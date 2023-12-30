module sram(input clk, wr,
        input [7:0] Addr,
        input [7:0] Di,
        output logic [7:0] Do );

logic[7:0] mem [0:255];

always_ff @(posedge clk)
    begin
        if (wr)
        mem[Addr] <= Di;
    Do <= mem[Addr];
    end

endmodule
