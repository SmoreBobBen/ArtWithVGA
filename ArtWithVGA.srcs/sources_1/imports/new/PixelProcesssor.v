`timescale 1ns / 1ps


module PixelProcessor(
    input clk_i,
    input reset_i,
    input [15:0] vpx,
    input [15:0] hpx,
    
    input frameClk,
    
    input [2:0] sw,
    
    output [3:0] Red,
    output [3:0] Grn,
    output [3:0] Blu,
    output Hsync,
    output Vsync
    );
    
    //wires
    wire active;
    wire Hs, Vs;
    wire [3:0] R, G, B;
    
    
    //art stufff
    //ENTIRELY SELF-COUNTAINED --------------------------------------------------------
    wire [11:0] Colors;
    wire [7:0] RedOut, GrnOut, BluOut, FrameOut, HorizOut;
    wire [6:0] miscUTC, miscDTC;
    
    countUD8L FrameCount (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .Up_i(frameClk),
        .Dw_i(1'b0),
        .LD_i(8'b0),
        .Din_i(8'h00),
        .Q_o(FrameOut),
        .UTC_o(miscUTC[0]),
        .DTC_o(miscDTC[0])
    );
    
    countUD8L RedCount (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .Up_i((hpx<=320)&sw[2]),
        .Dw_i((hpx>320)&sw[2]),
        .LD_i((hpx==0)),
        .Din_i(8'h00),
        .Q_o(RedOut),
        .UTC_o(miscUTC[1]),
        .DTC_o(miscDTC[1])
    );
    
    countUD8L GrnCount (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .Up_i((hpx<=320)&sw[1]),
        .Dw_i((hpx>320)&sw[1]),
        .LD_i((hpx==0)),
        .Din_i(8'h00),
        .Q_o(GrnOut),
        .UTC_o(miscUTC[2]),
        .DTC_o(miscDTC[2])
    );
    
    countUD8L BluCount (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .Up_i((hpx<=320)&sw[0]),
        .Dw_i((hpx>320)&sw[0]),
        .LD_i((hpx==0)),
        .Din_i(8'h00),
        .Q_o(BluOut),
        .UTC_o(miscUTC[3]),
        .DTC_o(miscDTC[3])
    );
    
    countUD8L HorizCount (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .Up_i(hpx==0),
        .Dw_i(1'b0),
        .LD_i((vpx==0)&(hpx==0)),
        .Din_i(8'h00),
        .Q_o(HorizOut),
        .UTC_o(miscUTC[4]),
        .DTC_o(miscDTC[4])
    );
    
    assign Colors = {(RedOut[5:2])+(FrameOut[6:3]),
                     (GrnOut[5:2])+(FrameOut[6:3])-(HorizOut[5:2]),
                     (BluOut[5:2])+(FrameOut[5:2])+(HorizOut[5:2])};
    
    //ENTIRELY SELF-COUNTAINED --------------------------------------------------------

    
    //determine current frame
    assign active = (hpx <= 639)&(vpx <= 479);
    assign Hs = (hpx >= 655)&(hpx <= 750);
    assign Vs = (vpx == 489)|(vpx == 490);
    
    //debug
    assign R = {{4{active&sw[2]}}&{Colors[11:8]}};
    assign G = {{4{active&sw[1]}}&{Colors[7:4]}};
    assign B = {{4{active&sw[0]}}&{Colors[3:0]}};
    
    //synchronize values
    FDRE #(.INIT(1'b0)) RED0 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(R[0]), .Q(Red[0]));
    FDRE #(.INIT(1'b0)) RED1 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(R[1]), .Q(Red[1]));
    FDRE #(.INIT(1'b0)) RED2 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(R[2]), .Q(Red[2]));
    FDRE #(.INIT(1'b0)) RED3 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(R[3]), .Q(Red[3]));

    FDRE #(.INIT(1'b0)) GRN0 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(G[0]), .Q(Grn[0]));
    FDRE #(.INIT(1'b0)) GRN1 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(G[1]), .Q(Grn[1]));
    FDRE #(.INIT(1'b0)) GRN2 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(G[2]), .Q(Grn[2]));
    FDRE #(.INIT(1'b0)) GRN3 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(G[3]), .Q(Grn[3]));

    FDRE #(.INIT(1'b0)) BLU0 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(B[0]), .Q(Blu[0]));
    FDRE #(.INIT(1'b0)) BLU1 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(B[1]), .Q(Blu[1]));
    FDRE #(.INIT(1'b0)) BLU2 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(B[2]), .Q(Blu[2]));
    FDRE #(.INIT(1'b0)) BLU3 (.C(clk_i), .R(reset_i), .CE(1'b1), .D(B[3]), .Q(Blu[3]));
    
    FDRE #(.INIT(1'b1)) HSYNC (.C(clk_i), .R(reset_i), .CE(1'b1), .D(~Hs), .Q(Hsync));
    FDRE #(.INIT(1'b1)) VSYNC (.C(clk_i), .R(reset_i), .CE(1'b1), .D(~Vs), .Q(Vsync));




    
endmodule
