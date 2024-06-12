module vip(
      //module clock
      input           clk            ,   // 时钟信号
     input           rst_n          ,   // 复位信号(低有效)

     //图像处理前的数据接口
     input           pre_frame_vsync,
      input           pre_frame_hsync,
      input           pre_frame_de   ,
     input    [15:0] pre_rgb        ,
     input    [10:0] xpos           ,
     input    [10:0] ypos           ,
 
     //图像处理后的数据接口
     output          post_frame_vsync,  // 场同步信号
     output          post_frame_hsync,  // 行同步信号
     output          post_frame_de  ,  // 数据输入使能
     output   [15:0] post_rgb           // RGB565颜色数据
);
 
 //wire define
 wire   [ 7:0]         img_y;
 
 //*****************************************************
 //**                    main code
//*****************************************************
 
 assign  post_rgb = {img_y[7:3],img_y[7:2],img_y[7:3]};
 
 //RGB转YCbCr模块
 rgb2ycbcr u_rgb2ycbcr(
     //module clock
     .clk             (clk    ),          // 时钟信号
     .rst_n           (rst_n  ),            // 复位信号(低有效)
    //图像处理前的数据接口
     .pre_frame_vsync (pre_frame_vsync),    // vsync信号
     .pre_frame_hsync (pre_frame_hsync),    // href信号
     .pre_frame_de    (pre_frame_de   ),    // data enable信号
    .img_red         (pre_rgb[15:11] ),
    .img_green       (pre_rgb[10:5 ] ),
     .img_blue        (pre_rgb[ 4:0 ] ),
     //图像处理后的数据接口
     .post_frame_vsync(post_frame_vsync),   // vsync信号
     .post_frame_hsync(post_frame_hsync),   // href信号
     .post_frame_de   (post_frame_de),      // data enable信号
    .img_y           (img_y),
    .img_cb          (),
     .img_cr          ()
 );
 
endmodule
