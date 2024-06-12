//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed May 15 15:28:34 2024

module rom_w4_ip (dout, clk, oce, ce, reset, ad);

output [15:0] dout;
input clk;
input oce;
input ce;
input reset;
input [7:0] ad;

wire [15:0] prom_inst_0_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO({prom_inst_0_dout_w[15:0],dout[15:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,gw_gnd,ad[7:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_0.READ_MODE = 1'b0;
defparam prom_inst_0.BIT_WIDTH = 16;
defparam prom_inst_0.RESET_MODE = "SYNC";
defparam prom_inst_0.INIT_RAM_00 = 256'h01760320042CFCCEF7E7F82D09C209620509F081E824FE73FE40FF1E03DF0796;
defparam prom_inst_0.INIT_RAM_01 = 256'hFABFFCC6036A00AB00DBFF38F7F2FD4800C5042E09A004B7FC2302A0FFFE0264;
defparam prom_inst_0.INIT_RAM_02 = 256'h016700ABFDDFFFC3FAB0FAB8FFD7028C0223FBF8F8F3FE4E048B05BB0729FE96;
defparam prom_inst_0.INIT_RAM_03 = 256'h07750BDC0757FD2FFD5EFEFCFEF4041D058A03DDFF0BFDCEFC0FF827021200A5;
defparam prom_inst_0.INIT_RAM_04 = 256'hFDCEFF610074010700A30323039BFE41FF9FFD2B049A00A6F90FF817043CFBF6;
defparam prom_inst_0.INIT_RAM_05 = 256'hF92BF3D8E92BE892EC3DF01B07990433FC23F9DAFDC6005BFF36009F0111FE99;
defparam prom_inst_0.INIT_RAM_06 = 256'hF2E9F54D017E02EBFC0FFFAB01A20192035601B5FF71F8F6F580F7E1F344F363;
defparam prom_inst_0.INIT_RAM_07 = 256'hFEC5FEF4FDC40054013001E1008CFE0DFFFD015B00B70076FA7C086D051FFBB7;
defparam prom_inst_0.INIT_RAM_08 = 256'hFFAFFCA4FA1AF6C3FC090145FFD602740021FF7BF917F0D8F409F80A00FEFEA4;
defparam prom_inst_0.INIT_RAM_09 = 256'h0000000000000000000000000000000000000000FE69005DFF6AFFE0FEDF012B;

endmodule //rom_w4_ip
