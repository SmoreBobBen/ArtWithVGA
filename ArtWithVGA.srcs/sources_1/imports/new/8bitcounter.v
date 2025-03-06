`timescale 1ns / 1ps

module countUD8L(
    input clk_i,
    input reset_i,
    input Up_i,
    input Dw_i,
    input LD_i,
    input [7:0] Din_i,
    output [7:0] Q_o,
    output UTC_o,
    output DTC_o
    );
    
    //wires
    wire [7:0] upTrig;
    wire [7:0] dwnTrig;
    wire [7:0] Q;
    wire [7:0] D;
    
    //IO assignments
    assign Q_o = Q;
    assign upTrig[0] = Up_i;
    assign dwnTrig[0] = Dw_i;
    assign UTC_o = (Q[0])&(Q[1])&(Q[2])&(Q[3])&(Q[4])&(Q[5])&(Q[6])&(Q[7]);
    assign DTC_o = (~Q[0])&(~Q[1])&(~Q[2])&(~Q[3])&(~Q[4])&(~Q[5])&(~Q[6])&(~Q[7]);
    
    //temp debug stuff
    //wire [4:0] Din;
    //assign Din = Din_i;
    //wire LD;
    //assign LD = LD_i;
    //assign UTC = 1'b0;
    //assign DTC = 1'b0;
    
    //load logic
    assign D[0] = (Q[0]^(upTrig[0]|dwnTrig[0]))&(~LD_i)|(Din_i[0])&(LD_i);
    assign D[1] = (Q[1]^(upTrig[1]|dwnTrig[1]))&(~LD_i)|(Din_i[1])&(LD_i);
    assign D[2] = (Q[2]^(upTrig[2]|dwnTrig[2]))&(~LD_i)|(Din_i[2])&(LD_i);
    assign D[3] = (Q[3]^(upTrig[3]|dwnTrig[3]))&(~LD_i)|(Din_i[3])&(LD_i);
    assign D[4] = (Q[4]^(upTrig[4]|dwnTrig[4]))&(~LD_i)|(Din_i[4])&(LD_i);
    assign D[5] = (Q[5]^(upTrig[5]|dwnTrig[5]))&(~LD_i)|(Din_i[5])&(LD_i);
    assign D[6] = (Q[6]^(upTrig[6]|dwnTrig[6]))&(~LD_i)|(Din_i[6])&(LD_i);
    assign D[7] = (Q[7]^(upTrig[7]|dwnTrig[7]))&(~LD_i)|(Din_i[7])&(LD_i);
    
    //assign D[0] = (Q[0]^(upTrig[0]|dwnTrig[0]));
    //assign D[1] = (Q[1]^(upTrig[1]|dwnTrig[1]));
    //assign D[2] = (Q[2]^(upTrig[2]|dwnTrig[2]));
    //assign D[3] = (Q[3]^(upTrig[3]|dwnTrig[3]));
    //assign D[4] = (Q[4]^(upTrig[4]|dwnTrig[4]));
    
    //addition logic
    assign upTrig[1] = upTrig[0] & Q[0];
    assign upTrig[2] = upTrig[1] & Q[1];
    assign upTrig[3] = upTrig[2] & Q[2];
    assign upTrig[4] = upTrig[3] & Q[3];
    assign upTrig[5] = upTrig[4] & Q[4];
    assign upTrig[6] = upTrig[5] & Q[5];
    assign upTrig[7] = upTrig[6] & Q[6];
    
    //subtraction logic
    assign dwnTrig[1] = dwnTrig[0] & ~Q[0];
    assign dwnTrig[2] = dwnTrig[1] & ~Q[1];
    assign dwnTrig[3] = dwnTrig[2] & ~Q[2];
    assign dwnTrig[4] = dwnTrig[3] & ~Q[3];
    assign dwnTrig[5] = dwnTrig[4] & ~Q[4];
    assign dwnTrig[6] = dwnTrig[5] & ~Q[5];
    assign dwnTrig[7] = dwnTrig[6] & ~Q[6];
    
    
    //flip flops
    FDRE #(.INIT(1'b0)) DFF0 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(D[0]), .Q(Q[0]));
    FDRE #(.INIT(1'b0)) DFF1 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(D[1]), .Q(Q[1]));
    FDRE #(.INIT(1'b0)) DFF2 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(D[2]), .Q(Q[2]));
    FDRE #(.INIT(1'b0)) DFF3 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(D[3]), .Q(Q[3]));
    FDRE #(.INIT(1'b0)) DFF4 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(D[4]), .Q(Q[4]));
    FDRE #(.INIT(1'b0)) DFF5 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(D[5]), .Q(Q[5]));
    FDRE #(.INIT(1'b0)) DFF6 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(D[6]), .Q(Q[6]));
    FDRE #(.INIT(1'b0)) DFF7 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(D[7]), .Q(Q[7]));
    
endmodule