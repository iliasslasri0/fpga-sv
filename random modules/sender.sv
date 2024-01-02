module sender(monInterface.master if_mst,
            input logic[7:0] data
            );

always_ff @(posedge if_mst.clk)
    if (if_mst.Sel)
        if_mst.Data <= data ;
    else
        if_mst.Data <= ’0 ;

endmodule