//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed May 29 16:00:19 2024

module rom_data_1 (dout, clk, oce, ce, reset, ad);

output [0:0] dout;
input clk;
input oce;
input ce;
input reset;
input [11:0] ad;

wire [30:0] prom_inst_0_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO({prom_inst_0_dout_w[30:0],dout[0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,gw_gnd,ad[11:0]})
);

defparam prom_inst_0.READ_MODE = 1'b0;
defparam prom_inst_0.BIT_WIDTH = 1;
defparam prom_inst_0.RESET_MODE = "SYNC";
defparam prom_inst_0.INIT_RAM_00 = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
defparam prom_inst_0.INIT_RAM_01 = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
defparam prom_inst_0.INIT_RAM_02 = 256'hFFFFFFFFFF8FFFFFFFFFFFE7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
defparam prom_inst_0.INIT_RAM_03 = 256'hFFFFFFFFFFFE3FFFFFFFFFFF8FFFFFFFFFFFE3FFFFFFFFFFF8FFFFFFFFFFFE03;
defparam prom_inst_0.INIT_RAM_04 = 256'hE3FFFFFFFFFFF8FFFFFFFFFFFE3FFFFFFFFFFF8FFFFFFFFFFFE3FFFFFFFFFFF8;
defparam prom_inst_0.INIT_RAM_05 = 256'hFF8FFFFFFFFFFFE3FFFFFFFFFFF8FFFFFFFFFFFE3FFFFFFFFFFF8FFFFFFFFFFF;
defparam prom_inst_0.INIT_RAM_06 = 256'hFFFFFFFFFFFFFFF800FFFFFFFFFFC1FFFFFFFFFFF8FFFFFFFFFFFE3FFFFFFFFF;
defparam prom_inst_0.INIT_RAM_07 = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
defparam prom_inst_0.INIT_RAM_08 = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
defparam prom_inst_0.INIT_RAM_09 = 256'h000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

endmodule //rom_data_1