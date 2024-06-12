//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Wed May 08 23:16:56 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    mult_gen_0 your_instance_name(
        .dout(dout_o), //output [25:0] dout
        .a(a_i), //input [7:0] a
        .b(b_i), //input [17:0] b
        .ce(ce_i), //input ce
        .clk(clk_i), //input clk
        .reset(reset_i) //input reset
    );

//--------Copy end-------------------
