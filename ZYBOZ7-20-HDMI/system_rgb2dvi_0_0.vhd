-- (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: digilentinc.com:ip:rgb2dvi:1.4
-- IP Revision: 7

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY system_rgb2dvi_0_0 IS
  PORT (
    TMDS_Clk_p_out : OUT STD_LOGIC;
    TMDS_Clk_n_out : OUT STD_LOGIC;
    TMDS_Data_p_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    TMDS_Data_n_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    aRst   : IN STD_LOGIC;
    aRst_n : IN STD_LOGIC;
    vid_pData : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    vid_pVDE : IN STD_LOGIC;
    vid_pHSync : IN STD_LOGIC;
    vid_pVSync : IN STD_LOGIC;
    PixelClk : IN STD_LOGIC;
    SerialClk : IN STD_LOGIC;
    sw1        : IN STD_LOGIC;
    sw2        : IN STD_LOGIC;
    sw3        : IN STD_LOGIC;
    sw4       : IN STD_LOGIC;
    led       : OUT STD_LOGIC_VECTOR (3 downto 0)
  );
END system_rgb2dvi_0_0;

ARCHITECTURE system_rgb2dvi_0_0_arch OF system_rgb2dvi_0_0 IS

  COMPONENT rgb2dvi IS
    GENERIC (
      kGenerateSerialClk : BOOLEAN;
      kClkPrimitive : STRING;
      kRstActiveHigh : BOOLEAN;
      kClkRange : INTEGER;
      kD0Swap : BOOLEAN;
      kD1Swap : BOOLEAN;
      kD2Swap : BOOLEAN;
      kClkSwap : BOOLEAN
    );
    PORT (
      TMDS_Clk_p_out : OUT STD_LOGIC;
      TMDS_Clk_n_out : OUT STD_LOGIC;
      TMDS_Data_p_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      TMDS_Data_n_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      aRst : IN STD_LOGIC;
      aRst_n : IN STD_LOGIC;
      vid_pData : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      vid_pVDE : IN STD_LOGIC;
      vid_pHSync : IN STD_LOGIC;
      vid_pVSync : IN STD_LOGIC;
      PixelClk : IN STD_LOGIC;
      SerialClk : IN STD_LOGIC;
      sw1        : IN STD_LOGIC;
      sw2        : IN STD_LOGIC;
      sw3        : IN STD_LOGIC;
      sw4        : IN STD_LOGIC;
      led       : OUT STD_LOGIC_VECTOR(3 downto 0)
    );
  END COMPONENT rgb2dvi;
 
BEGIN
  U0 : rgb2dvi
    GENERIC MAP (
      kGenerateSerialClk => false, -- True, if an internal Clk for deserialize should be generate,
                                   -- The generated SerialClk is based on PixelClk only, so
                                   -- no Input of SerialClk is needed.
                                   -- If this is false, then an input of SerialClk is needed for
                                   -- deserialize the TMDS signal.
      kClkPrimitive => "PLL",
      kRstActiveHigh => false,
      kClkRange => 2,
      kD0Swap => false,
      kD1Swap => false,
      kD2Swap => false,
      kClkSwap => false
    )
    PORT MAP (
      TMDS_Clk_p_out => TMDS_Clk_p_out,
      TMDS_Clk_n_out => TMDS_Clk_n_out,
      TMDS_Data_p_out => TMDS_Data_p_out,
      TMDS_Data_n_out => TMDS_Data_n_out,
      aRst => '0',
      aRst_n => aRst_n,
      vid_pData => vid_pData,
      vid_pVDE => vid_pVDE,
      vid_pHSync => vid_pHSync,
      vid_pVSync => vid_pVSync,
      PixelClk => PixelClk,
      SerialClk => SerialClk,
      sw1        => sw1,
      sw2        => sw2,
      sw3        => sw3,
      sw4        => sw4,
      led        =>  led      
    );
END system_rgb2dvi_0_0_arch;
