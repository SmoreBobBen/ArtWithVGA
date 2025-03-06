`timescale 1ns / 1ps


module Hex7Seg(
    input [3:0] n,
    output [6:0] segs
    );
    
    assign segs[0] = (~n[3]&~n[2]&~n[1]&n[0])|(~n[3]&n[2]&~n[1]&~n[0])|(n[3]&~n[2]&n[1]&n[0])|(n[3]&n[2]&~n[1]&n[0]);
    assign segs[1] = (~n[3]&n[2]&~n[1]&n[0])|(~n[3]&n[2]&n[1]&~n[0])|(n[3]&~n[2]&n[1]&n[0])|(n[3]&n[2]&~n[1]&~n[0])|(n[3]&n[2]&n[1]&~n[0])|(n[3]&n[2]&n[1]&n[0]);
    assign segs[2] = (~n[3]&~n[2]&n[1]&~n[0])|(n[3]&n[2]&~n[1]&~n[0])|(n[3]&n[2]&n[1]&~n[0])|(n[3]&n[2]&n[1]&n[0]);
    assign segs[3] = (~n[3]&n[2]&~n[1]&~n[0])|(n[3]&~n[2]&n[1]&~n[0])|(~n[2]&~n[1]&n[0])|(n[2]&n[1]&n[0]);
    assign segs[4] = (~n[3]&n[2]&~n[1]&~n[0])|(n[3]&~n[2]&~n[1]&n[0])|(~n[3]&n[0]);
    assign segs[5] = (~n[3]&~n[2]&n[1]&~n[0])|(~n[3]&n[2]&n[1]&n[0])|(n[3]&n[2]&~n[1]&n[0])|(~n[3]&~n[2]&n[0]);
    assign segs[6] = (~n[3]&~n[2]&~n[1]&~n[0])|(~n[3]&~n[2]&~n[1]&n[0])|(~n[3]&n[2]&n[1]&n[0])|(n[3]&n[2]&~n[1]&~n[0]);
    
    /*
    //old code dont need
    assign DP = btnD;
    
    assign AN3 = 1;
    assign AN2 = 1;
    assign AN1 = 1;
    assign AN0 = 0;
    */
    
endmodule