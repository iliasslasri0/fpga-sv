module rom (input clk,
            input [7:0] Addr,
            output logic [7:0] Do );
logic[7:0] mem [0:255];

initial // For simulation
    $readmemh("init.txt", mem);

always_ff @(posedge clk)
    Do <= mem[Addr];

endmodule