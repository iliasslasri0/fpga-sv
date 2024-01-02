module MCE #(parameter TAILLE = 8)(
            input  [TAILLE-1:0] A, B,
            output [TAILLE-1:0] MAX, MIN
            );

        assign MAX = (A>B) ? A: B;
        assign MIN = (A>B) ? B: A;
    
endmodule