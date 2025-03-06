`timescale 1ns / 1ps


module PixelPosition(
    input clk_i,
    input reset_i,
    output [15:0] vpx,
    output [15:0] hpx,
    output frameClk
    );
    
    wire Hend, Vend;
    wire [1:0] UTC, DTC;
    
    countUD16L hpos (.clk_i(clk_i), .reset_i(reset_i), .Up_i(1'b1&(~Hend)), .Dw_i(1'b0), .LD_i(Hend), .Din_i(16'h0000), 
                     .Q_o(hpx), .UTC_o(UTC[0]), .DTC_o(DTC[0]));
    countUD16L vpos (.clk_i(clk_i), .reset_i(reset_i), .Up_i(Hend&(~Vend)), .Dw_i(1'b0), .LD_i(Vend&Hend), .Din_i(16'h0000), 
                     .Q_o(vpx), .UTC_o(UTC[1]), .DTC_o(DTC[1]));
                     
    assign Hend = (hpx >= 799);
    assign Vend = (vpx >= 524);
    
    assign frameClk = Hend&Vend;
    
    
endmodule
