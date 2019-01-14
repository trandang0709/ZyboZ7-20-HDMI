----------------------------------------------------------------------------------
-- Company: HsKA
-- Engineer: Tran Dinh Hai Dang
-- 
-- Create Date: 09.07.2018 21:43:08
-- Design Name: ResyncToBUFG_Serial.vhd
-- Module Name: ResyncToBUFG_SerialCLK - Behavioral
-- Project Name: ZyboZ7_HDMI_IN_OUT
-- Target Devices: ZyboZ7 - 20?
-- Tool Versions: Vivado 2016.4
-- Description: This is the modified version of the program from Elod Gyorgy (credit below)
-- this program is for buffing not only the pixel CLK but also the Serial CLK for output of HDMI
--on Zybo Z7, which have HDMI input and output
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--This file is an adaption from below
-- File: ResyncToBUFG.vhd
-- Author: Elod Gyorgy
-- Original Project: HDMI input on 7-series Xilinx FPGA
-- Date: 7 July 2015
--

-------------------------------------------------------------------------------
--
-- Purpose:
-- This module inserts a BUFG on the SerialClk and PixelClk path so that the 
-- pixel bus can be routed globally on the device. It also synchronizes data 
-- to the new BUFG clock. 
--  
-------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ResyncToBUFG_SerialCLK is
   Port (
      -- Video in
      piData : in std_logic_vector(23 downto 0);
      piVDE : in std_logic;
      piHSync : in std_logic;
      piVSync : in std_logic;
      PixelClkIn : in std_logic; 
      SerialClkIn: in std_logic;
      -- Video out
      poData : out std_logic_vector(23 downto 0);
      poVDE : out std_logic;
      poHSync : out std_logic;
      poVSync : out std_logic;
      SerialClkOut: out std_logic;
      PixelClkOut : out std_logic
   );
end ResyncToBUFG_SerialCLK;

architecture Behavioral of ResyncToBUFG_SerialCLK is

signal PixelClkInt : std_logic;
signal SerialClkInt : std_logic;
begin
    
-- Insert BUFG  on clock path
InstBUFG_SerialClk: BUFG 
   port map (
      O => SerialClkInt, -- 1-bit output: Clock output
      I => SerialClkIn  -- 1-bit input: Clock input
   );
InstBUFG_PixelClk: BUFG
   port map (
      O => PixelClkInt, -- 1-bit output: Clock output
      I => PixelClkIn  -- 1-bit input: Clock input
   );
   
-- Try simple registering for re-align the video data with the CLK
RegisterData: process(PixelClkInt)
begin
   if Rising_Edge(PixelClkInt) then     
          poData <= piData;
          poVDE <= piVDE;
          poHSync <= piHSync;
          poVSync <= piVSync;
   end if;
PixelClkOut <= PixelClkInt;
SerialClkOut <= SerialClkInt;
end process RegisterData;

end Behavioral;

