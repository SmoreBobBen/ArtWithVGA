`timescale 1ns / 1ps


module Lab6Top(
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
    wire [1:0] miscUTC; //placeholders to accept UTC from countdown timers
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
    wire btnDw;
    assign btnDw = btnD;

    //debug assignments
    
    
    //tie values
    assign led = 16'h0000;
    //assign led = {Separate, 10'h000, State}; //debug
    //assign led = {Separate, flashBorder, MemOn, AllowInputs, loadTime, runTime, init, HSecClk, SecClk, flashOnBorder, 1'b1, State}; //debug
    
    //make the clock
    labVGA_clks clkMod (.clkin(clkin), .greset(btnC), .clk(clk), .digsel(digsel));
    
    
    //GAME ELEMENTS -------------------------------------------------------------
    
    //input
    assign BluMem = (~(btnL&AllowInputs))&MemOn;
    assign RedMem = (~(btnR&AllowInputs))&MemOn;
    
    //molecules
    Molecule RedMolA (.clk_i(clk), .reset_i(btnC), .frameClk(frameClk),
                      .initX(16'd50), .initY(16'd50), .init(init), .initdir(2'b01),
                      .currentX(rxa), .currentY(rya),
                      .MemOn(RedMem));
    Molecule RedMolB (.clk_i(clk), .reset_i(btnC), .frameClk(frameClk),
                      .initX(16'd600), .initY(16'd400), .init(init), .initdir(2'b10),
                      .currentX(rxb), .currentY(ryb),
                      .MemOn(RedMem));
    Molecule RedMolC (.clk_i(clk), .reset_i(btnC), .frameClk(frameClk),
                      .initX(16'd150), .initY(16'd300), .init(init), .initdir(2'b10),
                      .currentX(rxc), .currentY(ryc),
                      .MemOn(RedMem));
    Molecule RedMolD (.clk_i(clk), .reset_i(btnC), .frameClk(frameClk),
                      .initX(16'd500), .initY(16'd100), .init(init), .initdir(2'b11),
                      .currentX(rxd), .currentY(ryd),
                      .MemOn(RedMem));
    Molecule BluMolA (.clk_i(clk), .reset_i(btnC), .frameClk(frameClk),
                      .initX(16'd200), .initY(16'd150), .init(init), .initdir(2'b00),
                      .currentX(bxa), .currentY(bya),
                      .MemOn(BluMem));
    Molecule BluMolB (.clk_i(clk), .reset_i(btnC), .frameClk(frameClk),
                      .initX(16'd350), .initY(16'd350), .init(init), .initdir(2'b11),
                      .currentX(bxb), .currentY(byb),
                      .MemOn(BluMem));
    Molecule BluMolC (.clk_i(clk), .reset_i(btnC), .frameClk(frameClk),
                      .initX(16'd100), .initY(16'd450), .init(init), .initdir(2'b01),
                      .currentX(bxc), .currentY(byc),
                      .MemOn(BluMem));
    Molecule BluMolD (.clk_i(clk), .reset_i(btnC), .frameClk(frameClk),
                      .initX(16'd550), .initY(16'd200), .init(init), .initdir(2'b00),
                      .currentX(bxd), .currentY(byd),
                      .MemOn(BluMem));
    
    //figure out if the molecules are separated                  
    assign Separate = ((rxa<=300)&(rxb<=300)&(rxc<=300)&(rxd<=300)
                       &(bxa>=323)&(bxb>=323)&(bxc>=323)&(bxd>=323))
                     |((bxa<=300)&(bxb<=300)&(bxc<=300)&(bxd<=300)
                       &(rxa>=323)&(rxb>=323)&(rxc>=323)&(rxd>=323));
                       
    //Long time clocks
    FramesToSec SecClks (
        .clk_i(clk),
        .reset_i(btnC),
        .frameClk(frameClk),
        .runTime(1'b1),
        .HSecClk(HSecClk),
        .SecClk(SecClk)
    );
    
    //Timers
    countUD8L Timer8Sec (
        .clk_i(clk),
        .reset_i(btnC),
        .Up_i(1'b0),
        .Dw_i(SecClk&runTime&(~timeUp8)),
        .LD_i(loadTime),
        .Din_i(8'd08),
        .Q_o(timer8),
        .UTC_o(miscUTC[0]),
        .DTC_o(timeUp8)
    );
    
    countUD8L TimerSwitches (
        .clk_i(clk),
        .reset_i(btnC),
        .Up_i(1'b0),
        .Dw_i(SecClk&runTime&(~timeUpSw)&timeUp8),
        .LD_i(loadTime),
        .Din_i(sw[15:8]),
        .Q_o(timerSw),
        .UTC_o(miscUTC[1]),
        .DTC_o(timeUpSw)
    );
    
    //State Machine for Game State
    GameState GameStateMachine (
        .clk_i(clk),
        .reset_i(btnC),
        .btnU(btnU),
        .Separated(Separate),
        .timeUp8(timeUp8),
        .timeUpSw(timeUpSw),
        .State(State), //debug
        .initMol(init),
        .flashBorder(flashBorder),
        .MemOn(MemOn),
        .AllowInputs(AllowInputs),
        .runTime(runTime),
        .loadTime(loadTime),
        .flashTime(flashTime)
    );
    
    
    //DISPLAY -------------------------------------------------------------------
    //flashers
    Flasher HSecFlashMembrane (.clk_i(clk), .reset_i(btnC), .flashClk(HSecClk), .flashing(flashBorder), .flashOn(flashOnBorder));
    Flasher HSecFlashTime     (.clk_i(clk), .reset_i(btnC), .flashClk(HSecClk), .flashing(flashTime), .flashOn(flashOnTime));
    
    //pixel position
    PixelPosition PixPos (.clk_i(clk), .reset_i(btnC), .vpx(vpx), .hpx(hpx), .frameClk(frameClk));
    
    //pixel processor
    PixelProcessor PixProc (.clk_i(clk), .reset_i(btnC), .vpx(vpx), .hpx(hpx),
                            .Red(vgaRed), .Blu(vgaBlue), .Grn(vgaGreen),
                            .Hsync(Hsync), .Vsync(Vsync),
                            .borderOn(flashOnBorder),
                            .XRedMolA(rxa), .YRedMolA(rya),
                            .XRedMolB(rxb), .YRedMolB(ryb),
                            .XRedMolC(rxc), .YRedMolC(ryc),
                            .XRedMolD(rxd), .YRedMolD(ryd),
                            .XBluMolA(bxa), .YBluMolA(bya),
                            .XBluMolB(bxb), .YBluMolB(byb),
                            .XBluMolC(bxc), .YBluMolC(byc),
                            .XBluMolD(bxd), .YBluMolD(byd),
                            .RedMem(RedMem), .BluMem(BluMem));
    
    //Hex Display
    RingCounter RingCounter (.reset_i(btnC), .adv_i(digsel), .clk_i(clk), .ring_o(ringsel));
    assign an = {1'b1,
                 1'b1,
                 ~(ringsel[1]&flashOnTime), 
                 ~(ringsel[0]&flashOnTime)};
    
    assign dp = 1'b1;
    
    assign selin = {8'h00, timerSw};
    Selector Selector (.sel(ringsel), .N(selin), .H(selout));
    
    Hex7Seg HexDisplay (.n(selout), .segs(hexOut_w));
    
    assign seg = hexOut_w;
    
    
endmodule
