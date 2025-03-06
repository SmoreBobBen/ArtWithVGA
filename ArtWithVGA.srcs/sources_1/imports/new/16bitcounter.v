`timescale 1ns / 1ps

module countUD16L(
    input clk_i,
    input reset_i,
    input Up_i,
    input Dw_i,
    input LD_i,
    input [15:0] Din_i,
    output [15:0] Q_o,
    output UTC_o,
    output DTC_o
    );
    
    wire loUTC, loDTC, hiUTC, hiDTC;
    
    assign UTC_o = hiUTC & loUTC;
    assign DTC_o = hiDTC & loDTC;
    
    countUD8L locount (.clk_i(clk_i), .reset_i(reset_i), .Up_i(Up_i), .Dw_i(Dw_i), .LD_i(LD_i), .Din_i(Din_i[7:0]),
                       .Q_o(Q_o[7:0]), .UTC_o(loUTC), .DTC_o(loDTC));
    countUD8L hicount (.clk_i(clk_i), .reset_i(reset_i), .Up_i(Up_i&loUTC), .Dw_i(Dw_i&loDTC), .LD_i(LD_i), .Din_i(Din_i[15:8]),
                       .Q_o(Q_o[15:8]), .UTC_o(hiUTC), .DTC_o(hiDTC));

endmodule