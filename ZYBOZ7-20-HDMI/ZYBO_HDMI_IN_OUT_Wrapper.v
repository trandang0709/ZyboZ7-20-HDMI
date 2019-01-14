//`timescale 1ns / 1ps
`timescale 1 ps / 1 ps

//////////////////////////////////////////////////////////////////////////////////
// Company: HsKA
// Engineer: Tran Dinh Hai Dang
// 
// Create Date: 06/28/2018 12:29:40 PM
// Design Name: Zybo_HDMI_IN_OUT
// Module Name: design_1_Wrapper
// Project Name: Zybo_HDMI_IN_OUT
// Target Devices: Zybo
// Tool Versions: Vivado2016.4
// Description: This program is for input and output of HDMI 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.

//--------------------------------------------------------------------------------

module ZYBO_HDMI_IN_OUT_Wrapper
   (clk,
    ddc_scl_io,
    ddc_sda_io,
    hdmi_clk_n,
    hdmi_clk_p,
    hdmi_d_n,
    hdmi_d_p,
    hdmi_hpd,

   hdmi_clk_n_out,
   hdmi_clk_p_out, 
   hdmi_d_n_out,
   hdmi_d_p_out,

    sw1,
    sw2,
    sw3,
    sw4,
    led
    );
  input clk;
  inout ddc_scl_io;
  inout ddc_sda_io;
  input hdmi_clk_n;
  input hdmi_clk_p;
  input [2:0]hdmi_d_n;
  input [2:0]hdmi_d_p;
  
  output [0:0]hdmi_hpd;

  output hdmi_clk_n_out;
  output hdmi_clk_p_out; 
  output [2:0]hdmi_d_n_out;
  output [2:0]hdmi_d_p_out;

  input sw1;
  input sw2;
  input sw3;
  input sw4;
  output [3:0]led;
  
  wire clk;
  wire ddc_scl_i;
  wire ddc_scl_io;
  wire ddc_scl_o;
  wire ddc_scl_t;
  wire ddc_sda_i;
  wire ddc_sda_io;
  wire ddc_sda_o;
  wire ddc_sda_t;
  wire hdmi_clk_n;
  wire hdmi_clk_p;
  wire [2:0]hdmi_d_n;
  wire [2:0]hdmi_d_p;
  wire [0:0]hdmi_hpd;


  wire [2:0]hdmi_d_n_out;
  wire [2:0]hdmi_d_p_out; 
  wire [0:0]hdmi_hpd_out;
  wire sw1;
  wire sw2;
  wire sw3;
  wire sw4;
  wire [3:0]led;

IOBUF ddc_scl_iobuf
       (.I(ddc_scl_o),
        .IO(ddc_scl_io),
        .O(ddc_scl_i),
        .T(ddc_scl_t));
IOBUF ddc_sda_iobuf
       (.I(ddc_sda_o),
        .IO(ddc_sda_io),
        .O(ddc_sda_i),
        .T(ddc_sda_t));
        
ZYBO_HDMI_IN_OUT design_1_i
       (.DDC_scl_i(ddc_scl_i),
        .DDC_scl_o(ddc_scl_o),
        .DDC_scl_t(ddc_scl_t),
        .DDC_sda_i(ddc_sda_i),
        .DDC_sda_o(ddc_sda_o),
        .DDC_sda_t(ddc_sda_t),
        .clk(clk),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_d_n(hdmi_d_n),
        .hdmi_d_p(hdmi_d_p),
        .hdmi_hpd(hdmi_hpd),


        .hdmi_clk_n_out(hdmi_clk_n_out),
        .hdmi_clk_p_out(hdmi_clk_p_out),
        .hdmi_d_n_out(hdmi_d_n_out),
        .hdmi_d_p_out(hdmi_d_p_out),

        .sw1(sw1),
        .sw2(sw2),
        .sw3(sw3),
        .sw4(sw4),
        .led(led)
        );
          
endmodule
