`default_nettype none

module Top (
    // Les signaux externes de la partie FPGA
	input  wire         FPGA_CLK1_50,
	input  wire  [1:0]	KEY,
	output logic [7:0]	LED,
	input  wire	 [3:0]	SW,
    // Les signaux du support matériel son regroupés dans une interface
    hws_if.master       hws_ifm
);

//====================================
//  Déclarations des signaux internes
//====================================
  wire        sys_rst;   // Le signal de reset du système
  wire        sys_clk;   // L'horloge système a 100Mhz
  wire        pixel_clk; // L'horloge de la video 32 Mhz

//=======================================================
//  La PLL pour la génération des horloges
//=======================================================

sys_pll  sys_pll_inst(
		   .refclk(FPGA_CLK1_50),   // refclk.clk
		   .rst(1'b0),              // pas de reset
		   .outclk_0(pixel_clk),    // horloge pixels a 32 Mhz
		   .outclk_1(sys_clk)       // horloge systeme a 100MHz
);

//=============================
//  Les bus Wishbone internes
//=============================
wshb_if #( .DATA_BYTES(4)) wshb_if_sdram  (sys_clk, sys_rst);
wshb_if #( .DATA_BYTES(4)) wshb_if_stream (sys_clk, sys_rst);

//=============================
//  Le support matériel
//=============================
hw_support hw_support_inst (
    .wshb_ifs (wshb_if_sdram),
    .wshb_ifm (wshb_if_stream),
    .hws_ifm  (hws_ifm),
	.sys_rst  (sys_rst), // output
    .SW_0     ( SW[0] ),
    .KEY      ( KEY )
 );

//=============================
// On neutralise l'interface
// du flux video pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
assign wshb_if_stream.ack = 1'b1;
assign wshb_if_stream.dat_sm = '0 ;
assign wshb_if_stream.err =  1'b0 ;
assign wshb_if_stream.rty =  1'b0 ;

//=============================
// On neutralise l'interface SDRAM
// pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
assign wshb_if_sdram.stb  = 1'b0;
assign wshb_if_sdram.cyc  = 1'b0;
assign wshb_if_sdram.we   = 1'b0;
assign wshb_if_sdram.adr  = '0  ;
assign wshb_if_sdram.dat_ms = '0 ;
assign wshb_if_sdram.sel = '0 ;
assign wshb_if_sdram.cti = '0 ;
assign wshb_if_sdram.bte = '0 ;

//--------------------------
//------- Code Eleves ------
//--------------------------

// Recopier la valeur  du signal KEY[0]  vers la led LED[0]
assign LED[0] = KEY[0];

// Clignoter le signal LED[1] à  1Hz en utilisant l'horloge sys_clk
`ifdef SIMULATION
  localparam hcmpt=50 ;
`else
  localparam hcmpt=50000000 ;
`endif

logic [26:0]counter = 0;
always_ff@(posedge sys_clk) 
    begin
        if(sys_rst) begin
            counter <= 0;
            LED[1] <= 0;
        end
        else if(counter == hcmpt)
            begin 
                counter <= 0;
                LED[1] <= !(LED[1]);
            end
        else counter <= counter + 1;
    end

// Mécanisme de rééinitialisation
logic Q;
logic pixel_rst;
always_ff@(posedge pixel_clk or posedge sys_rst)begin 
    if (sys_rst)begin
            pixel_rst <= 1;
            Q <= 1;
        end
    else
        begin
            Q <= 0;
            pixel_rst <= Q;
        end
end

`ifdef SIMULATION
  localparam hcmpt2= 16;
`else
  localparam hcmpt2= 16000000;
`endif

// Clignoter le signal LED[2] à  1Hz en utilisant l'horloge pixel_clk
logic [26:0]counter2 = 0;
always_ff@(posedge pixel_clk)
    begin
        if(pixel_rst) begin 
            counter2 <= 0;
            LED[2] <= 0;
        end
        else if(counter2 == hcmpt2)
            begin 
                counter2 <= 0;
                LED[2] <= !(LED[2]);
            end
        else counter2 <= counter2 + 1;
    end


// To get rid of Warning in synthesis
assign LED[3] = 0;
assign LED[4] = 0;
assign LED[5] = 0;
assign LED[6] = 0;
assign LED[7] = 0;
endmodule
