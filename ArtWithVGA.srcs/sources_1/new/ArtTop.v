`timescale 1ns / 1ps


module ArtTop(
    input clkin,
    input [15:0] sw,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    input btnC, // reset
    output [6:0] seg,
    output dp,
    output [3:0] an,
    output [15:0] led,
    output Hsync,
    output Vsync,
    output [3:0] vgaRed,
    output [3:0] vgaBlue,
    output [3:0] vgaGreen
    );
    
    //wires
    wire clk, digsel, frameClk, HSecClk, SecClk, runTime, loadTime, timeUp8, timeUpSw;
    wire [12:0] miscUTC, miscDTC; //placeholders to accept UTC from countdown timers
    wire [7:0] timer8, timerSw;
    wire [15:0] vpx, hpx;
    wire init;
    wire BluMem, RedMem, flashBorder, flashOnBorder, flashTime, flashOnTime, MemOn, AllowInputs;
    wire Separate;
    wire [4:0] State; //only used for debug
    
    //display wires
    wire [6:0] hexOut_w;
    wire [3:0] ringsel;
    wire [15:0] selin;
    wire [3:0] selout;
    
    //molecule position wires, name format: [color][direction][letter a-d]
    wire [15:0] rxa, rya; 
    wire [15:0] rxb, ryb;
    wire [15:0] rxc, ryc;
    wire [15:0] rxd, ryd;
    wire [15:0] bxa, bya;
    wire [15:0] bxb, byb;
    wire [15:0] bxc, byc;
    wire [15:0] bxd, byd;

    //store unused values
    wire [15:0] sww;
    assign sww = sw;
    wire btnDw, btnLw, btnRw, btnUw;
    assign btnDw = btnD;
    assign btnLw = btnL;
    assign btnRw = btnR;
    assign btnUw = btnU;
    
    //debug assignments
    
    //tie values
    assign led = 16'h0000;
    //assign led = {Separate, 10'h000, State}; //debug
    //assign led = {Separate, flashBorder, MemOn, AllowInputs, loadTime, runTime, init, HSecClk, SecClk, flashOnBorder, 1'b1, State}; //debug
    
    //make the clock
    labVGA_clks clkMod (.clkin(clkin), .greset(btnC), .clk(clk), .digsel(digsel));
    
     //Long time clocks
    FramesToSec SecClks (
        .clk_i(clk),
        .reset_i(btnC),
        .frameClk(frameClk),
        .runTime(1'b1),
        .HSecClk(HSecClk),
        .SecClk(SecClk)
    );
    
    //NEW ART STUFF ------------------------------------------------------------------------
    
    PixelProcessor PixProc (.clk_i(clk), .reset_i(btnC), .vpx(vpx), .hpx(hpx),
                            .Red(vgaRed), .Blu(vgaBlue), .Grn(vgaGreen),
                            .Hsync(Hsync), .Vsync(Vsync),
                            .frameClk(frameClk),
                            .sw(sw[2:0])
                            );
    
    //DISPLAY ------------------------------------------------------------------------------
    //pixel position
    PixelPosition PixPos (.clk_i(clk), .reset_i(btnC), .vpx(vpx), .hpx(hpx), .frameClk(frameClk));
    
    //Hex Display
    RingCounter RingCounter (.reset_i(btnC), .adv_i(digsel), .clk_i(clk), .ring_o(ringsel));
    assign an = {1'b1,
                 1'b1,
                 ~(ringsel[1]), 
                 ~(ringsel[0])};
    
    assign dp = 1'b1;
    
    assign selin = {8'h00, 8'h21};
    Selector Selector (.sel(ringsel), .N(selin), .H(selout));
    
    Hex7Seg HexDisplay (.n(selout), .segs(hexOut_w));
    
    assign seg = hexOut_w;
    
    
endmodule
