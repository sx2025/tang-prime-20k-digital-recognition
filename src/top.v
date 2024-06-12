module top(
	input                       clk,
	input                       rst_n,
	inout                       cmos_scl,          //cmos i2c clock
	inout                       cmos_sda,          //cmos i2c data
	input                       cmos_vsync,        //cmos vsync
	input                       cmos_href,         //cmos hsync refrence,data valid
	input                       cmos_pclk,         //cmos pxiel clock
    output                      cmos_xclk,         //cmos externl clock 
	input   [7:0]               cmos_db,           //cmos data
	output                      cmos_rst_n,        //cmos reset 
	output                      cmos_pwdn,         //cmos power down
	
	//output [3:0] 				state_led,

	output [14-1:0]             ddr_addr,       //ROW_WIDTH=14
	output [3-1:0]              ddr_bank,       //BANK_WIDTH=3
	output                      ddr_cs,
	output                      ddr_ras,
	output                      ddr_cas,
	output                      ddr_we,
	output                      ddr_ck,
	output                      ddr_ck_n,
	output                      ddr_cke,
	output                      ddr_odt,
	output                      ddr_reset_n,
	output [2-1:0]              ddr_dm,         //DM_WIDTH=2
	inout [16-1:0]              ddr_dq,         //DQ_WIDTH=16
	inout [2-1:0]               ddr_dqs,        //DQS_WIDTH=2
	inout [2-1:0]               ddr_dqs_n,      //DQS_WIDTH=2


    input                       key_in,
	output                      lcd_dclk,	
	output                      lcd_hs,            //lcd horizontal synchronization
	output                      lcd_vs,            //lcd vertical synchronization        
	output                      lcd_de,            //lcd data enable     
	output[4:0]                 lcd_r,             //lcd red
	output[5:0]                 lcd_g,             //lcd green
	output[4:0]                 lcd_b,	           //lcd blue
    output[3:0]                 led
);

//memory interface
wire                   memory_clk         ;
wire                   dma_clk         	  ;
wire                   pll_lock           ;
wire                   cmd_ready          ;
wire[2:0]              cmd                ;
wire                   cmd_en             ;
wire[5:0]              app_burst_number   ;
wire[ADDR_WIDTH-1:0]   addr               ;
wire                   wr_data_rdy        ;
wire                   wr_data_en         ;//
wire                   wr_data_end        ;//
wire[DATA_WIDTH-1:0]   wr_data            ;   
wire[DATA_WIDTH/8-1:0] wr_data_mask       ;   
wire                   rd_data_valid      ;  
wire                   rd_data_end        ;//unused 
wire[DATA_WIDTH-1:0]   rd_data            ;   
wire                   init_calib_complete;

wire   [7:0]         img_y;
wire                  monoc           ;
//According to IP parameters to choose
`define	    WR_VIDEO_WIDTH_16
`define	DEF_WR_VIDEO_WIDTH 16

`define	    RD_VIDEO_WIDTH_16
`define	DEF_RD_VIDEO_WIDTH 16

`define	USE_THREE_FRAME_BUFFER

`define	DEF_ADDR_WIDTH 28 
`define	DEF_SRAM_DATA_WIDTH 128
//
//=========================================================
//SRAM parameters
parameter ADDR_WIDTH          = `DEF_ADDR_WIDTH;    //存储单元是byte，总容量=2^27*16bit = 2Gbit,增加1位rank地址，{rank[0],bank[2:0],row[13:0],cloumn[9:0]}
parameter DATA_WIDTH          = `DEF_SRAM_DATA_WIDTH;   //与生成DDR3IP有关，此ddr3 2Gbit, x16， 时钟比例1:4 ，则固定128bit
parameter WR_VIDEO_WIDTH      = `DEF_WR_VIDEO_WIDTH;  
parameter RD_VIDEO_WIDTH      = `DEF_RD_VIDEO_WIDTH;  

wire                            video_clk;         //video pixel clock
//-------------------
//syn_code
wire                      syn_off0_re;  // ofifo read enable signal
wire                      syn_off0_vs;
wire                      syn_off0_hs;
                          
wire                      off0_syn_de  ;
wire [RD_VIDEO_WIDTH-1:0] off0_syn_data;

wire[15:0]                      cmos_16bit_data;
wire                            cmos_16bit_clk;
wire[15:0] 						write_data;

wire[9:0]                       lut_index;
wire[31:0]                      lut_data;

assign cmos_xclk = cmos_clk;
assign cmos_pwdn = 1'b0;
assign cmos_rst_n = 1'b1;
assign write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};



//cnn port
wire                            down_data                       ;       
wire                            down_data_vld                   ;       
wire    [ 6:0]                  down_col_cnt                    ;       
wire    [ 6:0]                  down_row_cnt                    ;       

wire    [ 4:0]                  data_rd_addr                    ;       
wire    [ 4:0]                  conv_row_cnt                    ;       
wire    [ 4:0]                  col_data                        ;       
wire                            cal_start                       ;       


wire    [ 7:0]                  param_rd_addr                   ;       
wire    [ 4:0]                  conv_cnt                        ;       
wire    [15:0]                  param_w_h0                      ;       
wire    [15:0]                  param_w_h1                      ;       
wire    [15:0]                  param_w_h2                      ;       
wire    [15:0]                  param_w_h3                      ;       
wire    [15:0]                  param_w_h4                      ;       
wire    [15:0]                  param_bias                      ;       


wire    [31:0]                  conv_rslt_act                   ;       
wire                            conv_rslt_act_vld               ;  


//状态指示灯
// assign state_led[3] = 
// assign state_led[2] = 
//assign state_led[1] = rst_n; //复位指示灯
//assign state_led[0] = init_calib_complete; //DDR3初始化指示灯

//generate the CMOS sensor clock and the SDRAM controller clock
sys_pll sys_pll_m0(
	.clkin                     (cmos_clk                  ),
	.clkout                    (video_clk 	              )
	);
cmos_pll cmos_pll_m0(
	.clkin                     (clk                      		),
	.clkout                    (cmos_clk 	              		)
	);

mem_pll mem_pll_m0(
	.clkin                     (cmos_clk                        ),
	.clkout                    (memory_clk 	              		),
	.lock 					   (pll_lock 						)
	);

//I2C master controller
i2c_config i2c_config_m0(
	.rst                        (~rst_n                   ),
	.clk                        (clk                      ),
	.clk_div_cnt                (16'd500                  ),
	.i2c_addr_2byte             (1'b1                     ),
	.lut_index                  (lut_index                ),
	.lut_dev_addr               (lut_data[31:24]          ),
	.lut_reg_addr               (lut_data[23:8]           ),
	.lut_reg_data               (lut_data[7:0]            ),
	.error                      (                         ),
	.done                       (                         ),
	.i2c_scl                    (cmos_scl                 ),
	.i2c_sda                    (cmos_sda                 )
);
//configure look-up table
lut_ov5640_rgb565_480_272 lut_ov5640_rgb565_480_272_m0(
	.lut_index                  (lut_index                ),
	.lut_data                   (lut_data                 )
);
//CMOS sensor 8bit data is converted to 16bit data
cmos_8_16bit cmos_8_16bit_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.pdata_i                    (cmos_db                  ),
	.de_i                       (cmos_href                ),
	.pdata_o                    (cmos_16bit_data          ),
	.hblank                     (cmos_16bit_wr            ),
	.de_o                       (cmos_16bit_clk           )
);

//parameter define
parameter NUM_ROW = 1  ;               // 需识别的图像的行数
parameter NUM_COL = 4  ;               // 需识别的图像的列数
parameter DEPBIT  = 11 ;               // 数据位宽

//wire define
wire   [ 7:0]         img_y;
wire                  monoc;
wire                  monoc_fall;
wire   [DEPBIT-1:0]   row_border_addr;
wire   [DEPBIT-1:0]   row_border_data;
wire   [DEPBIT-1:0]   col_border_addr;
wire   [DEPBIT-1:0]   col_border_data;
wire   [3:0]          num_col;
wire   [3:0]          num_row;
wire                  hs_t0;
wire                  vs_t0;
wire                  de_t0;
wire   [ 1:0]         frame_cnt;
wire                  project_done_flag;

//*****************************************************
//**                    main code
//*****************************************************

cmos_data u_cmos_data(
        //
        .s_rst_n            (rst_n	),             
        .m_pclk             (cmos_16bit_clk	),             
        .m_data             (cmos_16bit_data	),
        .m_vs               (cmos_vsync	),       
        .m_href             (cmos_16bit_wr	),    
        .m_wr_en            (cmos_16bit_wr	),
        .bin_theta          (	),       
        .vid_data           (	),
        .bin_data           (	),
        .bin_data_vld       (	),
        .row_cnt            (pixel_ypos	),
        .col_cnt            (pixel_xpos	)        

);

lcd_driver u_lcd_driver(           
    .lcd_clk        (cmos_16bit_clk),    
    .sys_rst_n      (rst_n),    
    .lcd_hs         (lcd_hsb),       
    .lcd_vs         (lcd_vsb),       
    .lcd_de         (lcd_deb),       
    .lcd_rgb        (colour_rgb),
    .lcd_bl         (lcd_bl),
    .lcd_rst        (lcd_rst),
    .lcd_pclk       (lcd_pclk),
    
    .pixel_data     (cmos_16bit_data), 
    .data_req       (data_req),
    .out_vsync      (out_vsync),
    .h_disp         (h_disp),
    .v_disp         (v_disp), 
    .pixel_xpos     (), 
    .pixel_ypos     ()

    ); 


wire [15:0] colour_rgb;

//RGB转YCbCr模块
rgb2ycbcr u_rgb2ycbcr(
    //module clock
    .clk             (cmos_16bit_clk),            // 时钟信号
    .rst_n           (rst_n  ),            // 复位信号（低有效）
    //图像处理前的数据接口
    .pre_frame_vsync (cmos_vsync),    // vsync信号
    .pre_frame_hsync (cmos_href),    // href信号
    .pre_frame_de    (cmos_href),    // data enable信号
    .img_red         (cmos_16bit_data[4:0] ),
    .img_green       (cmos_16bit_data[10:5 ] ),
    .img_blue        (cmos_16bit_data[15:11] ),
    //图像处理后的数据接口
    .post_frame_vsync(vs_t0),               // vsync信号
    .post_frame_hsync(hs_t0),               // href信号
    .post_frame_de   (de_t0),               // data enable信号
    .img_y           (img_y),
    .img_cb          (),
    .img_cr          ()
);
wire post_frame_vsync;
wire post_frame_hsync;
wire post_frame_de;



//二值化模块
binarization u_binarization(
    //module clock
    .clk                (cmos_16bit_clk),          // 时钟信号
    .rst_n              (rst_n  ),          // 复位信号（低有效）
    //图像处理前的数据接口
    .pre_frame_vsync    (vs_t0),            // vsync信号
    .pre_frame_hsync    (hs_t0),            // href信号
    .pre_frame_de       (de_t0),            // data enable信号
    .color              (img_y),
    //图像处理后的数据接口
    .post_frame_vsync   (post_frame_vsync), // vsync信号
    .post_frame_hsync   (post_frame_hsync), // href信号
    .post_frame_de      (post_frame_de   ), // data enable信号
    .monoc              (monoc           ), // 单色图像像素数据
    .monoc_fall         (monoc_fall      )
    //user interface
);
/*
    assign lcd_vs      			  = post_frame_vsync;//syn_off0_vs;
    assign lcd_hs      			  = post_frame_hsync;//syn_off0_hs;
    assign lcd_de      			  = post_frame_de;//off0_syn_de;
*/
//assign {lcd_b,lcd_g,lcd_r}    = post_rgb[15:0];//{r,g,b}
wire    [10:0] pixel_xpos            ;
wire    [10:0] pixel_ypos            ;
//投影模块
projection #(
    .NUM_ROW(NUM_ROW),
    .NUM_COL(NUM_COL),
    .DEPBIT (DEPBIT)
) u_projection(
    //module clock
    .clk                (cmos_16bit_clk    ),          // 时钟信号
    .rst_n              (rst_n  ),          // 复位信号（低有效）
    //Image data interface
    .frame_vsync        (post_frame_vsync), // vsync信号
    .frame_hsync        (post_frame_hsync), // href信号
    .frame_de           (post_frame_de   ), // data enable信号
    .monoc              (monoc           ), // 单色图像像素数据
    .ypos               (pixel_ypos),
    .xpos               (pixel_xpos),
    //project border ram interface
    .row_border_addr_rd (row_border_addr),
    .row_border_data_rd (row_border_data),
    .col_border_addr_rd (col_border_addr),
    .col_border_data_rd (col_border_data),
    //user interface
	 .h_total_pexel      (13'd480),    
	 .v_total_pexel      (13'd272),
    .num_col            (num_col),
    .num_row            (num_row),
    .frame_cnt          (frame_cnt),
    .project_done_flag  (project_done_flag)
);

//数字特征识别模块
digital_recognition #(
    .NUM_ROW(NUM_ROW),
    .NUM_COL(NUM_COL),
    .NUM_WIDTH((NUM_ROW*NUM_COL<<2)-1)
)u_digital_recognition(
    //module clock
    .clk                (cmos_16bit_clk       ),        // 时钟信号
    .rst_n              (rst_n     ),        // 复位信号（低有效）
    //image data interface
    .monoc              (monoc     ),
    .monoc_fall         (monoc_fall),
    .color_rgb          (post_rgb  ),    
    .xpos               (pixel_xpos      ),
    .ypos               (pixel_ypos      ),
    //project border ram interface
    .row_border_addr    (row_border_addr),
    .row_border_data    (row_border_data),
    .col_border_addr    (col_border_addr),
    .col_border_data    (col_border_data),
    .num_col            (num_col),
    .num_row            (num_row),
    //user interface
    .frame_cnt          (frame_cnt),
    .project_done_flag  (project_done_flag),
    .digit              (digit)
);

wire [15:0] digit;


wire out_frame_vsync,out_frame_href,out_frame_clken,out_img_Bit;

VIP_Sobel_Edge_Detector 
    #(
    .SOBEL_THRESHOLD  (128)//sobel阈值
    )
u_VIP_Sobel_Edge_Detector(
    .clk (cmos_16bit_clk),   
    .rst_n (rst_n),  
    
    //预处理数据
    .per_frame_vsync (vs_t0),   //预处理帧有效信号
    .per_frame_href  (hs_t0),   //预处理行有效信号
    .per_frame_clken (de_t0), //预处理图像使能信号
    .per_img_Y       (img_y),         //输入灰度数据
    
    //处理后的数据
    .post_frame_vsync (out_frame_vsync), //处理后帧有效信号
    .post_frame_href  (out_frame_href),  //处理后行有效信号
    .post_frame_clken (out_frame_clken), //输出使能信号
    .post_img_Bit     (out_img_Bit)     //输出像素有效标志(1: Value, 0:inValid)
    
    //用户接口
//    .Sobel_Threshold  (Sobel_Threshold) //Sobel 阈值
);

wire [15:0] video_data_in;
assign video_data_in=(key_in==0)?({16{out_img_Bit}}):post_rgb;


/*
wire    [15:0]  vid_data;
cmos_data cmos_data_m0(
        //
        .s_rst_n(rst_n)                 ,             
        // Camera
        .m_pclk(cmos_16bit_clk)                  ,             
        .m_data(cmos_16bit_data)                  ,
        .m_vs(cmos_vsync)                    ,       
        .m_href(cmos_16bit_wr)                  ,    
        .m_wr_en(cmos_16bit_wr)                 ,
        //
        .bin_theta(8'd64)               ,       
        // Video in Core   
        .vid_data(vid_data)             ,
        //downsample
        .bin_data(bin_data)                     ,
        .bin_data_vld(bin_data_vld)             
);

//wire  bin_data;
//wire  bin_data_vld;

downsample u_downsample(
        // system signals
        .sclk(cmos_16bit_clk)                    ,       
        .s_rst_n(rst_n)                 ,       
        //
        .bin_data(bin_data)                ,       
        .bin_data_vld(bin_data_vld)            ,       
        //
        .down_data(down_data)               ,       
        .down_data_vld(down_data_vld)       ,
        .col_cnt(down_col_cnt)            ,
        .row_cnt(down_row_cnt)                       
);

data_ram        data_ram_inst(
        // system singals
        .sclk                   (cmos_16bit_clk                   ),
        .s_rst_n                (rst_n               ),
        // downsample
        .down_data              (down_data              ),
        .down_data_vld          (down_data_vld          ),
        .down_col_cnt           (down_col_cnt           ),
        .down_row_cnt           (down_row_cnt           ),
        // Conv Cal
        .data_rd_addr           (data_rd_addr           ),
        .conv_row_cnt           (conv_row_cnt           ),
        .col_data               (col_data               ),
        .cal_start              (cal_start              )
);

param_rom       param_rom_inst(
        // system signals
        .sclk                   (cmos_16bit_clk                   ),
        .s_rst_n                (rst_n                ),
        //
        .param_rd_addr          (param_rd_addr          ),
        .conv_cnt               (conv_cnt               ),
        .param_w_h0             (param_w_h0             ),
        .param_w_h1             (param_w_h1             ),
        .param_w_h2             (param_w_h2             ),
        .param_w_h3             (param_w_h3             ),
        .param_w_h4             (param_w_h4             ),
        .param_bias             (param_bias             )
);


conv_cal        conv_cal_inst(
        // system signals
        .sclk                   (cmos_16bit_clk                   ),
        .s_rst_n                (rst_n                ),
        // DATA RAM
        .data_rd_addr           (data_rd_addr           ),
        .row_cnt                (conv_row_cnt           ),
        .col_data               (col_data               ),
        .cal_start              (cal_start              ),
        // PARAM ROM
        .param_rd_addr          (param_rd_addr          ),
        .conv_cnt               (conv_cnt               ),
        .param_w_h0             (param_w_h0             ),
        .param_w_h1             (param_w_h1             ),
        .param_w_h2             (param_w_h2             ),
        .param_w_h3             (param_w_h3             ),
        .param_w_h4             (param_w_h4             ),
        .param_bias             (param_bias             ),
        // 
        .conv_rslt_act          (conv_rslt_act          ),
        .conv_rslt_act_vld      (conv_rslt_act_vld      )
);


pool_layer      pool_layer_inst(
        // system signals
        .sclk                   (cmos_16bit_clk                   ),
        .s_rst_n                (rst_n                ),
        //
        .act_data               (conv_rslt_act          ),
        .act_data_vld           (conv_rslt_act_vld      ),
        .cal_start              (cal_start              ),
        //
        .pool_data              (pool_data              ),
        .pool_data_vld          (pool_data_vld          ),
        .active_video           (active_video           ),
        .vid_hsync              (vid_hsync              ),
        .vid_ce                 (vid_ce                 )
);
*/
//The video output timing generator and generate a frame read data request
wire out_de;
syn_gen syn_gen_inst
(                                   
    .I_pxl_clk   (video_clk       ),//9Mhz    //32Mhz    //40MHz      //65MHz      //74.25MHz    //148.5
    .I_rst_n     (rst_n           ),//480x272 //800x480  //800x600    //1024x768   //1280x720    //1920x1080    
    .I_h_total   (16'd525         ),//16'd525 //16'd1056 // 16'd1056  // 16'd1344  // 16'd1650   // 16'd2200  
    .I_h_sync    (16'd41          ),//16'd41  //16'd128  // 16'd128   // 16'd136   // 16'd40     // 16'd44   
    .I_h_bporch  (16'd2           ),//16'd2   //16'd88   // 16'd88    // 16'd160   // 16'd220    // 16'd148   
    .I_h_res     (16'd480         ),//16'd480 //16'd800  // 16'd800   // 16'd1024  // 16'd1280   // 16'd1920  
    .I_v_total   (16'd284         ),//16'd284 //16'd505  // 16'd628   // 16'd806   // 16'd750    // 16'd1125   
    .I_v_sync    (16'd10          ),//16'd10  //16'd3    // 16'd4     // 16'd6     // 16'd5      // 16'd5      
    .I_v_bporch  (16'd2           ),//16'd2   //16'd21   // 16'd23    // 16'd29    // 16'd20     // 16'd36      
    .I_v_res     (16'd272         ),//16'd272 //16'd480  // 16'd600   // 16'd768   // 16'd720    // 16'd1080   
    .I_rd_hres   (16'd480         ),
    .I_rd_vres   (16'd272         ),
    .I_hs_pol    (1'b1            ),//HS polarity , 0:负极性，1：正极性
    .I_vs_pol    (1'b1            ),//VS polarity , 0:负极性，1：正极性
    .O_rden      (syn_off0_re     ),
    .O_de        (out_de          ),   
    .O_hs        (syn_off0_hs     ),
    .O_vs        (syn_off0_vs     )
);

Video_Frame_Buffer_Top Video_Frame_Buffer_Top_inst
( 
    .I_rst_n              (init_calib_complete ),//rst_n            ),
    .I_dma_clk            (dma_clk          ),   //sram_clk         ),
`ifdef USE_THREE_FRAME_BUFFER 
    .I_wr_halt            (1'd0             ), //1:halt,  0:no halt
    .I_rd_halt            (1'd0             ), //1:halt,  0:no halt
`endif
    // video data input             
    .I_vin0_clk           (cmos_16bit_clk   ),
    .I_vin0_vs_n          (~cmos_vsync      ),//只接收负极性  //~vsync
    .I_vin0_de            (cmos_16bit_wr    ),
    .I_vin0_data          (video_data_in),//灰度{img_y[7:3],img_y[7:2],img_y[7:3]}  二值化vid_data
    .O_vin0_fifo_full     (                 ),
    // video data output            
    .I_vout0_clk          (video_clk        ),
    .I_vout0_vs_n         (~syn_off0_vs     ),//只接收负极性
    .I_vout0_de           (syn_off0_re      ),
    .O_vout0_den          (off0_syn_de      ),
    .O_vout0_data         (off0_syn_data    ),
    .O_vout0_fifo_empty   (                 ),
    // ddr write request
    .I_cmd_ready          (cmd_ready          ),
    .O_cmd                (cmd                ),//0:write;  1:read
    .O_cmd_en             (cmd_en             ),
    .O_app_burst_number   (app_burst_number   ),
    .O_addr               (addr               ),//[ADDR_WIDTH-1:0]
    .I_wr_data_rdy        (wr_data_rdy        ),
    .O_wr_data_en         (wr_data_en         ),//
    .O_wr_data_end        (wr_data_end        ),//
    .O_wr_data            (wr_data            ),//[DATA_WIDTH-1:0]
    .O_wr_data_mask       (wr_data_mask       ),
    .I_rd_data_valid      (rd_data_valid      ),
    .I_rd_data_end        (rd_data_end        ),//unused 
    .I_rd_data            (rd_data            ),//[DATA_WIDTH-1:0]
    .I_init_calib_complete(init_calib_complete)
); 


localparam N = 7; //delay N clocks
                          
reg  [N-1:0]  Pout_hs_dn   ;
reg  [N-1:0]  Pout_vs_dn   ;
reg  [N-1:0]  Pout_de_dn   ;

always@(posedge video_clk or negedge rst_n)
begin
    if(!rst_n)
        begin                          
            Pout_hs_dn  <= {N{1'b1}};
            Pout_vs_dn  <= {N{1'b1}}; 
            Pout_de_dn  <= {N{1'b0}}; 
        end
    else 
        begin                          
            Pout_hs_dn  <= {Pout_hs_dn[N-2:0],syn_off0_hs};
            Pout_vs_dn  <= {Pout_vs_dn[N-2:0],syn_off0_vs}; 
            Pout_de_dn  <= {Pout_de_dn[N-2:0],out_de}; 
        end
end

//0-9图像存储
rom_data_0 u_rom_data_0(
        .dout(dout_o_0), //output [0:0] dout
        .clk(video_clk), //input clk
        .oce(1'b0), //input oce
        .ce(1'b1), //input ce
        .reset(1'b0), //input reset
        .ad(address) //input [13:0] ad
    );
rom_data_1 u_rom_data_1(
        .dout(dout_o_1), //output [0:0] dout
        .clk(video_clk), //input clk
        .oce(1'b0), //input oce
        .ce(1'b1), //input ce
        .reset(1'b0), //input reset
        .ad(address) //input [13:0] ad
    );
rom_data_2 u_rom_data_2(
        .dout(dout_o_2), //output [0:0] dout
        .clk(video_clk), //input clk
        .oce(1'b0), //input oce
        .ce(1'b1), //input ce
        .reset(1'b0), //input reset
        .ad(address) //input [13:0] ad
    );
rom_data_3 u_rom_data_3(
        .dout(dout_o_3), //output [0:0] dout
        .clk(video_clk), //input clk
        .oce(1'b0), //input oce
        .ce(1'b1), //input ce
        .reset(1'b0), //input reset
        .ad(address) //input [13:0] ad
    );
rom_data_4 u_rom_data_4(
        .dout(dout_o_4), //output [0:0] dout
        .clk(video_clk), //input clk
        .oce(1'b0), //input oce
        .ce(1'b1), //input ce
        .reset(1'b0), //input reset
        .ad(address) //input [13:0] ad
    );
rom_data_5 u_rom_data_5(
        .dout(dout_o_5), //output [0:0] dout
        .clk(video_clk), //input clk
        .oce(1'b0), //input oce
        .ce(1'b1), //input ce
        .reset(1'b0), //input reset
        .ad(address) //input [13:0] ad
    );
rom_data_6 u_rom_data_6(
        .dout(dout_o_6), //output [0:0] dout
        .clk(video_clk), //input clk
        .oce(1'b0), //input oce
        .ce(1'b1), //input ce
        .reset(1'b0), //input reset
        .ad(address) //input [13:0] ad
    );
rom_data_7 u_rom_data_7(
        .dout(dout_o_7), //output [0:0] dout
        .clk(video_clk), //input clk
        .oce(1'b0), //input oce
        .ce(1'b1), //input ce
        .reset(1'b0), //input reset
        .ad(address) //input [13:0] ad
    );
rom_data_8 u_rom_data_8(
        .dout(dout_o_8), //output [0:0] dout
        .clk(video_clk), //input clk
        .oce(1'b0), //input oce
        .ce(1'b1), //input ce
        .reset(1'b0), //input reset
        .ad(address) //input [13:0] ad
    );
rom_data_9 u_rom_data_9(
        .dout(dout_o_9), //output [0:0] dout
        .clk(video_clk), //input clk
        .oce(1'b0), //input oce
        .ce(1'b1), //input ce
        .reset(1'b0), //input reset
        .ad(address) //input [13:0] ad
    );
wire [13:0] ad_0;
wire [13:0] ad_1;
wire [13:0] ad_2;
wire [13:0] ad_3;
wire [13:0] ad_4;
wire [13:0] ad_5;
wire [13:0] ad_6;
wire [13:0] ad_7;
wire [13:0] ad_8;
wire [13:0] ad_9;

wire [13:0] address;
/*
always@(posedge video_clk or negedge rst_n)
begin
    if(!rst_n)
        begin                          
            address_rom  <= ad_0;
        end
    else 
        begin                          
            case(digit[3:0])
                  4'd0:address_rom <= ad_0; //0
                  4'd1:address_rom <= ad_1; //1
                  4'd2:address_rom <= ad_2; //2
                  4'd3:address_rom <= ad_3; //3
                  4'd4:address_rom <= ad_4; //4
                  4'd5:address_rom <= ad_5; //5
                  4'd6:address_rom <= ad_6; //6
                  4'd7:address_rom <= ad_7; //7
                  4'd8:address_rom <= ad_8; //8
                  4'd9:address_rom <= ad_9; //9
                  default:address_rom <= ad_0;
			endcase
        end
end
*/

//存储0-9图像数据显示时序
out_data u_out_data(
        // system signals
        .sclk(video_clk)                    ,       
        .s_rst_n(rst_n)                 ,       
        // VGA 
        .vga_vsync(Pout_vs_dn[4])               ,       
        .vga_hsync(Pout_hs_dn[4])               ,       
     .active_video(Pout_de_dn[4])            ,       
        // ROM
        .rom_sel(digit[15:0])                 ,
        .rd_addr(address)                 ,       
        .rom0_data(dout_o_0)               ,       // Zero
        .rom1_data(dout_o_1)               ,       // Zero
        .rom2_data(dout_o_2)               ,       // Zero
        .rom3_data(dout_o_3)               ,       // Zero
        .rom4_data(dout_o_4)               ,       // Zero
        .rom5_data(dout_o_5)              ,       // Zero
        .rom6_data(dout_o_6)               ,       // Zero
        .rom7_data(dout_o_7)               ,       // Zero
        .rom8_data(dout_o_8)               ,       // Zero
        .rom9_data(dout_o_9)               ,       // Zero
        // 
        .rgb_data_i(off0_syn_data)              ,    // VDMA   
        .rgb_data_o(video_data_out)                 //     
);
wire [15:0]video_data_out;
assign {lcd_b,lcd_g,lcd_r}=(key_in==0)?off0_syn_data:video_data_out;







wire [15:0] post_rgb;


    //assign {lcd_b,lcd_g,lcd_r}    = off0_syn_de ? off0_syn_data[15:0] : 16'h0000;//{r,g,b}
    assign lcd_vs      			  = Pout_vs_dn[4];//syn_off0_vs;
    assign lcd_hs      			  = Pout_hs_dn[4];//syn_off0_hs;
    assign lcd_de      			  = Pout_de_dn[4];//off0_syn_de;
    assign lcd_dclk    			  = video_clk;//video_clk_phs;





DDR3MI DDR3_Memory_Interface_Top_inst 
(
    .clk                (video_clk          ),
    .memory_clk         (memory_clk         ),
    .pll_lock           (pll_lock           ),
    .rst_n              (rst_n              ), //rst_n
    .app_burst_number   (app_burst_number   ),
    .cmd_ready          (cmd_ready          ),
    .cmd                (cmd                ),
    .cmd_en             (cmd_en             ),
    .addr               (addr               ),
    .wr_data_rdy        (wr_data_rdy        ),
    .wr_data            (wr_data            ),
    .wr_data_en         (wr_data_en         ),
    .wr_data_end        (wr_data_end        ),
    .wr_data_mask       (wr_data_mask       ),
    .rd_data            (rd_data            ),
    .rd_data_valid      (rd_data_valid      ),
    .rd_data_end        (rd_data_end        ),
    .sr_req             (1'b0               ),
    .ref_req            (1'b0               ),
    .sr_ack             (                   ),
    .ref_ack            (                   ),
    .init_calib_complete(init_calib_complete),
    .clk_out            (dma_clk            ),
    .burst              (1'b1               ),
    // mem interface
    .ddr_rst            (                 ),
    .O_ddr_addr         (ddr_addr         ),
    .O_ddr_ba           (ddr_bank         ),
    .O_ddr_cs_n         (ddr_cs         ),
    .O_ddr_ras_n        (ddr_ras        ),
    .O_ddr_cas_n        (ddr_cas        ),
    .O_ddr_we_n         (ddr_we         ),
    .O_ddr_clk          (ddr_ck          ),
    .O_ddr_clk_n        (ddr_ck_n        ),
    .O_ddr_cke          (ddr_cke          ),
    .O_ddr_odt          (ddr_odt          ),
    .O_ddr_reset_n      (ddr_reset_n      ),
    .O_ddr_dqm          (ddr_dm           ),
    .IO_ddr_dq          (ddr_dq           ),
    .IO_ddr_dqs         (ddr_dqs          ),
    .IO_ddr_dqs_n       (ddr_dqs_n        )
);

endmodule