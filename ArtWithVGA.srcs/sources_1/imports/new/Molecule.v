`timescale 1ns / 1ps


module Molecule(
    input clk_i,
    input reset_i,
    input frameClk,
    input MemOn,
    input [15:0] initX,
    input [15:0] initY,
    input [1:0] initdir,
    input init,
    output [15:0] currentX,
    output [15:0] currentY
    );
    
    //wires and outputs
    wire RL, DU;
    wire [15:0] xpos, ypos;
    wire [1:0] UTC, DTC;
    wire Lcol, Rcol;
    assign currentX = xpos;
    assign currentY = ypos;
    
    //collision detection
    assign Lcol = (xpos <= 8)|((xpos == 324)&(MemOn));
    assign Rcol = (xpos >= 615)|((xpos == 299)&(MemOn));
    assign Ucol = (ypos <= 8);
    assign Dcol = (ypos >= 456);
    
    //store direction states
    //    initdir: {DU, RL}
    //      0-0 /\ 0-1
    //       <      >
    //      1-0 \/ 1-1
    FDRE #(.INIT(1'b0)) RLDFF (.C(clk_i), .R(reset_i), .CE(frameClk), .D(((RL&(~Rcol)|Lcol)&(~init))|(init&initdir[0])), .Q(RL));
    FDRE #(.INIT(1'b0)) DUDFF (.C(clk_i), .R(reset_i), .CE(frameClk), .D(((DU&(~Dcol)|Ucol)&(~init))|(init&initdir[1])), .Q(DU));

    
    //coordinate counters
    countUD16L XPOS (.clk_i(clk_i), .reset_i(reset_i), .Up_i(frameClk&RL), .Dw_i(frameClk&(~RL)), .LD_i(init), .Din_i(initX), 
                     .Q_o(xpos), .UTC_o(UTC[0]), .DTC_o(DTC[0]));
    countUD16L YPOS (.clk_i(clk_i), .reset_i(reset_i), .Up_i(frameClk&DU), .Dw_i(frameClk&(~DU)), .LD_i(init), .Din_i(initY), 
                     .Q_o(ypos), .UTC_o(UTC[1]), .DTC_o(DTC[1]));
    
    
endmodule
