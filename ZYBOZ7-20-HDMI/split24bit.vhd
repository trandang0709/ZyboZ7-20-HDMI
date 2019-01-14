----------------------------------------------------------------------------------
-- Company: HsKA
-- Engineer: Tran Dinh Hai Dang
-- 
-- Create Date: 09.07.2018 16:02:40
-- Design Name: split 24 bit
-- Module Name: split24bit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This module is for split the 24 bit data coming from DVI2RGB into 
--              8 bit R + 8 bit G + 8 bit B
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity split24bit is
  Port (
       videodata_from_dvi_2_rgb: in std_logic_vector(23 downto 0);
       videodata_to_rgb_2dvi_R : out std_logic_vector(7 downto 0);
       videodata_to_rgb_2dvi_G : out std_logic_vector(7 downto 0);
       videodata_to_rgb_2dvi_B : out std_logic_vector(7 downto 0) 
   );
end split24bit;

architecture Behavioral of split24bit is

begin
videodata_to_rgb_2dvi_R <= videodata_from_dvi_2_rgb(23 downto 16);
videodata_to_rgb_2dvi_G <= videodata_from_dvi_2_rgb(15 downto 8);
videodata_to_rgb_2dvi_B <= videodata_from_dvi_2_rgb(7 downto 0);
end Behavioral;
