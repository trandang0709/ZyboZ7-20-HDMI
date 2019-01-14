----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.07.2018 10:25:33
-- Design Name: 
-- Module Name: FrameBuf - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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

entity FrameBuf is
  Port ( 
  Hcount: in integer:= 0;
  Vcount: in integer:= 0;
  HSize: in integer:= 1920;
  VSize: in integer:= 1080;
  Vdatathis: in STD_LOGIC_VECTOR;
  

  Vdata_past_1_this: out STD_LOGIC_VECTOR;
  Vdata_past_1_up: out STD_LOGIC_VECTOR;
  Vdata_past_1_down: out STD_LOGIC_VECTOR;
  Vdata_past_1_left: out STD_LOGIC_VECTOR;
  Vdata_past_1_right: out STD_LOGIC_VECTOR   
  );
end FrameBuf;

architecture Behavioral of FrameBuf is
subtype Vdata_val is std_logic_vector(7 downto 0);
type t_row is array (natural range<>) of Vdata_val;
subtype t_H_buf is t_row(0 to 1920); 
--type t_col is array (natural range<>) of t_H_buf;
--subtype t_V_buf is t_col(0 to 1080);

signal Vdata_H_buf : t_H_buf;
--signal Vdata_V_buf : t_V_buf;
signal Vdatathis_array  : Vdata_val;
begin

Buffer_line:process(Vdatathis)
begin
Vdatathis_array <= Vdatathis;
Vdata_H_buf(Hcount) <= Vdatathis_array;
--Vdata_V_buf(Vcount) <= Vdata_H_buf;


--    if Vcount = 0 then
--    Vdata_past_1_up <= Vdata_V_buf(Vcount)(Hcount);
--    else
--    Vdata_past_1_up <= Vdata_V_buf(Vcount - 1)(Hcount);
--    end if;
    
--    if Vcount = VSize then
--    Vdata_past_1_down <= Vdata_V_buf(Vcount)(Hcount);
--    else
--    Vdata_past_1_down <= Vdata_V_buf(Vcount + 1)(Hcount);
--    end if;
    
Vdata_past_1_this <= Vdata_H_buf(Hcount);
    
    if Hcount = 0 then
    Vdata_past_1_left <= Vdata_H_buf(Hcount);
    else
    Vdata_past_1_left <= Vdata_H_buf(Hcount-1);
    end if;
    
    if Hcount = HSize then
    Vdata_past_1_right <=Vdata_H_buf(Hcount);
    else
    Vdata_past_1_right <=Vdata_H_buf(Hcount+1);
    end if;
end process Buffer_line;
end Behavioral;
