`timescale 1ns / 1ps


module RingCounter(
    input reset_i,
    input adv_i,
    input clk_i,
    output [3:0] ring_o
    );
    
    wire [3:0] out_dff;
    wire dff0_pre_inv; //dff before i
    
    FDRE #(.INIT(1'b0)) DFF0 (.C(clk_i), .R(reset_i), .CE(adv_i), .D(~out_dff[3]), .Q(out_dff[0]));
    FDRE #(.INIT(1'b0)) DFF1 (.C(clk_i), .R(reset_i), .CE(adv_i), .D(~out_dff[0]), .Q(out_dff[1]));
    FDRE #(.INIT(1'b0)) DFF2 (.C(clk_i), .R(reset_i), .CE(adv_i), .D(out_dff[1]), .Q(out_dff[2]));
    FDRE #(.INIT(1'b0)) DFF3 (.C(clk_i), .R(reset_i), .CE(adv_i), .D(out_dff[2]), .Q(out_dff[3]));
    
    assign ring_o = {~out_dff[0],out_dff[1],out_dff[2],out_dff[3]};
    
endmodule