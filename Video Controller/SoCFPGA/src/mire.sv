// module mire #(parameter HDISP = 800, VDISP = 480)(
//     wshb_if.master wshb_if
//     );

// assign wshb_if.we = '1;
// assign wshb_if.sel = 4'b0111;
// assign wshb_if.cti = '0;
// assign wshb_if.bte = '0;

// logic [$clog2(HDISP) - 1: 0] HCounter;
// logic [$clog2(VDISP) - 1: 0] VCounter;

// // mire
// assign wshb_if.dat_ms = ( !(HCounter % 16 ) | !( VCounter % 16 ) ) ? 32'h00FFFFFF : 32'h00000000 ;


// //Compteur de lignes
// always_ff@(posedge wshb_if.clk)begin
//     if(wshb_if.rst || (VCounter == VDISP))
//         VCounter <= 0;
//     else if ((HCounter == VDISP - 1))
//         VCounter <= VCounter + 1; // Si on est en fin de ligne (le dernier pixel)
//                                                     // passer à la ligne suivante
//     end


// always_ff@(posedge wshb_if.clk)begin
//     if(wshb_if.rst || (HCounter == VDISP - 1))
//         HCounter <= 0;
//     else
//         HCounter <= HCounter + 1;
// end


// always_ff @( posedge wshb_if.clk or posedge wshb_if.rst )
// begin
    
//     if (wshb_if.rst) wshb_if.adr <= 0;
//     else if (wshb_if.ack)
//             if (wshb_if.adr == 4*(HDISP*VDISP -1)) wshb_if.adr <=0;
//             else wshb_if.adr <= wshb_if.adr + 4;
    
// end

// logic [5:0]fair_counter;

// always_ff @( posedge wshb_if.clk or posedge wshb_if.rst )
// begin
//     if (wshb_if.rst) fair_counter <= 0;
//     else
//     begin
//         if (fair_counter == 63) fair_counter <= 0;
//         else if (wshb_if.ack) fair_counter <= fair_counter + 1;
//     end
// end


// assign wshb_if.cyc = !(fair_counter == 63);
// assign wshb_if.stb = !(fair_counter == 63);




// endmodule


module mire #(parameter HDISP = 800, VDISP = 480) (wshb_if.master wshb_if );





assign wshb_if.we = '1;
assign wshb_if.sel = 4'b0111;  //because RGB takes 3 bytes (LSB)
assign wshb_if.cti = '0; // classic bus
assign wshb_if.bte = '0;




// Modified counters from module vga for making a grid
logic [$clog2(HDISP)-1:0] pixel_count;
logic [$clog2(VDISP)-1:0] lines_count;

// Modified counters logic from module vga
always_ff @( posedge wshb_if.clk or posedge wshb_if.rst )
begin
    if (wshb_if.rst)
    begin
        pixel_count <= 0;
        lines_count <= 0;
    end
    else if (wshb_if.ack)
    begin
        pixel_count <= pixel_count + 1;
        if (pixel_count == HDISP -1)
        begin
            pixel_count <= 0;
            lines_count <= lines_count + 1;
            if (lines_count == VDISP -1)
                lines_count <= 0;
        end

    end
end



// Making a grid
assign wshb_if.dat_ms = ( !(pixel_count % 16 ) | !( lines_count % 16 ) ) ? 32'h00FFFFFF : 32'h00000000 ;




// Write in SDRAM
// Adaptation from module vga

always_ff @( posedge wshb_if.clk or posedge wshb_if.rst )
begin
    
    if (wshb_if.rst) wshb_if.adr <= 0;
    else if (wshb_if.ack)
            if (wshb_if.adr == 4*(HDISP*VDISP -1)) wshb_if.adr <=0;
            else wshb_if.adr <= wshb_if.adr + 4;
    
end



// "fair play" for letting vga communicate with module wshb_intercon, 1 empty cycle in cyc and stb every 64 cycles
// Implementing fair play

logic [5:0]fair_counter;

always_ff @( posedge wshb_if.clk or posedge wshb_if.rst )
begin
    if (wshb_if.rst) fair_counter <= 0;
    else
    begin
        if (fair_counter == 63) fair_counter <= 0;
        else if (wshb_if.ack) fair_counter <= fair_counter + 1;
    end
end


assign wshb_if.cyc = !(fair_counter == 63);
assign wshb_if.stb = !(fair_counter == 63);




endmodule