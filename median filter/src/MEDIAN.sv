module MEDIAN (
    input logic CLK,
    input logic nRST,
    input logic DSI,
    input logic [7:0] DI,
    output logic [7:0] DO,
    output logic DSO
    );

enum logic[3:0] { ATT,STEP0, STEP1, STEP2, STEP3, STEP4, STEP5} state;
logic my_BYP;
logic [3:0] counter;

// instantie le module MED
MED #(.TAILLE(8), .NMBR(9)) med0(.BYP(my_BYP), .DSI(DSI), .DI(DI), .CLK(CLK), .DO(DO));

always_ff@(posedge CLK) begin
    if (!nRST)begin
        state <= DSI ? STEP1 : ATT; 
        counter <= 0;
        end
    else
    begin
        if ( counter == 8)
            counter <= 0;
        else
            counter <= counter + 1;
        
        // machine à 6 états + un état d'attente:
        case(state)
            ATT: begin
                state <= DSI ? STEP0 : ATT;
                counter <= 0;
            end

            STEP0: begin // Reception des 9 valeurs
                    if (counter == 8) 
                        state <= STEP1;
            end

            STEP1: begin // 8 à 0, 1 à 1
                    if (counter == 8)
                        state <= STEP2;
                        // counter <= 0;
            end
            STEP2:begin // 7 periodes à 0 & 2 periodes a 1
                    if (counter == 7)begin
                        counter <=0;
                        state <= STEP3;
                        end
            end

            STEP3:begin // 6 periodes a 0 & 3 periode a 1
                    if (counter == 8)begin
                        state <= STEP4;
                        end
            end

            STEP4: begin // 5 periodes a 0 & 4 periode a 1
                    if (counter == 8)begin
                        state <= STEP5;
                        end
            end

            STEP5: begin // 4 periodes a 0
                    if ( counter == 4)begin
                        state <= DSI ? STEP0 : ATT;
                        counter <= 0;
                        end
            end
        endcase
end
end


always_comb
    begin
        my_BYP = 0;
        DSO = 0;
        if(DSI) my_BYP = 1;
        if ( state == STEP0 && counter == 7) my_BYP = 1;
        else if ( state == STEP1 && counter == 7) my_BYP = 1;
        else if ( state == STEP2 && counter >= 6) my_BYP = 1;
        else if ( state == STEP3 && counter > 5) my_BYP = 1;
        else if ( state == STEP4 && counter > 4) my_BYP = 1;
        else if ( state == STEP5 && counter == 4) DSO = 1; 
    end
endmodule