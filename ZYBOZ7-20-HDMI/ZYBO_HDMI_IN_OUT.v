//`timescale 1ns / 1ps

`timescale 1 ps / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HsKA
// Engineer: Tran Dinh Hai Dang
// 
// Create Date: 06/28/2018 12:11:44 PM
// Design Name: Zybo Z7 HDMI_IN_HDMI_OUT_RE-ENGINEER
// Module Name: Zybo Z7 HDMI_IN_HDMI_OUT_RE-ENGINEER
// Project Name: Zybo Z7 HDMI_IN_HDMI_OUT_RE-ENGINEER
// Target Devices: Zybo Z7
// Tool Versions: Vivado 2016.4
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ZYBO_HDMI_IN_OUT
   (DDC_scl_i,
    DDC_scl_o,
    DDC_scl_t,
    DDC_sda_i,
    DDC_sda_o,
    DDC_sda_t,
    clk,
    hdmi_clk_n, //input HDMI CLK n
    hdmi_clk_p, //input HDMI CLK p
    hdmi_d_n,   //input HDMI data n
    hdmi_d_p,   //input HDMI data p
    hdmi_hpd,
    
    hdmi_clk_n_out, //output HDMI CLK n
    hdmi_clk_p_out, //output HDMI CLK p
    hdmi_d_n_out,//output HDMI data n
    hdmi_d_p_out,//output HDMI data p

    sw1,
    sw2,
    sw3,
    sw4,
    led
    );
  input DDC_scl_i;
  output DDC_scl_o;
  output DDC_scl_t;
  input DDC_sda_i;
  output DDC_sda_o;
  output DDC_sda_t;
  input clk;
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


  wire GND_2;
  wire TMDS_Clk_n_1;
  wire TMDS_Clk_p_1;
  wire [2:0]TMDS_Data_n_1;
  wire [2:0]TMDS_Data_p_1;
  
  wire TMDS_Clk_n_1_out;
  wire TMDS_Clk_p_1_out;
  wire [2:0]TMDS_Data_n_1_out;
  wire [2:0]TMDS_Data_p_1_out;
 
  
  wire clk_1;
  wire clk_wiz_0_clk_out1;
  wire dvi2rgb_0_DDC_SCL_I;
  wire dvi2rgb_0_DDC_SCL_O;
  wire dvi2rgb_0_DDC_SCL_T;
  wire dvi2rgb_0_DDC_SDA_I;
  wire dvi2rgb_0_DDC_SDA_O;
  wire dvi2rgb_0_DDC_SDA_T;
  wire dvi2rgb_0_PixelClk;
  wire dvi2rgb_0_RGB_ACTIVE_VIDEO;
  wire [23:0]dvi2rgb_0_RGB_DATA;
  wire dvi2rgb_0_RGB_HSYNC;
  wire dvi2rgb_0_RGB_VSYNC;
  wire dvi2rgb_0_SerialClk;
  wire dvi2rgb_0_aPixelClkLckd;
  
  wire rgb_processing_0_PixelClk;
  wire rgb_processing_0_RGB_ACTIVE_VIDEO;
  wire [23:0]rgb_processing_0_RGB_DATA;
  wire rgb_processing_0_RGB_HSYNC;
  wire rgb_processing_0_RGB_VSYNC;
  wire rgb_processing_0_SerialClk;
  
  wire [0:0]xlconstant_0_dout;
  wire [0:0]xlconstant_1_dout;
  wire rgb2vga_0_sw1;
  wire rgb2vga_0_sw2;
  wire rgb2vga_0_sw3;
  wire rgb2vga_0_sw4;
  wire [3:0]rgb2vga_0_led;
  
  assign DDC_scl_o = dvi2rgb_0_DDC_SCL_O;
  assign DDC_scl_t = dvi2rgb_0_DDC_SCL_T;
  assign DDC_sda_o = dvi2rgb_0_DDC_SDA_O;
  assign DDC_sda_t = dvi2rgb_0_DDC_SDA_T;
  assign TMDS_Clk_n_1 = hdmi_clk_n;
  assign TMDS_Clk_p_1 = hdmi_clk_p;
  assign TMDS_Data_n_1 = hdmi_d_n[2:0];
  assign TMDS_Data_p_1 = hdmi_d_p[2:0];
  
  assign TMDS_Clk_n_1_out = hdmi_clk_n_out;
  assign TMDS_Clk_p_1_out = hdmi_clk_p_out;
  assign TMDS_Data_n_1_out = hdmi_d_n_out[2:0];
  assign TMDS_Data_p_1_out = hdmi_d_p_out[2:0];
  
  assign clk_1 = clk;
  assign dvi2rgb_0_DDC_SCL_I = DDC_scl_i;
  assign dvi2rgb_0_DDC_SDA_I = DDC_sda_i;
  assign hdmi_hpd[0] = xlconstant_1_dout;

  assign sw1 = rgb2vga_0_sw1;
  assign sw2 = rgb2vga_0_sw2;
  assign sw3 = rgb2vga_0_sw3;
  assign sw4 = rgb2vga_0_sw4;
  assign led = rgb2vga_0_led;


design_1_xlconstant_0_1 GND
       (.dout(xlconstant_0_dout));
GND GND_1
       (.G(GND_2));
design_1_xlconstant_1_0 VDD
       (.dout(xlconstant_1_dout));
clk_wiz_0 clk_wiz_0
       (.clk_in1(clk_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .reset(GND_2));
        
        
//Module for input and output of HDMI_IN_OUT_Re_Engineer
//HDMI_IN_OUT_Re_Engineer HDMI_IN_OUT_Re_Engineer_X
//(
////signal of I2C for giving the supported EDID of the Zybo
//        .SCL_I(dvi2rgb_0_DDC_SCL_I),
//        .SCL_O(dvi2rgb_0_DDC_SCL_O),
//        .SCL_T(dvi2rgb_0_DDC_SCL_T),
//        .SDA_I(dvi2rgb_0_DDC_SDA_I),
//        .SDA_O(dvi2rgb_0_DDC_SDA_O),
//        .SDA_T(dvi2rgb_0_DDC_SDA_T),
        
//        //Read in HDMI signal
//        .PixelClk(dvi2rgb_0_PixelClk),
//        .SerialClk(dvi2rgb_0_SerialClk),
//        .aPixelClkLckd(dvi2rgb_0_aPixelClkLckd),
//        .RefClk(clk_wiz_0_clk_out1),
//        .TMDS_Clk_n(TMDS_Clk_n_1),
//        .TMDS_Clk_p(TMDS_Clk_p_1),
//        .TMDS_Data_n(TMDS_Data_n_1),
//        .TMDS_Data_p(TMDS_Data_p_1),
        
//        .aRst(GND_2),
//        .pRst(GND_2),
        
//        //The read in raw RGB data                     
//        .vid_pData(dvi2rgb_0_RGB_DATA),
//        .vid_pHSync(dvi2rgb_0_RGB_HSYNC),
//        .vid_pVDE(dvi2rgb_0_RGB_ACTIVE_VIDEO),
//        .vid_pVSync(dvi2rgb_0_RGB_VSYNC),
        
//////         write HMDI signal to the HDMI ports
//       .TMDS_Clk_p_out(TMDS_Clk_p_1_out),
//       .TMDS_Clk_n_out(TMDS_Clk_n_1_out),
//       .TMDS_Data_p_out(TMDS_Data_p_1_out),
//       .TMDS_Data_n_out(TMDS_Data_n_1_out),
//       .aRst_n(xlconstant_1_dout),
       

//       ////Switches for testing
//       ////enable if you need the switch to test some function of the system
////        .sw1(rgb2vga_0_sw1),
////        .sw2(rgb2vga_0_sw2),
////        .sw3(rgb2vga_0_sw3),
////        .sw4(rgb2vga_0_sw4),
                          
//       ////LED for testing the condition of the block
//       ////enable if you need the LED to test the function of the block
//        .led(led)        

//);

        
////module for read the HDMI input
system_dvi2rgb_0_0 dvi2rgb_0 
       (
       //signal of I2C for giving the supported EDID of the Zybo
        .SCL_I(dvi2rgb_0_DDC_SCL_I),
        .SCL_O(dvi2rgb_0_DDC_SCL_O),
        .SCL_T(dvi2rgb_0_DDC_SCL_T),
        .SDA_I(dvi2rgb_0_DDC_SDA_I),
        .SDA_O(dvi2rgb_0_DDC_SDA_O),
        .SDA_T(dvi2rgb_0_DDC_SDA_T),
        
        //Read in HDMI signal
        .PixelClk(dvi2rgb_0_PixelClk),
        .SerialClk(dvi2rgb_0_SerialClk),
        .aPixelClkLckd(dvi2rgb_0_aPixelClkLckd),
        .RefClk(clk_wiz_0_clk_out1),
        .TMDS_Clk_n(TMDS_Clk_n_1),
        .TMDS_Clk_p(TMDS_Clk_p_1),
        .TMDS_Data_n(TMDS_Data_n_1),
        .TMDS_Data_p(TMDS_Data_p_1),
        
        .aRst(GND_2),
        .pRst(GND_2),
        
        //The read in raw RGB data                     
        .vid_pData(dvi2rgb_0_RGB_DATA),
        .vid_pHSync(dvi2rgb_0_RGB_HSYNC),
        .vid_pVDE(dvi2rgb_0_RGB_ACTIVE_VIDEO),
        .vid_pVSync(dvi2rgb_0_RGB_VSYNC)
        

        );
        
//////module for processing the RGB signal     
system_rgb_processing_0_0 rgb_processing
        (
        //signal comming from the DVI2RGB block
        .vid_pData(dvi2rgb_0_RGB_DATA),
        .vid_pVDE(dvi2rgb_0_RGB_ACTIVE_VIDEO),
        .vid_pHSync(dvi2rgb_0_RGB_HSYNC),
        .vid_pVSync(dvi2rgb_0_RGB_VSYNC),
        .PixelClk(dvi2rgb_0_PixelClk),
        .SerialClk(dvi2rgb_0_SerialClk),
        
        //signal after processing
        .vid_pData_out(rgb_processing_0_RGB_DATA),
        .vid_pVDE_out(rgb_processing_0_RGB_ACTIVE_VIDEO),
        .vid_pHSync_out(rgb_processing_0_RGB_HSYNC),
        .vid_pVSync_out(rgb_processing_0_RGB_VSYNC),
        .PixelClk_out(rgb_processing_0_PixelClk),
        .SerialClk_out(rgb_processing_0_SerialClk),
        
        //Switches for choosing the kind of manipulation needed
        .sw1(rgb2vga_0_sw1),
        .sw2(rgb2vga_0_sw2),
        .sw3(rgb2vga_0_sw3),
        .sw4(rgb2vga_0_sw4)                                   
        );
 
////module for write the HDMI output       
system_rgb2dvi_0_0 rgb2dvi 
       (
        //write HMDI signal to the HDMI ports
        .TMDS_Clk_p_out(TMDS_Clk_p_1_out),
        .TMDS_Clk_n_out(TMDS_Clk_n_1_out),
        .TMDS_Data_p_out(TMDS_Data_p_1_out),
        .TMDS_Data_n_out(TMDS_Data_n_1_out),
        
        .aRst(GND_2),
        .aRst_n(xlconstant_1_dout),
        
//        ////Data coming from the DVI2RGB block 
//        ////enable the below to skip the processing block and
//        ////output directly from DVI2RGB
////        .vid_pData(dvi2rgb_0_RGB_DATA),
////        .vid_pVDE(dvi2rgb_0_RGB_ACTIVE_VIDEO),
////        .vid_pHSync(dvi2rgb_0_RGB_HSYNC),
////        .vid_pVSync(dvi2rgb_0_RGB_VSYNC),
////        .PixelClk(dvi2rgb_0_PixelClk),
////        .SerialClk(dvi2rgb_0_SerialClk)
        
////      Data coming from the RGB_processing block 
       //enable to take signal from RGB_processing block
        .vid_pData(rgb_processing_0_RGB_DATA),
        .vid_pVDE(rgb_processing_0_RGB_ACTIVE_VIDEO),
        .vid_pHSync(rgb_processing_0_RGB_HSYNC),
        .vid_pVSync(rgb_processing_0_RGB_VSYNC),
        .PixelClk(rgb_processing_0_PixelClk),
        .SerialClk(rgb_processing_0_SerialClk)

        ////Switches for testing
        ////enable if you need the switch to test some function of the system
//        .sw1(rgb2vga_0_sw1),
//        .sw2(rgb2vga_0_sw2),
//        .sw3(rgb2vga_0_sw3),
//        .sw4(rgb2vga_0_sw4),
                           
        ////LED for testing the condition of the block
        ////enable if you need the LED to test the function of the block
//        .led(rgb2vga_0_led)
        );


endmodule