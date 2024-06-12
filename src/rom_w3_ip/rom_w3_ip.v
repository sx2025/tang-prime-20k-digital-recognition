//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed May 15 15:28:17 2024

module rom_w3_ip (dout, clk, oce, ce, reset, ad);

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
defparam prom_inst_0.INIT_RAM_00 = 256'h0095FF3806960222F948FA490D1C09FEF744D65FF5ECFFC8033904690B190CC1;
defparam prom_inst_0.INIT_RAM_01 = 256'hFF25FA3C01D8032B015200BFFBEAF6B1F5E701100A6706EDF94D00F3008D037C;
defparam prom_inst_0.INIT_RAM_02 = 256'hFE47FF07FEF6FC2FFC4901F609FD0987F7FDF5E4FF5C082F02BC056507340485;
defparam prom_inst_0.INIT_RAM_03 = 256'h0A3400CAF372F2F3FB5E01C705800408FF7103F704BA0214FEE8FB660185FFA7;
defparam prom_inst_0.INIT_RAM_04 = 256'h0106FFF1FFD8004CFFF1019300EDFE91FEDFFB640757FE68F407FBC30AD30573;
defparam prom_inst_0.INIT_RAM_05 = 256'h04C4F751F953FAD0F6EAEF82082009DC0961016DFC4A01BD00E70028FF940020;
defparam prom_inst_0.INIT_RAM_06 = 256'hF320ED8100D8FC70FE00021B005E00E2033DFEA7FACBF97EEF71F508F9A9010C;
defparam prom_inst_0.INIT_RAM_07 = 256'hFEBFFFFF022100AC0057FFC6FF11FE0F025A01DD00AA011CFCEF09CC0725FCE2;
defparam prom_inst_0.INIT_RAM_08 = 256'h03370321FAA9F4F1009D001500E801A4FFA1EEFEEE17ED99EC33E4B4016BFEB9;
defparam prom_inst_0.INIT_RAM_09 = 256'h0000000000000000000000000000000000000000012A010BFEC0026300FF0014;

endmodule //rom_w3_ip
