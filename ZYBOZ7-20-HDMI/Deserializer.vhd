----------------------------------------------------------------------------------
-- Company: HsKA
-- Engineer: Tran Dinh Hai Dang
-- 
-- Create Date: 18.07.2018 23:04:57
-- Design Name: Deserializer
-- Module Name: Deserializer - Behavioral
-- Project Name: Deserializer
-- Target Devices: Zybo Z7
-- Tool Versions:  Vivado 2016.4
-- Description: This is a program for Deserialize the stream signal from HDMI input
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Purpose: This a program mimic the program ISERDESE of Xilinx, this is specially 
-- for HDMI 1:10 ratio only.
--  
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Deserializer is
  Port ( 
  -- input Clk and data
  CLK : in STD_LOGIC := '0';  --1bit clock input, fast clock or SerialClk
  CLKB: in STD_LOGIC := '0';  --1bit clock input, just a simple reverse of the fast clock (SerialClk)
  CLKDIV: in STD_LOGIC:= '0' ; -- 1bit slow clock input, should be PixelClk
  SerData: in STD_LOGIC:= '0'; -- 1bit serial data input, this data will be sampled every SerialClk
  RST: in STD_LOGIC:= '0'; -- 1bit reset input,
  -- output data
  Q0: out STD_LOGIC:= '0'; 
  Q1: out STD_LOGIC:= '0';
  Q2: out STD_LOGIC:= '0';
  Q3: out STD_LOGIC:= '0';
  Q4: out STD_LOGIC:= '0';
  Q5: out STD_LOGIC:= '0';
  Q6: out STD_LOGIC:= '0';
  Q7: out STD_LOGIC:= '0';
  Q8: out STD_LOGIC:= '0';
  Q9: out STD_LOGIC:= '0'
  );

end Deserializer;

architecture Behavioral of Deserializer is
signal Q_array: STD_LOGIC_VECTOR (9 downto 0):= (others => '0');
begin
Sample_data_every_clock:process(CLK, CLKB)
begin
if (rising_edge(CLK) or rising_edge(CLKB)) then
--if (rising_edge(CLK)) then
    --Sample the data into the LSB Q0
--    Q_array <= Q_array(8 downto 0) & SerData;
    Q_array <= SerData & Q_array(9 downto 1) ;
end if;
end process;

Output_every_PixelClk: process(CLKDIV)
begin
if (rising_edge(CLKDIV)) then
Q0 <= Q_array(0);
Q1 <= Q_array(1);
Q2 <= Q_array(2);
Q3 <= Q_array(3);
Q4 <= Q_array(4);
Q5 <= Q_array(5);
Q6 <= Q_array(6);
Q7 <= Q_array(7);
Q8 <= Q_array(8);
Q9 <= Q_array(9);
end if;
end process;

end Behavioral;
