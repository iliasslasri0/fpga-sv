module receiver(
    monInterface.master if_mst,
    output logic[7:0] data);

logic [1:0] cmpt ;

always_ff @(posedge if_mst.clk or posedge if_mst.rst)
    if(if_mst.rst)
        cmpt <= ’0 ;
    else
        cmpt <= cmpt+1 ;

assign if_mst.Sel = cmpt[1] ;
assign data = if_mst.Data ;
endmodule