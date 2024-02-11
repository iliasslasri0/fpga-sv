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
      .rclk(pixel_clk),
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

assign wshb_ifm.sel = '1;
assign wshb_ifm.we	= 1'b0;
assign wshb_ifm.cti = '0;
assign wshb_ifm.bte = '0;

// ---------------------Lecture en SDRAM -------------------------
// ----------------------------------------------------------------

/// controlleur de l'adresse wshb_ifm.adr
logic [$clog2(H)-1:0]x = 0;
logic [$clog2(V)-1:0]y = 0;

assign wshb_ifm.adr = 4*(HDISP * y + x);

always_ff@(posedge wshb_ifm.clk)
begin
    if(wshb_ifm.rst)begin
        x <= 0;
        y <= 0;
        end
    else if (wshb_ifm.ack)
        begin
            if (x == HDISP - 1)
                begin
                    x <= 0;
                    if (y == VDISP -1)
                        y <= 0;
                    else
                        y <= y + 1;
                end
            else
                x <= x + 1;
    end
end


//Compteur de lignes
always_ff@(posedge pixel_clk)begin
    if(pixel_rst || (VCounter == V))
        VCounter <= 0;
    else if ((HCounter == H - 1))
        VCounter <= VCounter + 1; // Si on est en fin de ligne (le dernier pixel)
                                                    // passer à la ligne suivante
    end


// Compteur de pixel
always_ff@(posedge pixel_clk)begin
    if(pixel_rst || (HCounter == H - 1))
        HCounter <= 0;
    else
        HCounter <= HCounter + 1;
end


//---------------Ecriture en FIFO --------------
// ---------------------------------------------
assign wdata = wshb_ifm.dat_sm;

/// ------------- Lecture de la FIFO ----------------
/// --------------------------------------------------

// Rééchantillonnage wshb_ifm.clk to pixel_clk
logic D;
assign wshb_ifm.cyc = wshb_ifm.stb;

always_ff @(posedge wshb_ifm.clk)
begin
    if (wshb_ifm.rst) D <= '0;
    else if (!walmost_full) D <= '1;
end

assign wshb_ifm.stb = D & !wfull;

logic DA, wfull_pixel_clk;
always_ff @(posedge pixel_clk ) begin
    if (pixel_rst)begin
            DA <= '0;
            wfull_pixel_clk <= '0;
        end
    else begin 
        DA <= wfull;
        wfull_pixel_clk <= DA;
        end
end

logic was_full; // était remplie au mois une fois
always_ff@(posedge pixel_clk)begin
    if (pixel_rst) was_full <= 0; 
    else if (wfull_pixel_clk) 
        was_full <= 1;
end

assign video_ifm.HS = !(HCounter >= HFP && HCounter < HFP + HPULSE);
assign video_ifm.VS = !(VCounter >= VFP && VCounter < VFP + VPULSE);
assign video_ifm.BLANK = ((HCounter >= (H - HDISP)) && (VCounter >= (V - VDISP)));

assign read = video_ifm.BLANK & was_full & !rempty;
assign video_ifm.RGB = rdata[23:0];

endmodule