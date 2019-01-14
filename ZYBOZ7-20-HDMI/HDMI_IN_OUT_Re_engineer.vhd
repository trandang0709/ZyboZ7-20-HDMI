----------------------------------------------------------------------------------
-- Company: HsKA
-- Engineer: Tran Dinh Hai Dang
-- 
-- Create Date: 08/13/2018 12:56:46 PM
-- Design Name: HDMI Input Re-engineer
-- Module Name: HDMI_in - Behavioral
-- Project Name: HDMI_IN_OUT_Re-Engineer
-- Target Devices: ZyboZ7
-- Tool Versions: 2016.4
-- Description: This module is a re-engineer project from the DVI2RGB module of Xilinx
--              The root modle project is from the dvi2rgb IP core and listed in the below.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- File: dvi2rgb.vhd
-- Author: Elod Gyorgy
-- Original Project: HDMI input on 7-series Xilinx FPGA
-- Date: 24 July 2015
--
-------------------------------------------------------------------------------
-- (c) 2015 Copyright Digilent Incorporated
-- All Rights Reserved
-- 
-- This program is free software; distributed under the terms of BSD 3-clause 
-- license ("Revised BSD License", "New BSD License", or "Modified BSD License")
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
--    of its contributors may be used to endorse or promote products derived
--    from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
--
-- Purpose:
-- This module connects to a top level DVI 1.0 sink interface comprised of three
-- TMDS data channels and one TMDS clock channel. It includes the necessary
-- clock infrastructure, deserialization, phase alignment, channel deskew and
-- decode logic. It outputs 24-bit RGB video data along with pixel clock and
-- synchronization signals. 
--  
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.DVI_Constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity HDMI_IN_OUT_Re_Engineer is
   Generic (
      kEmulateDDC : boolean := true; --will emulate a DDC EEPROM with basic EDID, if set to yes 
      kRstActiveHigh : boolean := true; --true, if active-high; false, if active-low
      kAddBUFG : boolean := true ; --true, if PixelClk should be re-buffered with BUFG 
      kAddBUFG_serial : boolean := false; --true, if SerialClk should be re-buffered with BUFG, should be interlock with kAddBUFG;
                                          -- If both KAddBUFG and kAddBUFG_serial are true, the kAddBUFG_serial will be chosen
      kClkRange : natural := 1;  -- MULT_F = kClkRange*5 (choose >=120MHz=1, >=60MHz=2, >=40MHz=3)
      kEdidFileName : string := "EDID_1920_1080.txt";  -- Select EDID file to use
      -- 7-series specific
      kIDLY_TapValuePs : natural := 78; --delay in ps per tap
      kIDLY_TapWidth : natural := 5); --number of bits for IDELAYE2 tap counter   
   Port (
      -- DVI 1.0 TMDS video interface
      TMDS_Clk_p : in std_logic;
      TMDS_Clk_n : in std_logic;
      TMDS_Data_p : in std_logic_vector(2 downto 0);
      TMDS_Data_n : in std_logic_vector(2 downto 0);
      
      TMDS_CLK_p_out: out std_logic;
      TMDS_CLK_n_out: out std_logic;
      TMDS_data_p_out: out std_logic_vector(2 downto 0);
      TMDS_data_n_out: out std_logic_vector(2 downto 0);
      
      -- Auxiliary signals 
      RefClk : in std_logic; --200 MHz reference clock for IDELAYCTRL, reset, lock monitoring etc.
      aRst : in std_logic; --asynchronous reset; must be reset when RefClk is not within spec
      aRst_n : in std_logic; --asynchronous reset; must be reset when RefClk is not within spec
      
      -- Video out
      vid_pData : out std_logic_vector(23 downto 0);
      vid_pVDE : out std_logic;
      vid_pHSync : out std_logic;
      vid_pVSync : out std_logic;
      
      PixelClk : out std_logic; --pixel-clock recovered from the DVI interface
      
      SerialClk : out std_logic; -- advanced use only; 5x PixelClk
      aPixelClkLckd : out std_logic; -- advanced use only; PixelClk and SerialClk stable
      
      -- Optional DDC port
      SDA_I : in std_logic;
      SDA_O : out std_logic;
      SDA_T : out std_logic;
      SCL_I : in std_logic;
      SCL_O : out std_logic; 
      SCL_T : out std_logic;
      
      pRst : in std_logic; -- synchronous reset; will restart locking procedure
      pRst_n : in std_logic; -- synchronous reset; will restart locking procedure
      
      --Led for debuggin  
      led:  out std_logic_vector (3 downto 0)
   );
end HDMI_IN_OUT_Re_Engineer;

architecture Behavioral of HDMI_IN_OUT_Re_Engineer is
signal TMDS_Clk: std_logic;
signal TMDS_Data: std_logic_vector(2 downto 0) := (others => '0');
signal TMDS_Clk_out: std_logic:= '0';
signal TMDS_data_out: std_logic_vector(2 downto 0) := (others => '0');

signal TMDS_data_Channel_0: std_logic_vector(9 downto 0) := (others=>'0');
signal TMDS_data_Channel_1: std_logic_vector(9 downto 0) := (others=>'0');
signal TMDS_data_Channel_2: std_logic_vector(9 downto 0) := (others=>'0');
signal count_in: integer range 0 to 16:= 0; -- counter for counting the sampling bit
signal count_out: integer range 0 to 16:= 0; -- counter for counting the sampling bit

signal clkfbout_hdmi_clk, CLK_OUT_10x_SerialClk, CLK_OUT_1X_PixelClk: std_logic := '0';
signal  SeialClk_counter: integer range 0 to 10 := 0; 
signal do_unused: std_logic_vector (15 downto 0):= (others => '0');

signal clkfboutb_unused,clkout0b_unused,clkout1_unused,clkout1b_unused,clkout2_unused,clkout2b_unused,clkout3_unused,
clkout3b_unused, clkout4_unused, clkout5_unused, clkout6_unused , drdy_unused, psdone_unused,clkinstopped_unused,clkfbstopped_unused :std_logic;

constant kDlyRstDelay : natural := 32;
signal aDlyLckd, rDlyRst, rBUFR_Rst, rLockLostRst : std_logic;
signal rDlyRstCnt : natural range 0 to kDlyRstDelay - 1 := kDlyRstDelay - 1;
signal  aLocked: std_logic;
signal LOCKED_int, rRdyRst : std_logic;
signal aMMCM_Locked, rMMCM_Locked_ms, rMMCM_Locked, rMMCM_LckdFallingFlag, rMMCM_LckdRisingFlag : std_logic;
signal rMMCM_Reset_q : std_logic_vector(1 downto 0);
signal rMMCM_Locked_q : std_logic_vector(1 downto 0);

signal counter_test1: integer range 0 to 2147483647 := 0;
signal counter_test2: integer range 0 to 2147483647 := 0;
signal counter_test3: integer range 0 to 2147483647 := 0;
signal counter_test4: integer range 0 to 2147483647 := 0;

begin
----------------------------------------------------------------------------------
-- Optional DDC EEPROM Display Data Channel - Bi-directional (DDC2B)
-- The EDID will be loaded from the file specified below in kInitFileName.
----------------------------------------------------------------------------------
GenerateDDC: if kEmulateDDC generate	
   DDC_EEPROM: entity work.EEPROM_8b
      generic map (
         kSampleClkFreqInMHz => 200,
         kSlaveAddress => b"1010000",
         kAddrBits => 7, -- 128 byte EDID 1.x data
         kWritable => false,
         kInitFileName => kEdidFileName) -- name of file containing init values
      port map(
         SampleClk => RefClk,
         sRst => '0',
         aSDA_I => SDA_I,
         aSDA_O => SDA_O,
         aSDA_T => SDA_T,
         aSCL_I => SCL_I,
         aSCL_O => SCL_O,
         aSCL_T => SCL_T);
end generate GenerateDDC;
   
InputBuffer_CLOCK: IBUFDS
   generic map (
      DIFF_TERM  => FALSE,
      IOSTANDARD => "TMDS_33")
   port map (
      I          => TMDS_Clk_p,
      IB         => TMDS_Clk_n,
      O          => TMDS_Clk);
InputBuffer_Channel2: IBUFDS
     generic map (
        DIFF_TERM  => FALSE,
        IOSTANDARD => "TMDS_33")
     port map (
        I          => TMDS_Data_p(2),
        IB         => TMDS_Data_n(2),
        O          => TMDS_Data(2));
InputBuffer_Channel1: IBUFDS
   generic map (
      DIFF_TERM  => FALSE,
      IOSTANDARD => "TMDS_33")
   port map (
      I          => TMDS_Data_p(1),
      IB         => TMDS_Data_n(1),
      O          => TMDS_Data(1));
InputBuffer_Channel0: IBUFDS
     generic map (
        DIFF_TERM  => FALSE,
        IOSTANDARD => "TMDS_33")
     port map (
        I          => TMDS_Data_p(0),
        IB         => TMDS_Data_n(0),
        O          => TMDS_Data(0));
 
OutputBuffer_Clock: OBUFDS
       generic map (
          IOSTANDARD => "TMDS_33")
       port map (
          O          => TMDS_Clk_p_out,
          OB         => TMDS_Clk_n_out,
          I          => TMDS_Clk_out);
OutputBuffer_Channel2: OBUFDS
     generic map (
        IOSTANDARD => "TMDS_33")
     port map (
        O          => TMDS_Data_p_out(2),
        OB         => TMDS_Data_n_out(2),
        I          => TMDS_Data_out(2));
OutputBuffer_Channel1: OBUFDS
       generic map (
          IOSTANDARD => "TMDS_33")
       port map (
          O          => TMDS_Data_p_out(1),
          OB         => TMDS_Data_n_out(1),
          I          => TMDS_Data_out(1));
OutputBuffer_Channel0: OBUFDS
     generic map (
        IOSTANDARD => "TMDS_33")
     port map (
        O          => TMDS_Data_p_out(0),
        OB         => TMDS_Data_n_out(0),
        I          => TMDS_Data_out(0));
--Passthrough with simple connection of port only, no signal can be processed                                                                            
--TMDS_CLK_out <= TMDS_Clk;
--TMDS_data_out <= TMDS_Data;
--Generate the PixelClk from the 10x SerialClk
PixelClk_From_SerialClk: process(CLK_OUT_10x_SerialClk)
begin
if rising_edge(CLK_OUT_10x_SerialClk) then
--     if SeialClk_counter = 4 or SeialClk_counter = 9 then
--     CLK_OUT_1x_PixelClk <= not CLK_OUT_1x_PixelClk; 
--     end if;

     if SeialClk_counter < 8 then
     SeialClk_counter <= SeialClk_counter + 1;
     else
     SeialClk_counter <= 0;
     end if;
 end if;
end process PixelClk_From_SerialClk;

--PixelClkBuffer: BUFR
--   generic map (
--      BUFR_DIVIDE => "5",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
--      SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
--   )
--   port map (
--      O => CLK_OUT_1x_PixelClk,     -- 1-bit output: Clock output port
--      CE => '1',   -- 1-bit input: Active high, clock enable (Divided modes only)
--      CLR => rBUFR_Rst, -- 1-bit input: Active high, asynchronous clear (Divided modes only)        
--      I => CLK_OUT_10x_SerialClk      -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
--   );     
--rBUFR_Rst <= rMMCM_LckdRisingFlag; --pulse CLR on BUFR one the clock returns

--Attempt to sample the TMDS data
Sampling_TMDS: process(CLK_OUT_10x_SerialClk)
begin
if rising_edge(CLK_OUT_10x_SerialClk) then
TMDS_data_Channel_0(SeialClk_counter) <= TMDS_Data(0);
TMDS_data_Channel_1(SeialClk_counter) <= TMDS_Data(1);
TMDS_data_Channel_2(SeialClk_counter) <= TMDS_Data(2);
--if count_in < 8 then count_in <= count_in + 1; else count_in <= 0; end if;
end if;
end process Sampling_TMDS;

Decode_8_bit_signal: process(CLK_OUT_10x_SerialClk)
begin
if rising_edge(CLK_OUT_10x_SerialClk) then

end if;
end process Decode_8_bit_signal;

Output_TMDS: process(CLK_OUT_1x_PixelClk)
begin
if rising_edge(CLK_OUT_10x_SerialClk) then
TMDS_data_out(0) <= TMDS_data_Channel_0 (SeialClk_counter);
TMDS_data_out(1) <= TMDS_data_Channel_1 (SeialClk_counter);
TMDS_data_out(2) <= TMDS_data_Channel_2 (SeialClk_counter);
--if count_out < 8 then count_out <= count_out + 1; else count_out <= 0; end if;
TMDS_CLK_out <= CLK_OUT_1x_PixelClk;
end if;
end process Output_TMDS;

--Make a 10x faster clock from the PixelClk
DVI_ClkGenerator: MMCME2_ADV
   generic map
      (BANDWIDTH            => "OPTIMIZED",-- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F      =>  real(kClkRange) * 10.0,  -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE       => 0.000, -- Phase offset in degrees of CLKFB (-360.000-360.000).
      
      -- CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      CLKIN1_PERIOD        =>  6.734006, -- for resolution of 1920x1080, pixel clock is 148.5 Mhz
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
      CLKOUT0_DIVIDE_F     => real(kClkRange) * 1.0,-- Divide amount for CLKOUT0 (1.000-128.000).
--      CLKOUT1_DIVIDE       => 10,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99)
      CLKOUT0_DUTY_CYCLE   => 0.500,
--      CLKOUT1_DUTY_CYCLE => 0.500,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT0_PHASE        => 0.000,
      CLKOUT1_PHASE => 0.0,
      CLKOUT4_CASCADE      => FALSE,        -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      COMPENSATION         => "ZHOLD",  -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
      DIVCLK_DIVIDE        => 1,            -- Master division value (1-106)
      -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
      REF_JITTER1          => 0.010,
      STARTUP_WAIT         => FALSE,   -- Delays DONE until MMCM is locked (FALSE, TRUE)
      -- USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
      CLKFBOUT_USE_FINE_PS => FALSE,
      CLKOUT0_USE_FINE_PS  => FALSE)
   port map
   -- Output clocks
   (
      CLKOUT0             => clkout4_unused,            -- 1-bit output: CLKOUT0
      CLKOUT0B            => clkout0b_unused,           -- 1-bit output: Inverted CLKOUT0
      CLKOUT1             => clkout1_unused,            -- 1-bit output: CLKOUT1
      CLKOUT1B            => clkout1b_unused,           -- 1-bit output: Inverted CLKOUT1
      CLKOUT2             => clkout2_unused,            -- 1-bit output: CLKOUT2
      CLKOUT2B            => clkout2b_unused,           -- 1-bit output: Inverted CLKOUT2
      CLKOUT3             => clkout3_unused,            -- 1-bit output: CLKOUT3
      CLKOUT3B            => clkout3b_unused,           -- 1-bit output: Inverted CLKOUT3
      CLKOUT4             => CLK_OUT_10x_SerialClk,            -- 1-bit output: CLKOUT4
      CLKOUT5             => clkout5_unused,            -- 1-bit output: CLKOUT5
      CLKOUT6             => clkout6_unused,            -- 1-bit output: CLKOUT6
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBOUT            => clkfbout_hdmi_clk,         -- 1-bit output: Feedback clock
      CLKFBOUTB           => clkfboutb_unused,          -- 1-bit output: Inverted CLKFBOUT
      CLKFBIN             => clkfbout_hdmi_clk,         -- 1-bit input: Feedback clock
      -- Input clock control
      CLKIN1              => TMDS_Clk,
      CLKIN2              => '0',
      -- Tied to always select the primary input clock
      CLKINSEL            => '1',    -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
      -- Ports for dynamic reconfiguration
      DADDR               => (others => '0'),
      DCLK                => '0',
      DEN                 => '0',
      DI                  => (others => '0'),
      DO                  => do_unused,
      DRDY                => drdy_unused,
      DWE                 => '0',
      -- Ports for dynamic phase shift
      PSCLK               => '0',
      PSEN                => '0',
      PSINCDEC            => '0',
      PSDONE              => psdone_unused,
      -- Status Ports: 1-bit (each) output: MMCM status ports
      CLKINSTOPPED        => clkinstopped_unused,   -- 1-bit output: Feedback clock stopped
      CLKFBSTOPPED        => clkfbstopped_unused,   -- 1-bit output: Input clock stopped
      LOCKED              => aMMCM_Locked,          -- 1-bit output: LOCK
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN              => '0',               -- 1-bit input: Power-down
      RST                 => rMMCM_Reset_q(0)); -- 1-bit input: Feedback clock
      
MMCM_Reset: process(rLockLostRst, RefClk)
      begin
         if (rLockLostRst = '1') then
            rMMCM_Reset_q <= (others => '1'); -- MMCM_RSTMINPULSE Minimum Reset Pulse Width 5.00ns = two RefClk periods min
         elsif Rising_Edge(RefClk) then
            if (rMMCM_LckdFallingFlag = '1') then
                rMMCM_Reset_q <= (others => '1');
            else
                rMMCM_Reset_q <= '0' & rMMCM_Reset_q(rMMCM_Reset_q'high downto 1);
            end if;
         end if; 
      end process MMCM_Reset;
      
LockLostReset: entity work.ResetBridge
         generic map (
            kPolarity => '1')
         port map (
            aRst => aRst,
            OutClk => RefClk,
            oRst => rLockLostRst);
      
--IDELAYCTRL must be reset after configuration or refclk lost for 52ns(K7), 72ns(A7) at least
ResetIDELAYCTRL: process(rLockLostRst, RefClk)
begin
 if Rising_Edge(RefClk) then
    if (rLockLostRst = '1') then
       rDlyRstCnt <= kDlyRstDelay - 1;
       rDlyRst <= '1';
    elsif (rDlyRstCnt /= 0) then
       rDlyRstCnt <= rDlyRstCnt - 1;
    else
       rDlyRst <= '0';
    end if;
 end if;
end process;
  
IDelayCtrlX: IDELAYCTRL
 port map (
    RDY         => aDlyLckd,
    REFCLK      => RefClk,
    RST         => rDlyRst);   

RdyLostReset: entity work.ResetBridge
 generic map (
    kPolarity => '1')
 port map (
    aRst => not aDlyLckd,
    OutClk => RefClk,
    oRst => rRdyRst);
    
MMCM_LockSync: entity work.SyncAsync
   port map (
      aReset => '0',
      aIn => aMMCM_Locked,
      OutClk => RefClk,
      oOut => rMMCM_Locked);
      
MMCM_LockedDetect: process(RefClk)
begin
   if Rising_Edge(RefClk) then
      rMMCM_Locked_q <= rMMCM_Locked & rMMCM_Locked_q(1);
      rMMCM_LckdFallingFlag <= rMMCM_Locked_q(1) and not rMMCM_Locked;
      rMMCM_LckdRisingFlag <= not rMMCM_Locked_q(1) and rMMCM_Locked;
   end if;
end process MMCM_LockedDetect;

GlitchFreeLocked: process(rRdyRst, RefClk)
begin
   if (rRdyRst = '1') then
      aLocked <= '0';
   elsif Rising_Edge(RefClk) then
      aLocked <= rMMCM_Locked_q(0);
   end if;
end process GlitchFreeLocked;

    
process(TMDS_Clk)
begin
if rising_edge(TMDS_Clk) then
    if counter_test1 < 1073741824 then
    led(0) <= '1';
    else 
    led(0) <= '0';
    end if;
    counter_test1 <= counter_test1 + 1;
end if;
end process;

process(CLK_OUT_1x_PixelClk)
begin
if rising_edge(CLK_OUT_1x_PixelClk) then
    if counter_test2 < 1073741824 then
    led(1) <= '1';
    else 
    led(1) <= '0';
    end if;
    counter_test2 <= counter_test2 + 1;
end if;
end process;

process(CLK_OUT_10x_SerialClk)
begin
if rising_edge(CLK_OUT_10x_SerialClk) then
    if counter_test3 < 1073741824 then
    led(2) <= '1';
    else 
    led(2) <= '0';
    end if;
    counter_test3 <= counter_test3 + 1;
end if;
end process;

process(CLK_OUT_10x_SerialClk)
begin
if rising_edge(CLK_OUT_10x_SerialClk) then
    if counter_test4 < 1073741824 then
    led(3) <= '1';
    else 
    led(3) <= '0';
    end if;
    if SeialClk_counter = 1 then
    counter_test4 <= counter_test4 + 1;
    end if;
end if;
end process;
--led(0) <= TMDS_Clk;
--led(1) <= CLK_OUT_1x_PixelClk;
--led(2) <= CLK_OUT_10x_SerialClk;
--led(3) <=TMDS_data_Channel_0(0);
end Behavioral;
