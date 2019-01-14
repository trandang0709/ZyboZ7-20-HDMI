----------------------------------------------------------------------------------
-- Company: HsKA
-- Engineer: Tran Dinh Hai Dang
-- 
-- Create Date: 24.07.2018 23:36:29
-- Design Name: Zybo Z7 HDMI in HDMI out
-- Module Name: average - Behavioral
-- Project Name:Zybo Z7 HDMI in HDMI out 
-- Target Devices: Zybo Z7
-- Tool Versions: Vivado 2016.4
-- Description: This program is for averaging the input, this is for reducing the noise
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity average is
  Generic(
  kStage: integer:= 2 --Number of sample for averaging
  );
  Port (
  Sample_Clk: in std_logic:= '0';
  Vdata: in std_logic_vector (7 downto 0) := (others => '0');
  Videodata_ave: out std_logic_vector (7 downto 0) := (others => '0')
   );
end average;

architecture Behavioral of average is
signal count: integer:= 0;
signal buf0: STD_LOGIC_VECTOR(7 downto 0);
signal buf1: STD_LOGIC_VECTOR(7 downto 0);
signal buf2: STD_LOGIC_VECTOR(7 downto 0);
signal BnWVideodata_buf: STD_LOGIC_VECTOR(7 downto 0);
begin

Take_sample:process(Sample_Clk)
begin
if count <= 2 then
count <= count + 1;
else
count <= 0;
end if;

case count is
when 0 => buf0 <= Vdata;
when 1 => buf1 <= Vdata;
when others => buf2 <= Vdata;
end case;

Videodata_ave <= STD_LOGIC_VECTOR(unsigned(b"00" & buf0( 7 downto  2)) + unsigned (b"0000" & buf0( 7 downto  4)) + unsigned (b"000000" & buf0( 7 downto  6))
                               + unsigned(b"00" & buf1( 7 downto  2)) + unsigned (b"0000" & buf1( 7 downto  4)) + unsigned (b"000000" & buf1( 7 downto  6))
                               + unsigned(b"00" & buf2( 7 downto  2)) + unsigned (b"0000" & buf2( 7 downto  4)) + unsigned (b"000000" & buf2( 7 downto  6))
                                );

end process Take_sample;
end Behavioral;
