module topModule(input logic clk,
                input logic rst,
                input logic [7:0] datain,
                output logic [7:0] dataout
                );

    monInterface itf_0(
        .clk(clk),
        .rst(rst)
        );

    sender snd_0(
        .if_slv(itf_0.slave),
        .data(datain)
        );
        
    receiver rcv_0(
        .if_mst(itf_0.master),
        .data(dataout)
        );

endmodule