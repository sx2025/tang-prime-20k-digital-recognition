//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed May 15 15:26:35 2024

module rom_w2_ip (dout, clk, oce, ce, reset, ad);

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
defparam prom_inst_0.INIT_RAM_00 = 256'hFFD9FA5C06FC0628FC59FAF10CDAFD73E021E5560BE103CE05B904FD0089FA3A;
defparam prom_inst_0.INIT_RAM_01 = 256'h0180FD91F6F8FFE4FF4C00EAFD48F742F429FDB70AF3083EF8D101DA011002FC;
defparam prom_inst_0.INIT_RAM_02 = 256'hFF8E007CFF8B01750714097B0538FCFEFAA0026C07880806FD4BFCDBFE040634;
defparam prom_inst_0.INIT_RAM_03 = 256'hFCEDEE72F0170161FE00060203450091FAFBF8F900D102F1FF75FC44FCB4FE8F;
defparam prom_inst_0.INIT_RAM_04 = 256'hFEBCFFDDFFA50048FF0C00BB031F03AF01BBFD9C0B05F853ED2F01CE0C7C061E;
defparam prom_inst_0.INIT_RAM_05 = 256'h0870085C0A590B6206EBFEFBFBD102B80BDB07BF0484FED1FFC2FF2B000800A3;
defparam prom_inst_0.INIT_RAM_06 = 256'hF605F1690273FE28FF9CFE9FFAD6FAB8FB81FCA7FF33039BF0B2FD8E052A0916;
defparam prom_inst_0.INIT_RAM_07 = 256'h017B027700F0FDC9FF7AFEA30032001DFC7FFD55006C0237FA89083D0962FD56;
defparam prom_inst_0.INIT_RAM_08 = 256'h0A0A0F6605ABFD70FF3E0078007500DFFDE3F799FDCF00B7FBA3F203FFA7003F;
defparam prom_inst_0.INIT_RAM_09 = 256'h000000000000000000000000000000000000000000F00145FF440071FE6F0401;

endmodule //rom_w2_ip
