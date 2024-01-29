module vga #(parameter HDISP = 800, parameter VDISP = 480)(
    input logic pixel_clk,
    input logic pixel_rst,
    video_if.master video_ifm,
    wshb_if.master wshb_ifm // interface permettra d'échanger des données de 32 bits avec une fréquence de bus de 100MHz
);

// ------------ FIFO INSTANCIATION -----
// ------------------------------------
logic write, read;
logic wfull, walmost_full;
logic rempty;
assign write = wshb_ifm.ack;
logic [31:0] wdata;
logic [31:0] rdata;
async_fifo
  #(
      .DATA_WIDTH(32), 
      .DEPTH_WIDTH(8),
      .ALMOST_FULL_THRESHOLD(255)
  )my_async_fifo
  (
      .rst(wshb_ifm.rst),
      .rclk(pixel_clk), // TODO
      .read(read),
      .rdata(rdata), 
      .rempty(rempty),
      .wclk(wshb_ifm.clk),
      .wdata(wdata), 
      .write(write),
      .wfull(wfull),
      .walmost_full(walmost_full)
   );

// Les constantes pour les timings seront fournies via des paramètres locaux
localparam HFP = 40;
localparam HPULSE = 48;
localparam HBP = 40;
localparam VFP = 13;
localparam VPULSE = 3;
localparam VBP = 29;

localparam H = HDISP + HFP + HPULSE + HBP;
localparam V = VDISP + VFP + VPULSE + VBP;
// // Counters
logic [$clog2(V) - 1: 0] VCounter = '0; // Vertical Counter (lignes)
logic [$clog2(H) - 1: 0] HCounter = '0; // Horizontal Counter (Pixels)

// le signal video_ifm.CLK sera simplement  pixel_clk
assign video_ifm.CLK = pixel_clk;

assign wshb_ifm.sel = 4'b1111;
assign wshb_ifm.we	= 1'b0;
assign wshb_ifm.cti = '0;
assign wshb_ifm.bte = '0;
assign wshb_ifm.stb = '1;

// ---------------------Lecture en SDRAM -------------------------
// ----------------------------------------------------------------
assign wshb_ifm.cyc = 1'b1;
logic [31:0]pixel = '0;

/// controlleur de l'adresse wshb_ifm.adr
always_ff @( posedge wshb_ifm.clk ) begin
    if ( wshb_ifm.rst )begin
        wshb_ifm.adr <= '0;
        end
    else if (wshb_ifm.ack && !wfull) begin
        wshb_ifm.adr <= (wshb_ifm.adr == 4*(HDISP*HCounter+VCounter)) ? 0: wshb_ifm.adr + 4;
    end
end


//Compteur de lignes
always_ff@(posedge wshb_ifm.clk)begin
    if(wshb_ifm.rst || (VCounter == VDISP))
        VCounter <= 0;
    else if ((HCounter == H - 1) && wshb_ifm.ack && !video_ifm.BLANK )
        VCounter <= VCounter + 1; // Si on est en fin de ligne (le dernier pixel)
                                                    // passer à la ligne suivante
    end


// Compteur de pixel
always_ff@(posedge wshb_ifm.clk)begin
    if(wshb_ifm.rst || (HCounter == HDISP - 1))
        HCounter <= 0;
    else if (wshb_ifm.ack && !video_ifm.BLANK )
        HCounter <= HCounter + 1;
end

// BLANKING
always_ff @( posedge wshb_ifm.clk ) begin
    if (wshb_ifm.rst)
        video_ifm.BLANK <= 1;
    else
        video_ifm.BLANK <= ((HCounter >= (H - HDISP)) && (VCounter >= (V - VDISP)));
end

//---------------Ecriture en FIFO --------------
// ---------------------------------------------

always_ff@(posedge wshb_ifm.clk)
if (wshb_ifm.ack)
    wdata <= wshb_ifm.dat_sm;


/// ------------- Lecture de la FIFO ----------------
/// --------------------------------------------------
always_ff@(posedge pixel_clk)begin
    
end

endmodule