//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed May 08 23:16:56 2024

module mult_gen_0 (dout, a, b, ce, clk, reset);

output [25:0] dout;
input [7:0] a;
input [17:0] b;
input ce;
input clk;
input reset;

wire [9:0] dout_w;
wire [17:0] soa_w;
wire [17:0] sob_w;
wire gw_vcc;
wire gw_gnd;

assign gw_vcc = 1'b1;
assign gw_gnd = 1'b0;

MULT18X18 mult18x18_inst (
    .DOUT({dout_w[9:0],dout[25:0]}),
    .SOA(soa_w),
    .SOB(sob_w),
    .A({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,a[7:0]}),
    .B(b),
    .ASIGN(gw_gnd),
    .BSIGN(gw_vcc),
    .SIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .SIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .CE(ce),
    .CLK(clk),
    .RESET(reset),
    .ASEL(gw_gnd),
    .BSEL(gw_gnd)
);

defparam mult18x18_inst.AREG = 1'b1;
defparam mult18x18_inst.BREG = 1'b1;
defparam mult18x18_inst.OUT_REG = 1'b1;
defparam mult18x18_inst.PIPE_REG = 1'b0;
defparam mult18x18_inst.ASIGN_REG = 1'b0;
defparam mult18x18_inst.BSIGN_REG = 1'b0;
defparam mult18x18_inst.SOA_REG = 1'b0;
defparam mult18x18_inst.MULT_RESET_MODE = "SYNC";

endmodule //mult_gen_0
