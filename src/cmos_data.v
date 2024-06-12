// *********************************************************************************
// Project Name : OSXXXX
// Author       : dengkanwen
// Email        : dengkanwen@163.com
// Website      : http://www.opensoc.cn/
// Create Time  : 2021-05-09 09:54:24
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
// 2021-05-09    Kevin           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns

module  cmos_data(
        //
        input                   s_rst_n                 ,             
        // Camera
        input                   m_pclk                  ,             
        input           [15:0]  m_data                  ,
        input                   m_vs                    ,       
        input                   m_href                  ,    
        input                   m_wr_en                 ,
        //
        input           [ 7:0]  bin_theta               ,       
        // Video in Core   
        output  wire     [15:0]       vid_data                ,
        output  wire            bin_data                ,
        output  wire            bin_data_vld            ,
        output  reg [ 9:0]                  row_cnt                         ,
        output  reg     [ 9:0]                  col_cnt                         

);

//========================================================================\
// =========== Define Parameter and Internal signals =========== 
//========================================================================/
// Gray = R*0.299 + G*0.587 + B*0.114
// Gray = R*76 + G*150 + B*29
reg     [ 9:0]                  row_cnt                         ;
reg     [ 9:0]                  col_cnt                         ;

reg     [15:0]                  r_mult                          ;
reg     [15:0]                  g_mult                          ;
reg     [15:0]                  b_mult                          ;

wire    [15:0]                  gray                            ;


//=============================================================================
//**************    Main Code   **************
//=============================================================================
assign  gray            =       r_mult + g_mult + b_mult;
assign  vid_data        =       (col_cnt >= 'd184 && col_cnt <= 'd296 && row_cnt >= 'd80 && row_cnt <= 'd192) ? 
                                ((gray[15:8] < bin_theta) ?  16'hffff : 16'h0) : m_data;
assign  bin_data        =       vid_data;
assign  bin_data_vld    =       (col_cnt >= 'd184 && col_cnt < 'd296 && row_cnt >= 'd80 && row_cnt < 'd192) ? 1'b1 : 1'b0;



always  @(posedge m_pclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                col_cnt <=      'd0;
        else if(m_href == 1'b0)
                col_cnt <=      'd0;
        else if(m_href == 1'b1 && m_wr_en == 1'b1)
                col_cnt <=      col_cnt + 1'b1;
end

always  @(posedge m_pclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                row_cnt <=      'd0;
        else if(m_vs == 1'b1)
                row_cnt <=      'd0;
        else if( m_href == 1'b1 &&m_wr_en == 1'b1 && col_cnt == 'd479)  //
                row_cnt <=      row_cnt + 1'b1;
end

always  @(posedge m_pclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0) begin
                r_mult  <=      'd0;
                g_mult  <=      'd0;
                b_mult  <=      'd0;
        end
        else if(m_wr_en == 1'b1) begin
                r_mult  <=      {m_data[15:11], 3'h0} * 76;
                g_mult  <=      {m_data[10:05], 2'h0} * 150;
                b_mult  <=      {m_data[04:00], 3'h0} * 29;
        end
end


endmodule
