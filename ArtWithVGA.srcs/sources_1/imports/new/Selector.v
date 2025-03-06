`timescale 1ns / 1ps


module Selector(
    input [15:0] N,
    input [3:0] sel,
    output [3:0] H
    );
    
    assign H = (N[15:12]&{4{sel[3]}}) | (N[11:8]&{4{sel[2]}}) | (N[7:4]&{4{sel[1]}}) | (N[3:0]&{4{sel[0]}});
    
    //H is N[15:12] when sel=(1000)
    //H is N[11:8] when sel=(0100)
    //H is N[7:4] when sel=(0010)
    //H is N[3:0] when sel=(0001
endmodule