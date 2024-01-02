module receiver(
    monInterface.slave if_slv, // we can note moninterface if_mst, or interface if_mst, depending on the level of verefication we want at compilatio
    output logic[7:0] data);

logic [1:0] cmpt ;

always_ff @(posedge if_slv.clk or posedge if_slv.rst)
    if(if_slv.rst)
        cmpt <= ’0 ;
    else
        cmpt <= cmpt+1 ;

assign if_slv.Sel = cmpt[1] ;
assign data = if_slv.Data ;
endmodule