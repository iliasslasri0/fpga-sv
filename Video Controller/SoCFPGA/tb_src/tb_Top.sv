`timescale 1ns/1ps

`default_nettype none

module tb_Top;

// Entrées sorties extérieures
bit   FPGA_CLK1_50;
logic [1:0]	KEY;
wire  [7:0]	LED;
logic [3:0]	SW;

// Interface vers le support matériel
hws_if      hws_ifm();

// Instance du module Top
Top Top0(.*) ;

///////////////////////////////
//  Code élèves
//////////////////////////////

// Générateur d'horloge à 50Mhz pour générer le signal FPGA_CLK1_50
always #25 FPGA_CLK1_50 = ~FPGA_CLK1_50; 

// Un processus simulant une action d'initialisation utilisant le bouton KEY[0] 
initial begin
    KEY[0] = 0;
    forever #(128) KEY[0] = ~KEY[0];
    #(4000)$stop();
end


endmodule
