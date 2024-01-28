`timescale 1ns/1ps

`default_nettype none

module tb_Top;

// Entrées sorties extérieures
bit   FPGA_CLK1_50;
logic [1:0]	KEY;
wire  [7:0]	LED;
logic [3:0]	SW;

// Interface vers le support matériel
hws_if hws_ifm();

///////////////////////////////
//////////////////////////////

// instance de video_if :
`define SIMULATION
initial begin
    KEY[0] = 1;
    #128ns KEY[0] = 0;
    #128ns KEY[0] = 1;
    #10ms $stop();
end

video_if video_if0() ;

// Instance du module Top
Top #(
    .HDISP(160),
    .VDISP(90)
) myTop (.*,
    .video_ifm(video_if0.master)
);


screen #(.mode(13),.X(160),.Y(90)) screen0(.video_ifs(video_if0));
// Générateur d'horloge à 50Mhz pour générer le signal FPGA_CLK1_50
always #25 FPGA_CLK1_50 = ~FPGA_CLK1_50; 

// Un processus simulant une action d'initialisation utilisant le bouton KEY[0] 
// initial begin
//     KEY[0] = 1;
//     #(128ns) 
//     KEY[0] = 0;
//     #(128ns)
//     KEY[0] = 1;
// end

endmodule
