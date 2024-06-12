// *********************************************************************************
// Project Name : OSXXXX
// Author       : dengkanwen
// Email        : dengkanwen@163.com
// Website      : http://www.opensoc.cn/
// Create Time  : 2021-08-09 15:45:13
// File Name    : .v
// Module Name  : 
// Called By    :
// Abstract     :
//
// CopyRight(c) 2018, OpenSoc Studio.. 
// All Rights Reserved
//
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2021-08-09    Kevin           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns

module  conv_cal #(
        parameter       W_WIDTH =       16               ,
        parameter       B_WIDTH =       16               
)(
        // system signals
        input                   sclk                    ,       
        input                   s_rst_n                 ,       
        // DATA RAM
        output  reg     [ 4:0]  data_rd_addr            ,
        output  reg     [ 4:0]  row_cnt                 ,
        input           [ 4:0]  col_data                ,
        input                   cal_start               ,
        // PARAM ROM
        output  reg     [ 7:0]  param_rd_addr           ,
        output  reg     [ 4:0]  conv_cnt                ,
        input           [15:0]  param_w_h0              ,
        input           [15:0]  param_w_h1              ,
        input           [15:0]  param_w_h2              ,
        input           [15:0]  param_w_h3              ,
        input           [15:0]  param_w_h4              ,
        input   signed  [15:0]  param_bias              ,
        // 
        output  wire    [31:0]  conv_rslt_act           ,
        output  reg             conv_rslt_act_vld       
);

//========================================================================\
// =========== Define Parameter and Internal signals =========== 
//========================================================================/
reg                             conv_flag                       ;       
reg     [79:0]                  param_w_h0_arr                  ;       
reg     [79:0]                  param_w_h1_arr                  ;       
reg     [79:0]                  param_w_h2_arr                  ;       
reg     [79:0]                  param_w_h3_arr                  ;       
reg     [79:0]                  param_w_h4_arr                  ;       


reg     [ 4:0]                  col_data_r0                     ;
reg     [ 4:0]                  col_data_r1                     ;
reg     [ 4:0]                  col_data_r2                     ;
reg     [ 4:0]                  col_data_r3                     ;
reg     [ 4:0]                  col_data_r4                     ;

wire    signed  [23:0]          mult00                          ;               
wire    signed  [23:0]          mult01                          ;               
wire    signed  [23:0]          mult02                          ;               
wire    signed  [23:0]          mult03                          ;               
wire    signed  [23:0]          mult04                          ;               

wire    signed  [23:0]          mult10                          ;               
wire    signed  [23:0]          mult11                          ;               
wire    signed  [23:0]          mult12                          ;               
wire    signed  [23:0]          mult13                          ;               
wire    signed  [23:0]          mult14                          ;               

wire    signed  [23:0]          mult20                          ;               
wire    signed  [23:0]          mult21                          ;               
wire    signed  [23:0]          mult22                          ;               
wire    signed  [23:0]          mult23                          ;               
wire    signed  [23:0]          mult24                          ;               

wire    signed  [23:0]          mult30                          ;               
wire    signed  [23:0]          mult31                          ;               
wire    signed  [23:0]          mult32                          ;               
wire    signed  [23:0]          mult33                          ;               
wire    signed  [23:0]          mult34                          ;               

wire    signed  [23:0]          mult40                          ;               
wire    signed  [23:0]          mult41                          ;               
wire    signed  [23:0]          mult42                          ;               
wire    signed  [23:0]          mult43                          ;               
wire    signed  [23:0]          mult44                          ;               


reg     signed    [31:0]        conv_rslt                       ;



//=============================================================================
//**************    Main Code   **************
//=============================================================================

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                conv_flag       <=      1'b0;
        else if(conv_cnt == 'd29 && row_cnt == 'd23 && data_rd_addr == 'd31)
                conv_flag       <=      1'b0;
        else if(cal_start == 1'b1)
                conv_flag       <=      1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                param_rd_addr   <=      'd0; 
        else if(conv_flag == 1'b0)
                param_rd_addr   <=      'd0;
        else if(conv_flag == 1'b1 && row_cnt == 'd0 && data_rd_addr <= 'd4)
                param_rd_addr   <=      param_rd_addr + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0) begin
                param_w_h0_arr  <=      'd0;
                param_w_h1_arr  <=      'd0;
                param_w_h2_arr  <=      'd0;
                param_w_h3_arr  <=      'd0;
                param_w_h4_arr  <=      'd0;
        end
        else if(data_rd_addr >= 'd1 && data_rd_addr <= 'd5 && row_cnt == 'd0) begin
                param_w_h0_arr  <=      {param_w_h0, param_w_h0_arr[W_WIDTH*5-1:W_WIDTH]}; 
                param_w_h1_arr  <=      {param_w_h1, param_w_h1_arr[W_WIDTH*5-1:W_WIDTH]}; 
                param_w_h2_arr  <=      {param_w_h2, param_w_h2_arr[W_WIDTH*5-1:W_WIDTH]}; 
                param_w_h3_arr  <=      {param_w_h3, param_w_h3_arr[W_WIDTH*5-1:W_WIDTH]}; 
                param_w_h4_arr  <=      {param_w_h4, param_w_h4_arr[W_WIDTH*5-1:W_WIDTH]}; 
        end
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                row_cnt <=      'd0;
        else if(row_cnt == 'd23 && conv_flag == 1'b1 && data_rd_addr == 'd31)
                row_cnt <=      'd0;
        else if(conv_flag == 1'b1 && data_rd_addr == 'd31)
                row_cnt <=      row_cnt + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                data_rd_addr    <=      'd0;
        else if(conv_flag == 1'b1 && data_rd_addr == 'd31)
                data_rd_addr    <=      'd0;
        else if(conv_flag == 1'b1)
                data_rd_addr    <=      data_rd_addr + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0) begin
                col_data_r0     <=      'd0;
                col_data_r1     <=      'd0;
                col_data_r2     <=      'd0;
                col_data_r3     <=      'd0;
                col_data_r4     <=      'd0;
        end
        else begin
                col_data_r4     <=      col_data;
                col_data_r3     <=      col_data_r4;
                col_data_r2     <=      col_data_r3;
                col_data_r1     <=      col_data_r2;
                col_data_r0     <=      col_data_r1;
        end
end

//////////////////////////////////////////////////////////////////////////////////
mult_gen_0 mult_gen_U00 (
        .dout(mult00), //output [25:0] dout
        .a({8{col_data_r0[0]}}), //input [7:0] a
        .b(param_w_h0_arr[W_WIDTH-1:0]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U01 (
        .dout(mult01), //output [25:0] dout
        .a({8{col_data_r1[0]}}), //input [7:0] a
        .b(param_w_h0_arr[W_WIDTH*2-1:W_WIDTH]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U02 (
        .dout(mult02), //output [25:0] dout
        .a({8{col_data_r2[0]}}), //input [7:0] a
        .b(param_w_h0_arr[W_WIDTH*3-1:W_WIDTH*2]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U03 (
        .dout(mult03), //output [25:0] dout
        .a({8{col_data_r3[0]}}), //input [7:0] a
        .b(param_w_h0_arr[W_WIDTH*4-1:W_WIDTH*3]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U04 (
        .dout(mult04), //output [25:0] dout
        .a({8{col_data_r0[0]}}), //input [7:0] a
        .b(param_w_h0_arr[W_WIDTH*5-1:W_WIDTH*4]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);


mult_gen_0 mult_gen_U10 (
        .dout(mult10), //output [25:0] dout
        .a({8{col_data_r0[1]}}), //input [7:0] a
        .b(param_w_h1_arr[W_WIDTH-1:0]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U11 (
        .dout(mult11), //output [25:0] dout
        .a({8{col_data_r1[1]}}), //input [7:0] a
        .b(param_w_h1_arr[W_WIDTH*2-1:W_WIDTH]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U12 (
        .dout(mult12), //output [25:0] dout
        .a({8{col_data_r2[1]}}), //input [7:0] a
        .b(param_w_h1_arr[W_WIDTH*3-1:W_WIDTH*2]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U13 (
        .dout(mult13), //output [25:0] dout
        .a({8{col_data_r3[1]}}), //input [7:0] a
        .b(param_w_h1_arr[W_WIDTH*4-1:W_WIDTH*3]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U14 (
        .dout(mult14), //output [25:0] dout
        .a({8{col_data_r4[1]}}), //input [7:0] a
        .b(param_w_h1_arr[W_WIDTH*5-1:W_WIDTH*4]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U20 (
        .dout(mult20), //output [25:0] dout
        .a({8{col_data_r0[2]}}), //input [7:0] a
        .b(param_w_h2_arr[W_WIDTH-1:0]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U21 (
        .dout(mult21), //output [25:0] dout
        .a({8{col_data_r1[2]}}), //input [7:0] a
        .b(param_w_h2_arr[W_WIDTH*2-1:W_WIDTH]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U22 (
        .dout(mult22), //output [25:0] dout
        .a({8{col_data_r2[2]}}), //input [7:0] a
        .b(param_w_h2_arr[W_WIDTH*3-1:W_WIDTH*2]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U23 (
        .dout(mult23), //output [25:0] dout
        .a({8{col_data_r3[2]}}), //input [7:0] a
        .b(param_w_h2_arr[W_WIDTH*4-1:W_WIDTH*3]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U24 (
        .dout(mult24), //output [25:0] dout
        .a({8{col_data_r4[2]}}), //input [7:0] a
        .b(param_w_h2_arr[W_WIDTH*5-1:W_WIDTH*4]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U30 (
        .dout(mult30), //output [25:0] dout
        .a({8{col_data_r0[3]}}), //input [7:0] a
        .b(param_w_h3_arr[W_WIDTH-1:0]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U31 (
        .dout(mult31), //output [25:0] dout
        .a({8{col_data_r1[3]}}), //input [7:0] a
        .b(param_w_h3_arr[W_WIDTH*2-1:W_WIDTH]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U32 (
        .dout(mult32), //output [25:0] dout
        .a({8{col_data_r2[3]}}), //input [7:0] a
        .b(param_w_h3_arr[W_WIDTH*3-1:W_WIDTH*2]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U33 (
        .dout(mult33), //output [25:0] dout
        .a({8{col_data_r3[3]}}), //input [7:0] a
        .b(param_w_h3_arr[W_WIDTH*4-1:W_WIDTH*3]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U34 (
        .dout(mult34), //output [25:0] dout
        .a({8{col_data_r4[3]}}), //input [7:0] a
        .b(param_w_h3_arr[W_WIDTH*5-1:W_WIDTH*4]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);


mult_gen_0 mult_gen_U40 (
        .dout(mult40), //output [25:0] dout
        .a({8{col_data_r0[4]}}), //input [7:0] a
        .b(param_w_h3_arr[W_WIDTH-1:0]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U41 (
        .dout(mult41), //output [25:0] dout
        .a({8{col_data_r1[4]}}), //input [7:0] a
        .b(param_w_h4_arr[W_WIDTH*2-1:W_WIDTH]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U42 (
        .dout(mult42), //output [25:0] dout
        .a({8{col_data_r2[4]}}), //input [7:0] a
        .b(param_w_h4_arr[W_WIDTH*3-1:W_WIDTH*2]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U43 (
        .dout(mult43), //output [25:0] dout
        .a({8{col_data_r3[4]}}), //input [7:0] a
        .b(param_w_h4_arr[W_WIDTH*4-1:W_WIDTH*3]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);

mult_gen_0 mult_gen_U44 (
        .dout(mult44), //output [25:0] dout
        .a({8{col_data_r4[4]}}), //input [7:0] a
        .b(param_w_h4_arr[W_WIDTH*5-1:W_WIDTH*4]), //input [17:0] b
        .ce(1'b1), //input ce
        .clk(sclk), //input clk
        .reset(1'b0) //input reset
);
//////////////////////////////////////////////////////////////////////////////////

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                conv_cnt        <=      'd0;
        else if(conv_flag == 1'b0)
                conv_cnt        <=      'd0;
        else if(conv_flag == 1'b1 && row_cnt == 'd23 && data_rd_addr == 'd31)
                conv_cnt        <=      conv_cnt + 1'b1;
end


always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                conv_rslt       <=      'd0;
        else if(data_rd_addr >= 'd7 && data_rd_addr <= 'd30)
                conv_rslt       <=      mult00 + mult01 + mult02 + mult03 + mult04 +
                                        mult10 + mult11 + mult12 + mult13 + mult14 +
                                        mult20 + mult21 + mult22 + mult23 + mult24 +
                                        mult30 + mult31 + mult32 + mult33 + mult34 +
                                        mult40 + mult41 + mult42 + mult43 + mult44 + param_bias;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                conv_rslt_act_vld       <=      1'b0;
        else if(data_rd_addr >= 'd7 && data_rd_addr <= 'd30)
                conv_rslt_act_vld       <=      1'b1;
        else
                conv_rslt_act_vld       <=      1'b0;
end


assign  conv_rslt_act   =       (conv_rslt[31] == 1'b0) ? conv_rslt : 'd0;


endmodule
