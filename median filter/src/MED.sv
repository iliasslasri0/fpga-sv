module MED #(parameter TAILLE = 8, parameter NMBR = 9)(
            input logic BYP,
            input logic DSI,
            input logic [TAILLE-1:0] DI,
            input logic CLK,
            output logic [TAILLE-1:0] DO
            );

logic [TAILLE-1:0] _MAX, _MIN;
logic [TAILLE-1:0] R [NMBR-1:0];

MCE #(.TAILLE(TAILLE)) mce0(.A(R[NMBR-2]), .B(R[NMBR-1]), .MAX(_MAX), .MIN(_MIN));

always_ff @(posedge CLK ) begin
    // Traitemennt des registres R1 à R7
    for (integer i = 1; i < NMBR-1; i++)
            R[i] <= R[i-1];
    
    // traitement de R0
    if (DSI) 
        R[0] <= DI;
    else
        R[0] <= _MIN;

    // traitement de R8
    if(BYP)
        R[NMBR-1] <= R[NMBR-2];
    else
        R[NMBR-1] <= _MAX;
     
end

always_comb
DO = R[NMBR-1];

endmodule