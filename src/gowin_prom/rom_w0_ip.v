//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed May 15 15:27:54 2024

module rom_w0_ip (dout, clk, oce, ce, reset, ad);

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
defparam prom_inst_0.INIT_RAM_00 = 256'h016FFBB4008901B304900468F170EA85F75308590E9FF8D7F6C4FCC4FD3DF97E;
defparam prom_inst_0.INIT_RAM_01 = 256'h00ED020F0222006EFDBC010E02C4F446F584FEBD060004A503AA018A01A0012C;
defparam prom_inst_0.INIT_RAM_02 = 256'hFD88FE35FF0BFE3BFA0AF9C3FA17023C062E0129F93FF70BFE22F65BFD960120;
defparam prom_inst_0.INIT_RAM_03 = 256'h00D209A80BBD02BD04A10237FCFEF9ACF83700D9FF3EFEC602A601EA0158FE32;
defparam prom_inst_0.INIT_RAM_04 = 256'h0181FFDCFF56FFCFFCAEF995F6C8FFD703D604230742F50DF983060D05D1FB33;
defparam prom_inst_0.INIT_RAM_05 = 256'hFB0D05FB01E9006001F502D3FAE3F8E5FA57F9DFFC4100D1004EFFE5008BFFDB;
defparam prom_inst_0.INIT_RAM_06 = 256'hFD77F5DDFA30FB74FE10019A012B01FDFBFBFE43FF0BF827FF30070C076003CB;
defparam prom_inst_0.INIT_RAM_07 = 256'hFF94FFF9003700EDFFB0FF530016FEECFF91FE26FF81035102AE07000BAF0640;
defparam prom_inst_0.INIT_RAM_08 = 256'hF065FBB8FFC30185FFE30069008C01B3FAB90D0B097109F6071B04450153FFE5;
defparam prom_inst_0.INIT_RAM_09 = 256'h0000000000000000000000000000000000000000FC0E00ADFFD10243FFD2EEEA;

endmodule //rom_w0_ip
