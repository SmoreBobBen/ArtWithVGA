`timescale 1ns / 1ps


module FramesToSec(
    input clk_i,
    input reset_i,
    input frameClk,
    input runTime,
    output HSecClk,
    output SecClk
    );
    
    //60 fps means
    //30 frames = 1/2 sec
    //60 frams = 1 sec
    
    wire HSecEnd, SecEnd;
    wire [7:0] HSecFrame, SecFrame;
    wire [1:0] UTC, DTC;
    
    assign HSecEnd = (HSecFrame>=29); //30-1 because counting from 0
    assign SecEnd = (SecFrame>=59);

    
    countUD8L HSecCounter (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .Up_i(runTime&frameClk&(~HSecEnd)),
        .Dw_i(1'b0),
        .LD_i(HSecEnd),
        .Din_i(8'h00),
        .Q_o(HSecFrame),
        .UTC_o(UTC[0]),
        .DTC_o(DTC[0])
    );
    
    countUD8L SecCounter (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .Up_i(runTime&frameClk&(~SecEnd)),
        .Dw_i(1'b0),
        .LD_i(SecEnd),
        .Din_i(8'h00),
        .Q_o(SecFrame),
        .UTC_o(UTC[0]),
        .DTC_o(DTC[0])
    );
    
    assign HSecClk = HSecEnd;
    assign SecClk = SecEnd;
    
endmodule
