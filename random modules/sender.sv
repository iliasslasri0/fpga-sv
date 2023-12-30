module sender(monInterface.slave if_slv,
            input logic[7:0] data
            );

always_ff @(posedge if_slv.clk)
    if (if_slv.Sel)
        if_slv.Data <= data ;
    else
        if_slv.Data <= ’0 ;

endmodule