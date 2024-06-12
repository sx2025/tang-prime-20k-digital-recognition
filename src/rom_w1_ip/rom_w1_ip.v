//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed May 15 15:27:31 2024

module rom_w1_ip (dout, clk, oce, ce, reset, ad);

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
defparam prom_inst_0.INIT_RAM_00 = 256'h0102F7D70349056301ACFF900220E6E4E446FE291117FF20FDD4FAE0F557EBD7;
defparam prom_inst_0.INIT_RAM_01 = 256'h042B0262FB29029E00E802210255F258F18FFBD706AB065AFFD500EDFFCF00B5;
defparam prom_inst_0.INIT_RAM_02 = 256'h02C30286FF0903DD0394FF04F746EF8502B40824043EFD4DFAF0ECF9FA4404DE;
defparam prom_inst_0.INIT_RAM_03 = 256'hF523F47B04280D10038104C60004FEB8F849FC36001101B3029A02A501180212;
defparam prom_inst_0.INIT_RAM_04 = 256'hFED500BEFFDA0027FE74FEDF006C07E30454014B0B8DF1CBF23A05E709C6FCB1;
defparam prom_inst_0.INIT_RAM_05 = 256'h03930AD80921092C07050482EA17F456024B036806B800A30041006700D2FF6B;
defparam prom_inst_0.INIT_RAM_06 = 256'hF808F35003DD01D502520137FF120015022004EB07C004E1F49104AA08A30883;
defparam prom_inst_0.INIT_RAM_07 = 256'hFEC1FD8EFCFCFFCB0071009501CC00C8FED1FF20015C026DFBF9084B09DAFFAE;
defparam prom_inst_0.INIT_RAM_08 = 256'hFBF509EA07EA03EA020C000A003300E5FC3808D30A290BCE098B018DFF5FFE5E;
defparam prom_inst_0.INIT_RAM_09 = 256'h0000000000000000000000000000000000000000FF67FFB300670169FEDDF7EE;

endmodule //rom_w1_ip
