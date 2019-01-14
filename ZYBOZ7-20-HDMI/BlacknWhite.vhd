----------------------------------------------------------------------------------
-- Company: HsKA    
-- Engineer: Tran Dinh Hai Dang
-- 
-- Create Date: 22.07.2018 09:52:30
-- Design Name: Zybo Z7 HDMI
-- Module Name: BlacknWhite - Behavioral
-- Project Name: Zybo Z7 HDMI IN OUT
-- Target Devices: Zybo Z7
-- Tool Versions: Vivado 2016.4
-- Description: This module is to make signal from    RGB     to Black and white
--                                                (256x256x25)      (8 bit)
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
-- This module has 2 part, Part 1: making gray scale imaging by different method, there are 3 method, using
-- different Gray scale factor. Part 2 is making a Binary imagine (just 1 or 0) from the gray scale result
--Black and White: This mode will reduce the color data from 256x256x256 to 8 bit only
--             8 bit Output is calculate by 1/2 max + 1/2 min method from  video data RGB
--             Out   =   1/3R   +   1/3G   +   1/3B
--           (8 bit)    (8 bit)    (8 bit)   (8 bit)
--             8 bit Output is calculate by AVERAGE video data RGB
--             Out   =   1/3R   +   1/3G   +   1/3B
--           (8 bit)    (8 bit)    (8 bit)   (8 bit)
--             8 bit Output is calculate by AVERAGE video data RGB
--             Out   =   1/3R   +   1/3G   +   1/3B
--           (8 bit)    (8 bit)    (8 bit)   (8 bit)
--      Note: For divide in VHDL or Verilog 1/3 = 0.333333 => 1/4 + 1/16 + 1/64 = 0.328125
--However the data feed to RGB2DVI block needs 24 bit, this OUT 8 bit is going to be duplicated 3 times
--             RGB2DVI input =   OUT          &      OUT       &       OUT
--             (24 bit)       (8 bit) concatenate (8 bit) concatenate (8 bit)
--After Gray scale reduction, the data only need to be processed with 8 bit which have value ranging from  x"00" and X"FF"
--After Black and White reduction, the data only need to be processed with 8 bit which only have 2 value x"00" and X"FF"
-- Black n White threshold is set to x"8F",  every grayscale pixel >= x"8F" is considered White
--                                           every grayscale pixel >= x"8F" is considered Black
-- The threshold can be changed by going to BlacknWhite.vhd file   
------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BlacknWhite is

  Port (
  PixelClk: in STD_LOGIC;
  RGBVideodata: in STD_LOGIC_VECTOR (23 downto 0);
  
  GSVideodata1   : out STD_LOGIC_VECTOR(7 downto 0);--output of gray scale video data type 1
  GSVideodata2   : out STD_LOGIC_VECTOR(7 downto 0);--output of gray scale video data type 2
  GSVideodata3   : out STD_LOGIC_VECTOR(7 downto 0);--output of gray scale video data type 3
  
  BnWVideodata: out STD_LOGIC_VECTOR(7 downto 0) --output of black and white video data
   );
end BlacknWhite;

architecture Behavioral of BlacknWhite is
signal max: STD_LOGIC_VECTOR(7 downto 0);   
signal min: STD_LOGIC_VECTOR(7 downto 0);  



signal count: integer range 0 to 4;
begin

--Gray scale Method 1: 1/3 R + 1/3 G + 1/3 B 
GSVideodata1 <= STD_LOGIC_VECTOR(unsigned(b"00" & RGBVideodata(23 downto 18)) + unsigned (b"0000" & RGBVideodata(23 downto 20)) + unsigned (b"000000" & RGBVideodata(23 downto 22))
                               + unsigned(b"00" & RGBVideodata(15 downto 10)) + unsigned (b"0000" & RGBVideodata(15 downto 12)) + unsigned (b"000000" & RGBVideodata(15 downto 14))
                               + unsigned(b"00" & RGBVideodata( 7 downto  2)) + unsigned (b"0000" & RGBVideodata( 7 downto  4)) + unsigned (b"000000" & RGBVideodata( 7 downto  6))
                                );

--Gray scale method 2: (max(R,G,B) + min(R,G,B))/2  
Maxmin_GS_method:process(PixelClk)
begin
if (RGBVideodata(23 downto 16) >= RGBVideodata(15 downto 8)) and (RGBVideodata(23 downto 16) >= RGBVideodata(7 downto 0)) then
 max <= RGBVideodata(23 downto 16);
 end if;
if (RGBVideodata(15 downto 8) >= RGBVideodata(23 downto 16)) and (RGBVideodata(15 downto 8) >= RGBVideodata(7 downto 0)) then
 max <= RGBVideodata(15 downto 8);
 end if;
if (RGBVideodata(7 downto 0) >= RGBVideodata(23 downto 16)) and (RGBVideodata(7 downto 0) >= RGBVideodata(15 downto 8)) then
 max <= RGBVideodata(7 downto 0);
 end if;
if (RGBVideodata(23 downto 16) <= RGBVideodata(15 downto 8)) and (RGBVideodata(23 downto 16) <= RGBVideodata(7 downto 0)) then
 min <= RGBVideodata(23 downto 16);
 end if;
if (RGBVideodata(15 downto 8) <= RGBVideodata(23 downto 16)) and (RGBVideodata(15 downto 8) <= RGBVideodata(7 downto 0)) then
 min <= RGBVideodata(15 downto 8);
 end if;
if (RGBVideodata(7 downto 0) <= RGBVideodata(23 downto 16)) and (RGBVideodata(7 downto 0) <= RGBVideodata(15 downto 8)) then
 min <= RGBVideodata(7 downto 0);
 end if;
end process Maxmin_GS_method;                      
GSVideodata2 <= STD_LOGIC_VECTOR(unsigned(b"0" & max(7 downto 1)) + unsigned (b"0" & min(7 downto 1)));


--Gray scale method 3:  y = 0.299R + 0.587G + 0.114B
GSVideodata3 <= STD_LOGIC_VECTOR(unsigned(b"00" & RGBVideodata(23 downto 18)) + unsigned (b"00000" & RGBVideodata(23 downto 21)) + unsigned (b"000000" & RGBVideodata(23 downto 22))
                               + unsigned(b"0000" & RGBVideodata(15 downto 12)) + unsigned (b"00000" & RGBVideodata(15 downto 13)) + unsigned (b"000000" & RGBVideodata(15 downto 14)) + unsigned (b"0000000" & RGBVideodata(15 downto 15))
                               + unsigned(b"0"  & RGBVideodata( 7 downto  1)) + unsigned (b"0000" & RGBVideodata( 7 downto  4)) + unsigned (b"000000" & RGBVideodata( 7 downto 6)) + unsigned (b"0000000" & RGBVideodata( 7 downto 7))
                                );
                                                                                                                                                                                     

BnW:process(PixelClk)
begin
 if STD_LOGIC_VECTOR(unsigned(b"00" & RGBVideodata(23 downto 18)) + unsigned (b"0000" & RGBVideodata(23 downto 20)) + unsigned (b"000000" & RGBVideodata(23 downto 22))
                   + unsigned(b"00" & RGBVideodata(15 downto 10)) + unsigned (b"0000" & RGBVideodata(15 downto 12)) + unsigned (b"000000" & RGBVideodata(15 downto 14))
                   + unsigned(b"00" & RGBVideodata( 7 downto  2)) + unsigned (b"0000" & RGBVideodata( 7 downto  4)) + unsigned (b"000000" & RGBVideodata( 7 downto  6))
                    ) <= x"8F" then
BnWVideodata <= x"00";
end if;
 if STD_LOGIC_VECTOR(unsigned(b"00" & RGBVideodata(23 downto 18)) + unsigned (b"0000" & RGBVideodata(23 downto 20)) + unsigned (b"000000" & RGBVideodata(23 downto 22))
                   + unsigned(b"00" & RGBVideodata(15 downto 10)) + unsigned (b"0000" & RGBVideodata(15 downto 12)) + unsigned (b"000000" & RGBVideodata(15 downto 14))
                   + unsigned(b"00" & RGBVideodata( 7 downto  2)) + unsigned (b"0000" & RGBVideodata( 7 downto  4)) + unsigned (b"000000" & RGBVideodata( 7 downto  6))
                   ) > x"8F" then
BnWVideodata <= x"FF";
end if;
end process BnW;

end Behavioral;
