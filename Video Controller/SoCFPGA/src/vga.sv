module vga #(parameter HDISP = 800, parameter VDISP = 480)(
    input logic pixel_clk,
    input logic pixel_rst,
    video_if.master video_ifm
);

// Les constantes pour les timings seront fournies via des paramètres locaux
localparam HFP = 40;
localparam HPULSE = 48;
localparam HBP = 40;
localparam VFP = 13;
localparam VPULSE = 3;
localparam VBP = 29;

localparam H = HDISP + HFP + HPULSE + HBP;
localparam V = VDISP + VFP + VPULSE + VBP;
// // Counters
logic [$clog2(V) - 1: 0] VCounter; // Vertical Counter (lignes)
logic [$clog2(H) - 1: 0] HCounter; // Horizontal Counter (Pixels)

// le signal video_ifm.CLK sera simplement  pixel_clk
assign video_ifm.CLK = pixel_clk;

// Compteur de pixel
always_ff@(posedge pixel_clk)begin
    if(pixel_rst || (HCounter == H - 1))
        HCounter <= 0;
    else 
        HCounter <= HCounter + 1;
end

//Compteur de lignes
always_ff@(posedge pixel_clk)begin
    if(pixel_rst || (VCounter == V))
        VCounter <= 0;
    else if ((HCounter == H - 1))
        VCounter <= VCounter + 1; // Si on est en fin de ligne (le dernier pixel)
                                                    // passer à la ligne suivante
    end

// Les  signaux de synchronisation  (video_ifm.HS, video_ifm.VS, video_ifm.BLANK)
always_ff@(posedge pixel_clk)begin
    if(pixel_rst)begin
        video_ifm.HS <= 1;
        video_ifm.VS <= 1;
        video_ifm.BLANK <= 1;
        video_ifm.RGB <= 24'h000000;
    end
    else 
        video_ifm.HS <= !(HCounter >= HFP && HCounter < HFP + HPULSE);
        video_ifm.VS <= !(VCounter >= VFP && VCounter < VFP + VPULSE);
        video_ifm.BLANK <= ((HCounter >= (H - HDISP)) && (VCounter >= (V - VDISP)));
        if( ((HCounter >= (H - HDISP)) && (VCounter >= (V - VDISP))) )begin
            video_ifm.RGB <= ((HCounter - (H - HDISP)) % 16) && ((VCounter - (V - VDISP)) % 16) ? 24'h000000 : 24'hFFFFFF;
        end
    end
endmodule