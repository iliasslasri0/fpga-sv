//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------
//
// Le paramètre mem_adr_width doit permettre de déterminer le nombre 
// de mots de la mémoire : (2048 pour mem_adr_width=11)

module wb_bram #(parameter mem_adr_width = 11) (
      // Wishbone interface
      wshb_if.slave wb_s
      );

      logic [3:0][7:0] mem [0:(2**mem_adr_width)-1];


      assign wb_s.err = 0;
      assign wb_s.rty = 0;

      logic x = 0;

      logic counter = 0;

      // Traitement de ACK pour l'écriture et 'x' pour la lecture
      assign wb_s.ack = (wb_s.we & wb_s.stb) | x;

      // Traitement de ACK pour la lecture et de rst
      always_ff@(posedge wb_s.clk) 
      begin
            // reset
            begin
                  if (wb_s.rst) begin
                        x <= 0;
                        counter <= 0;
                  end
                  else if(!wb_s.we & wb_s.stb)
                        begin
                              x <= 1;
                        end
            end


            // Traitement de dat_sm pour la lecture
            if(!wb_s.we && wb_s.stb) 
                  begin
                        if(wb_s.cti == 0 || ( wb_s.cti[0] && wb_s.cti[1] && wb_s.cti[2])) // Classic Cycle & End of Brust
                              begin 
                                    counter <= 0;
                                    x <= !x;
                              end
                        else if (wb_s.cti[1] && !wb_s.cti[0]) // Incrementing Burst Cycle
                              begin 
                                    counter <= 1;
                              end 
                        else // Constant Address Burst Cycle 
                              begin 
                                    counter <= 0;
                              end
                        wb_s.dat_sm <= mem[wb_s.adr[mem_adr_width+1:2] + counter];
                  end
      end

      // Traitement pour écriture
      always_ff@(posedge wb_s.clk)     
            if (wb_s.we && wb_s.stb) begin
                  for (int i = 0; i < 4; i++)
                        if (wb_s.sel[i])
                              mem[wb_s.adr[mem_adr_width+1:2]][i] <= wb_s.dat_ms[8*i +:8]; 
            end


      endmodule

