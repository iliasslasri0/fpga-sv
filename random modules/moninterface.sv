interface monInterface (
                        input logic clk, rst
                        );
logic [7:0] Data ;
logic Sel ;

    modport master (
        input clk, rst, Data,
        output Sel
        );

    modport slave (
        input clk, rst, Sel,
        output Data
        );
endinterface