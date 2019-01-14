----------------------------------------------------------------------------------
-- Company: HsKA
-- Engineer: Tran Dinh Hai Dang
-- 
-- Create Date: 19.07.2018 10:28:23
-- Design Name: RGB processing
-- Module Name: rgb_processing - Behavioral
-- Project Name: ZyboZ7- HDMI
-- Target Devices: ZyboZ7
-- Tool Versions: Vivado2016.4
-- Description: This module is for some manipulation algorithm of the frame
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Purpose: This module is for adding some simple manipulation of the frame
-- that is read from dvi2rgb module
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

entity rgb_processing is
  generic(
  kAddPUBG_Serial: boolean:= true; --Indicate if the signal should be re-buffer and re-timing to align with PixelClk
                    --after processing phase so that no skew is introduced between the video data and the PixelClk.
                    --If don't buffer and re-timing, may lead to some skew between data and CLK which may lead to wrong
                    --result
  --The default Hsize and Vsize is for HDMI 1080 resolution, this can be changed by changing the value in the
  --file name system_rgb_processing_0_0
  kAverage_BnW: boolean:= true; -- true if the BnW signal should be average before output
  kAverage_GS: boolean:= true; -- true if the BnW signal should be average before output
  KGenerateBnW: boolean:= true; --true, if Black and White signal should be generated.
                                -- Black and White signal might be needed for others algorithm like Haar?
                                -- the manipulate video data signal is reduced from 256x256x256 down to 8 bit
  kFrameBuf: boolean:= false; --True, if a frame is needed to be buffered.
                              -- when a frame is buffered into the memory, some algorithm about the pass frame can
                              -- be implemented, however the memory capacity need to be considered. For
                              -- Zybo Z7, we face strange behavior in mode Gray Scale or BnW
                              -- when the block buffer frame is added

  
  HSize: integer:= 1920; 
  VSize: integer:= 1080;
  pol_Hsync: STD_LOGIC:= '1';
  pol_Vsync: STD_LOGIC:= '1'
  );
  Port (
     --Input signal
      vid_pData: in STD_LOGIC_VECTOR (23 downto 0);
      vid_pVDE: in STD_LOGIC;
      vid_pHSync: in STD_LOGIC;
      vid_pVSync: in STD_LOGIC;
      PixelClk: in STD_LOGIC;
      SerialClk: in STD_LOGIC;
  
      --Output signal
      vid_pData_out: out STD_LOGIC_VECTOR (23 downto 0);
      vid_pVDE_out: out STD_LOGIC;
      vid_pHSync_out: out STD_LOGIC;
      vid_pVSync_out: out STD_LOGIC;
      PixelClk_out: out STD_LOGIC;
      SerialClk_out: out STD_LOGIC;
      
      --switch for choosing the manipulation method
      sw1: in STD_LOGIC;
      sw2: in STD_LOGIC;
      sw3: in STD_LOGIC;
      sw4: in STD_LOGIC
    );
end rgb_processing;

architecture Behavioral of rgb_processing is
signal switches:STD_LOGIC_VECTOR (3 downto 0);
signal state0,state1,state2,state3,state4,state5,state6,state7,
       state8,state9,state10,state11,state12,state13,state14,
       state15: BOOLEAN;
signal vid_pData_process:STD_LOGIC_VECTOR(23 downto 0):= (others => '0');
--signal vid_pData_G_process:STD_LOGIC_VECTOR(7 downto 0):= (others => '0');
--signal vid_pData_B_process:STD_LOGIC_VECTOR(7 downto 0):= (others => '0');
signal vid_pVDE_process: STD_LOGIC:= '0';
signal vid_pHSync_process: STD_LOGIC:='0';
signal vid_pVSync_process: STD_LOGIC:='0';
signal Hcount: integer range 0 to HSize:= 0; --Count value for counting the pixel CLK.
                                           --the upper limit could be changed, think of the
                                           -- resources when change the value
signal Vcount: integer range 0 to VSize:= 0;
signal Ave_count: integer range 0 to 3:=0; -- count value for averaging the signal
signal BnW : STD_LOGIC_VECTOR (7 downto 0):= (others => '0'); --black and white video data
signal GS1 : STD_LOGIC_VECTOR (7 downto 0):= (others => '0'); --gray scale video data type 1
signal GS2 : STD_LOGIC_VECTOR (7 downto 0):= (others => '0'); --gray scale video data type 2
signal GS3 : STD_LOGIC_VECTOR (7 downto 0):= (others => '0'); --gray scale video data type 3

signal BnW_ave: STD_LOGIC_VECTOR(7 downto 0):= (others => '0');--Black and White average video data
signal BnW_buf: STD_LOGIC_VECTOR (7 downto 0):= (others => '0');
signal GS3_ave : STD_LOGIC_VECTOR (7 downto 0):= (others => '0'); --gray scale average video data
signal GS_buf : STD_LOGIC_VECTOR (7 downto 0):= (others => '0'); --gray scale video data
signal ave_buf_GS: STD_LOGIC_VECTOR(23 downto 0):= (others => '0'); -- buffer for averaging of GS
signal ave_buf_BnW: STD_LOGIC_VECTOR(23 downto 0):= (others => '0'); -- buffer for averaging of GS


signal Vdata_past_1_this : STD_LOGIC_VECTOR (7 downto 0):= (others => '0');
signal Vdata_past_1_up : STD_LOGIC_VECTOR (7 downto 0):= (others => '0');
signal Vdata_past_1_down : STD_LOGIC_VECTOR (7 downto 0):= (others => '0');
signal Vdata_past_1_left : STD_LOGIC_VECTOR (7 downto 0):= (others => '0');
signal Vdata_past_1_right : STD_LOGIC_VECTOR (7 downto 0):= (others => '0');
--subtype Vdata_val is std_logic_vector(7 downto 0);
--type t_row is array (natural range<>) of Vdata_val;
--subtype t_H_buf is t_row(0 to HSize); 
--type t_col is array (natural range<>) of t_H_buf;
--subtype t_V_buf is t_col(0 to VSize);

--signal Vdata_H_buf : t_H_buf;
--signal Vdata_V_buf : t_V_buf;

begin --Program start from below here


----------------------------------------------------------------
--Use switch combination to save effort of listing switch everytime
--we need to address the switches. each processing mode is choosen
--by the switches combination
----------------------------------------------------------------
switches <= sw1 & sw2 & sw3 & sw4;


Processing_method:process(PixelClk) --update is made at every PixelClk changes
begin
if rising_edge(PixelClk) then
BnW_buf <= BnW;
GS_buf <= GS1;
----------------------------------------------------------------
--Passthrough: video data is passthrough. No processing is made
----------------------------------------------------------------
Passthrough: if  switches = "0000" then
   vid_pData_process <= vid_pData;
end if Passthrough ;

----------------------------------------------------------------
--Cut some color: CutRED, CutGREEN, CutBLUE
----------------------------------------------------------------   
CutRED: if  switches = "0001" then
      vid_pData_process <= x"00" & vid_pData(15 downto 8) & vid_pData(7 downto 0);   
end if CutRED ;

CutBLUE: 
if  switches = "0010"  then
      vid_pData_process <= vid_pData(23 downto 16) & x"00" & vid_pData(7 downto 0);     
end if CutBLUE;

CutGREEN: 
if  switches = "0011"  then
      vid_pData_process <= vid_pData(23 downto 16) & vid_pData(15 downto 8) & x"00";  
end if CutGREEN;


---------------------------------------------------
--Eight color: This mode will reduce the color data
--             from 256x256x256 to 2x2x2
--             The R has 2 state 00 or FF
--             The G has 2 state 00 or FF
--             The B has 2 state 00 or FF
-- Which give out in total 8 posible combination
---------------------------------------------------
eight_color: 
if  switches = "0100"  then  
          if vid_pData(23 downto 16) < x"0F" then
                vid_pData_process(23 downto 16)<= x"00";
              end if;
          if vid_pData(23 downto 16) >= x"0F" then
                vid_pData_process(23 downto 16)<= x"FF";
          end if;
          if vid_pData(15 downto 8) < x"0F" then
                 vid_pData_process(15 downto 8)<= x"00";
               end if;
          if vid_pData(15 downto 8) >= x"0F" then
                 vid_pData_process(15 downto 8)<= x"FF";
          end if;
          if vid_pData(7 downto 0) < x"0F" then
                 vid_pData_process(7 downto 0)<= x"00";
          end if;
          if vid_pData(7 downto 0) >= x"0F" then
                 vid_pData_process(7 downto 0)<= x"FF";
          end if;
end if eight_color;



------------------------------------------------------------------------------------------------------
--Gray Scale: This mode will reduce the color data from RGB 256x256x256 to gray scale 8 bit only
--             8 bit Output is calculate by AVERAGE video data RGB
--             Out   =   1/3R   +   1/3G   +   1/3B
--           (8 bit)    (8 bit)    (8 bit)   (8 bit)
--      Note: For divide in VHDL or Verilog 1/3 = 0.333333 => 1/4 + 1/16 + 1/64 = 0.328125
--However the data feed to RGB2DVI block needs 24 bit, this OUT 8 bit is going to be duplicated 3 times
--             RGB2DVI input =   OUT          &      OUT       &       OUT
--             (24 bit)       (8 bit) concatenate (8 bit) concatenate (8 bit)
--After Gray scale reduction, the data only need to be processed with 8 bit which have value ranging from  x"00" and X"FF"
------------------------------------------------------------------------------------------------------
GrayScale: 
if  switches = "0101"  then         
         vid_pData_process <= STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"00" & vid_pData(23 downto 18))) + unsigned (std_logic_vector'(b"0000" & vid_pData(23 downto 20))) + unsigned (std_logic_vector'(b"000000" & vid_pData(23 downto 22)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData(15 downto 10))) + unsigned (std_logic_vector'(b"0000" & vid_pData(15 downto 12))) + unsigned (std_logic_vector'(b"000000" & vid_pData(15 downto 14)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData( 7 downto  2))) + unsigned (std_logic_vector'(b"0000" & vid_pData( 7 downto  4))) + unsigned (std_logic_vector'(b"000000" & vid_pData( 7 downto  6)))
                                              )
                             & STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"00" & vid_pData(23 downto 18))) + unsigned (std_logic_vector'(b"0000" & vid_pData(23 downto 20))) + unsigned (std_logic_vector'(b"000000" & vid_pData(23 downto 22)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData(15 downto 10))) + unsigned (std_logic_vector'(b"0000" & vid_pData(15 downto 12))) + unsigned (std_logic_vector'(b"000000" & vid_pData(15 downto 14)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData( 7 downto  2))) + unsigned (std_logic_vector'(b"0000" & vid_pData( 7 downto  4))) + unsigned (std_logic_vector'(b"000000" & vid_pData( 7 downto  6)))
                                              )
                             & STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"00" & vid_pData(23 downto 18))) + unsigned (std_logic_vector'(b"0000" & vid_pData(23 downto 20))) + unsigned (std_logic_vector'(b"000000" & vid_pData(23 downto 22)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData(15 downto 10))) + unsigned (std_logic_vector'(b"0000" & vid_pData(15 downto 12))) + unsigned (std_logic_vector'(b"000000" & vid_pData(15 downto 14)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData( 7 downto  2))) + unsigned (std_logic_vector'(b"0000" & vid_pData( 7 downto  4))) + unsigned (std_logic_vector'(b"000000" & vid_pData( 7 downto  6)))
                                              );                                         
 
end if GrayScale;


BlacknWhite:if  switches = "0110"  then         
         if STD_LOGIC_VECTOR(unsigned(b"00" & vid_pData(23 downto 18)) + unsigned (b"00000" & vid_pData(23 downto 21)) + unsigned (b"000000" & vid_pData(23 downto 22))
                               + unsigned(b"0000" & vid_pData(15 downto 12)) + unsigned (b"00000" & vid_pData(15 downto 13)) + unsigned (b"000000" & vid_pData(15 downto 14)) + unsigned (b"0000000" & vid_pData(15 downto 15))
                               + unsigned(b"0"  & vid_pData( 7 downto  1)) + unsigned (b"0000" & vid_pData( 7 downto  4)) + unsigned (b"000000" & vid_pData( 7 downto 6)) + unsigned (b"0000000" & vid_pData( 7 downto 7))
                                ) >= x"8F"
          then 
           vid_pData_process <= x"FF" & x"FF" & x"FF";
          else
           vid_pData_process <= x"00" & x"00" & x"00";                         
          end if;
end if BlacknWhite;


Differentiate:if  switches = "0111"  then         
                   if STD_LOGIC_VECTOR(unsigned(BnW(7 downto 0)) - unsigned(BnW_buf(7 downto 0))) = x"00" then
  vid_pData_process <= x"FF" & x"FF" & x"FF";
  else
   vid_pData_process <= x"00" & x"00" & x"00";
end if;                              
end if Differentiate;



----------------------------------------------------------------------------------
-- Divide the output screen by 4, so that 4 processing method can be displayed at 1 time
-- this boost the ability to show results. This can be boost to even 8 or 16.
-- The orders of display and used algorithm is 
--                         1/4: Left Upper : Gray scale - manual
--                         2/4: Right Upper : Passthrough
--                         3/4: Left Bottom : Black and White
--                         4/4: Right Bottom : Gray scale - use the generate version
-- This is the default of divide by 4, for re-use, just copy the below and change the
-- necessary algorithm in each quater 
----------------------------------------------------------------------------------
Divideby4_default: if  switches = "1000"  then
--         1/4: Left Upper :Gray scale - manual
         The_1_4:if Hcount <= Hsize/2 and VCount <= Vsize/2 then
         -- Algorithm for the first quater 1_4 start from below
         vid_pData_process <= STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"00" & vid_pData(23 downto 18))) + unsigned (std_logic_vector'(b"0000" & vid_pData(23 downto 20))) + unsigned (std_logic_vector'(b"000000" & vid_pData(23 downto 22)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData(15 downto 10))) + unsigned (std_logic_vector'(b"0000" & vid_pData(15 downto 12))) + unsigned (std_logic_vector'(b"000000" & vid_pData(15 downto 14)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData( 7 downto  2))) + unsigned (std_logic_vector'(b"0000" & vid_pData( 7 downto  4))) + unsigned (std_logic_vector'(b"000000" & vid_pData( 7 downto  6)))
                                              )
                            & STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"00" & vid_pData(23 downto 18))) + unsigned (std_logic_vector'(b"0000" & vid_pData(23 downto 20))) + unsigned (std_logic_vector'(b"000000" & vid_pData(23 downto 22)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData(15 downto 10))) + unsigned (std_logic_vector'(b"0000" & vid_pData(15 downto 12))) + unsigned (std_logic_vector'(b"000000" & vid_pData(15 downto 14)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData( 7 downto  2))) + unsigned (std_logic_vector'(b"0000" & vid_pData( 7 downto  4))) + unsigned (std_logic_vector'(b"000000" & vid_pData( 7 downto  6)))
                                              )
                            & STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"00" & vid_pData(23 downto 18))) + unsigned (std_logic_vector'(b"0000" & vid_pData(23 downto 20))) + unsigned (std_logic_vector'(b"000000" & vid_pData(23 downto 22)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData(15 downto 10))) + unsigned (std_logic_vector'(b"0000" & vid_pData(15 downto 12))) + unsigned (std_logic_vector'(b"000000" & vid_pData(15 downto 14)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData( 7 downto  2))) + unsigned (std_logic_vector'(b"0000" & vid_pData( 7 downto  4))) + unsigned (std_logic_vector'(b"000000" & vid_pData( 7 downto  6)))
                                              );                                            
           end if The_1_4;
          
--        2/4: Right Upper : passthrough
          The_2_4:if Hcount > Hsize/2 and VCount < Vsize/2 then
          -- Algorithm for the second quater 2_4 start from below
          vid_pData_process <= vid_pData;
          end if The_2_4;
          
--        3/4: Left Bottom : Black and White     
          The_3_4:if Hcount < Hsize/2 and VCount > Vsize/2 then
          -- Algorithm for the third quater 3_4 start from below
         if ave_buf_BnW(7 downto 0) = ave_buf_BnW(15 downto 8) and ave_buf_BnW(23 downto 16) = ave_buf_BnW(7 downto 0) then  
                      vid_pData_process <= ave_buf_BnW(23 downto 16)  & ave_buf_BnW(23 downto 16)  & ave_buf_BnW(23 downto 16) ;
                      else
          --            vid_pData_process <= not ave_buf_BnW(7 downto 0) & not ave_buf_BnW(7 downto 0) & not ave_buf_BnW(7 downto 0);
                      vid_pData_process <= ave_buf_BnW(7 downto 0) & ave_buf_BnW(7 downto 0) & ave_buf_BnW(7 downto 0);  
          end if;
end if The_3_4;

--        4/4: Right Bottom : Gray scale - use the generated version        
          The_4_4:if Hcount >= Hsize/2 and VCount >= Vsize/2 then
          -- Algorithm for the fourth quater 4_4 start from below
          vid_pData_process <= GS1 &  GS1 & GS1;                   
          end if The_4_4;    
end if Divideby4_default;


Divideby4_GS: if  switches = "1001"  then
--         1/4: Left Upper : Gray scale type 1
         The_GS1_4:if Hcount <= Hsize/2 and VCount <= Vsize/2 then
         -- Algorithm for the first quater 1_4 start from below
            
            vid_pData_process <= GS1 &  GS1 & GS1; 
           end if The_GS1_4;
          
--        2/4: Right Upper: Gray scale type 2
          The_GS2_4:if Hcount > Hsize/2 and VCount < Vsize/2 then
          -- Algorithm for the second quater 2_4 start from below
           vid_pData_process <= GS2 &  GS2 & GS2;

          end if The_GS2_4;
          
--        3/4: Left Bottom: Gray scale type 3     
          The_GS3_4:if Hcount < Hsize/2 and VCount > Vsize/2 then
          -- Algorithm for the third quater 3_4 start from below
          vid_pData_process <= GS3 &  GS3 & GS3;
          
          end if The_GS3_4;

--        4/4: Right Bottom: BnW          
          The_GS4_4:if Hcount >= Hsize/2 and VCount >= Vsize/2 then
          -- Algorithm for the fourth quater 4_4 start from below
          vid_pData_process <=  BnW &  BnW & BnW;
                         
          end if The_GS4_4;    
end if Divideby4_GS;


Divideby4_average2pixel_diff2pixel: if  switches = "1010"  then
         
--         1/4: Left Upper : average the 2 pixel next together after Black and White
         The_A1_4:if Hcount <= Hsize/2 and VCount <= Vsize/2 then
         -- Algorithm for the first quater 1_4 start from below
            
            vid_pData_process <= STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"0" & BnW(7 downto 1))) + unsigned(std_logic_vector'(b"0" & BnW_buf(7 downto 1))))
                              &  STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"0" & BnW(7 downto 1))) + unsigned(std_logic_vector'(b"0" & BnW_buf(7 downto 1))))
                              &  STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"0" & BnW(7 downto 1))) + unsigned(std_logic_vector'(b"0" & BnW_buf(7 downto 1)))); 
           end if The_A1_4;
          
--        2/4: Right Upper: average the 2 pixel next together after Gray Scale
          The_A2_4:if Hcount > Hsize/2 and VCount < Vsize/2 then
          -- Algorithm for the second quater 2_4 start from below
           vid_pData_process <= STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"0" & GS1(7 downto 1))) + unsigned(std_logic_vector'(b"0" & GS_buf(7 downto 1))))
                             &  STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"0" & GS1(7 downto 1))) + unsigned(std_logic_vector'(b"0" & GS_buf(7 downto 1))))
                             &  STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"0" & GS1(7 downto 1))) + unsigned(std_logic_vector'(b"0" & GS_buf(7 downto 1))));

          end if The_A2_4;
          
--        3/4: Left Bottom Differentiate the 2 pixel next together after BnW      
          The_A3_4:if Hcount < Hsize/2 and VCount > Vsize/2 then
          --just differentiate
          -- Algorithm for the third quater 3_4 start from below
          if STD_LOGIC_VECTOR(unsigned(BnW(7 downto 0)) - unsigned(BnW_buf(7 downto 0))) = x"00" then

            vid_pData_process <= x"FF" & x"FF" & x"FF";
            else
             vid_pData_process <= x"00" & x"00" & x"00";
             end if;

          end if The_A3_4;

--        4/4: Right Bottom: Differentiate the 2 pixel next together after Gray scale          
          The_A4_4:if Hcount >= Hsize/2 and VCount >= Vsize/2 then
          -- Algorithm for the fourth quater 4_4 start from below
            if STD_LOGIC_VECTOR(unsigned(GS1(7 downto 0)) - unsigned(GS_buf(7 downto 0))) >= x"96" then
             vid_pData_process <= x"00" & x"00" & x"00";
             else
             vid_pData_process <= x"FF" & x"FF" & x"FF";   
             end if;       
          end if The_A4_4;    
end if Divideby4_average2pixel_diff2pixel;


Divideby4_show_edge_XOR_2pixel: if  switches = "1011"  then
--         1/4: Left Upper : Show edge with combination of XOR GS and XOR BnW
         The_AL1_4:if Hcount <= Hsize/2 and VCount <= Vsize/2 then
         -- Algorithm for the first quater 1_4 start from below
            
           vid_pData_process <= ((ave_buf_BnW(7 downto 0) xor ave_buf_BnW(15 downto 8)) or (GS1(7 downto 0) xor GS_buf(7 downto 0)))
                             &   ((ave_buf_BnW(7 downto 0) xor ave_buf_BnW(15 downto 8)) or (GS1(7 downto 0) xor GS_buf(7 downto 0)))
                             & ((ave_buf_BnW(7 downto 0) xor ave_buf_BnW(15 downto 8)) or (GS1(7 downto 0) xor GS_buf(7 downto 0)));
          end if The_AL1_4;
          
--        2/4: Right Upper:Grayscale 
          The_AL2_4:if Hcount > Hsize/2 and VCount < Vsize/2 then
          -- Algorithm for the second quater 2_4 start from below
          vid_pData_process <= ((ave_buf_BnW(7 downto 0) xor ave_buf_BnW(23 downto 16)) or (GS1(7 downto 0) xor GS_buf(7 downto 0)))
                              & ((ave_buf_BnW(7 downto 0) xor ave_buf_BnW(23 downto 16)) or (GS1(7 downto 0) xor GS_buf(7 downto 0)))
                              & ((ave_buf_BnW(7 downto 0) xor ave_buf_BnW(23 downto 16)) or (GS1(7 downto 0) xor GS_buf(7 downto 0)));
                   
          end if The_AL2_4;
          
--        3/4: Left Bottom  Xor the 2 pixel next together after Black and White
          The_AL3_4:if Hcount < Hsize/2 and VCount > Vsize/2 then
          -- Algorithm for the third quater 3_4 start from below
            
            vid_pData_process <= (ave_buf_BnW(7 downto 0) xor ave_buf_BnW(15 downto 8))
                                & (ave_buf_BnW(7 downto 0) xor ave_buf_BnW(15 downto 8)) 
                                & (ave_buf_BnW(7 downto 0) xor ave_buf_BnW(15 downto 8)); 
            
          end if The_AL3_4;

--        4/4: Right Bottom: xor the 2 pixel next together after Gray scale          
          The_AL4_4:if Hcount >= Hsize/2 and VCount >= Vsize/2 then
          -- Algorithm for the fourth quater 4_4 start from below        
          vid_pData_process <=  (GS1(7 downto 0) xor GS_buf(7 downto 0))
                                & (GS1(7 downto 0) xor GS_buf(7 downto 0))
                                & (GS1(7 downto 0) xor GS_buf(7 downto 0));
                         
          end if The_AL4_4;    
end if Divideby4_show_edge_XOR_2pixel;

Edge_showing_by_differentiate: if  switches = "1100"  then         
          vid_pData_process <= STD_LOGIC_VECTOR(unsigned(BnW(7 downto 0)) - unsigned(BnW_buf(7 downto 0)))
                            &  STD_LOGIC_VECTOR(unsigned(BnW(7 downto 0)) - unsigned(BnW_buf(7 downto 0)))
                            &  STD_LOGIC_VECTOR(unsigned(BnW(7 downto 0)) - unsigned(BnW_buf(7 downto 0)));                             
end if Edge_showing_by_differentiate;

Edge_showing_by_XOR:if  switches = "1101"  then         
          vid_pData_process <= ((ave_buf_BnW(7 downto 0) xor ave_buf_BnW(15 downto 8)) or (GS1(7 downto 0) xor GS_buf(7 downto 0)))
                           &   ((ave_buf_BnW(7 downto 0) xor ave_buf_BnW(15 downto 8)) or (GS1(7 downto 0) xor GS_buf(7 downto 0)))
                           & ((ave_buf_BnW(7 downto 0) xor ave_buf_BnW(15 downto 8)) or (GS1(7 downto 0) xor GS_buf(7 downto 0)));                                
end if Edge_showing_by_XOR;


Divideby4_Cut_1_channel: if  switches = "1110"  then
--         1/4: Left Upper : Cut RED
         The_C1_4:if Hcount <= Hsize/2 and VCount <= Vsize/2 then
         -- Algorithm for the first quater 1_4 start from below
           vid_pData_process <= x"00" & vid_pData(15 downto 8) & vid_pData(7 downto 0);   
           end if The_C1_4;
          
--        2/4: Right Upper:Cut BLUE 
          The_C2_4:if Hcount > Hsize/2 and VCount < Vsize/2 then
          -- Algorithm for the second quater 2_4 start from below
         vid_pData_process <= vid_pData(23 downto 16) & x"00" & vid_pData(7 downto 0);
          

          end if The_C2_4;
          
--        3/4: Left Bottom  Cut GREEN
          The_C3_4:if Hcount < Hsize/2 and VCount > Vsize/2 then
          -- Algorithm for the third quater 3_4 start from below            
           vid_pData_process <= vid_pData(23 downto 16) & vid_pData(15 downto 8) & x"00";
            
          end if The_C3_4;

--        4/4: Right Bottom: xor the 2 pixel next together after Gray scale          
          The_C4_4:if Hcount >= Hsize/2 and VCount >= Vsize/2 then
          -- Algorithm for the fourth quater 4_4 start from below        
          vid_pData_process <= vid_pData(23 downto 16) & vid_pData(15 downto 8) & vid_pData(7 downto 0);
          end if The_C4_4;    
end if Divideby4_Cut_1_channel;

end if;
end process Processing_method;

Count_the_Pixel: process(PixelClk)
begin
if (rising_edge(PixelClk)) then
    end_of_frame: if vid_pHSync = pol_Hsync and vid_pVSync = pol_Vsync then
        Hcount <= 0;
        Vcount <= 0;
        Ave_count <= 0;
    else
        if vid_pVDE = '1' then
            count_normal:if Vcount <= VSize - 2 then
                if Hcount <= HSize - 2 then
                Hcount <= Hcount + 1;
                Ave_count <= Ave_count + 1;
                else
                Hcount <= 0;
                Vcount <= Vcount + 1;    
                end if;
            else
            Hcount <= 0;
            Vcount <= 0;
            end if count_normal;
        end if;
    end if end_of_frame;
--    Vdata_V_buf(Hcount)(Vcount) <= GS;
end if Count_the_Pixel;
end process Count_the_Pixel;

Buffer_for_average_GS: process (PixelClk)
begin
if rising_edge(PixelClk) then
case Ave_count is
when 0 => ave_buf_GS(23 downto 16) <= STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"00" & vid_pData(23 downto 18))) + unsigned (std_logic_vector'(b"0000" & vid_pData(23 downto 20))) + unsigned (std_logic_vector'(b"000000" & vid_pData(23 downto 22)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData(15 downto 10))) + unsigned (std_logic_vector'(b"0000" & vid_pData(15 downto 12))) + unsigned (std_logic_vector'(b"000000" & vid_pData(15 downto 14)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData( 7 downto  2))) + unsigned (std_logic_vector'(b"0000" & vid_pData( 7 downto  4))) + unsigned (std_logic_vector'(b"000000" & vid_pData( 7 downto  6)))
                                              );
when 1 => ave_buf_GS(15 downto 8) <= STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"00" & vid_pData(23 downto 18))) + unsigned (std_logic_vector'(b"0000" & vid_pData(23 downto 20))) + unsigned (std_logic_vector'(b"000000" & vid_pData(23 downto 22)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData(15 downto 10))) + unsigned (std_logic_vector'(b"0000" & vid_pData(15 downto 12))) + unsigned (std_logic_vector'(b"000000" & vid_pData(15 downto 14)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData( 7 downto  2))) + unsigned (std_logic_vector'(b"0000" & vid_pData( 7 downto  4))) + unsigned (std_logic_vector'(b"000000" & vid_pData( 7 downto  6)))
                                              );
when others => ave_buf_GS(7 downto 0) <= STD_LOGIC_VECTOR(unsigned(std_logic_vector'(b"00" & vid_pData(23 downto 18))) + unsigned (std_logic_vector'(b"0000" & vid_pData(23 downto 20))) + unsigned (std_logic_vector'(b"000000" & vid_pData(23 downto 22)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData(15 downto 10))) + unsigned (std_logic_vector'(b"0000" & vid_pData(15 downto 12))) + unsigned (std_logic_vector'(b"000000" & vid_pData(15 downto 14)))
                                             + unsigned(std_logic_vector'(b"00" & vid_pData( 7 downto  2))) + unsigned (std_logic_vector'(b"0000" & vid_pData( 7 downto  4))) + unsigned (std_logic_vector'(b"000000" & vid_pData( 7 downto  6)))
                                              );
end case;
end if;
end process Buffer_for_average_GS;


Buffer_for_Binary_average: process (PixelClk)
begin
if rising_edge(PixelClk) then
case Ave_count is
when 0 => ave_buf_BnW(23 downto 16) <= BnW;
when 1 => ave_buf_BnW(15 downto 8) <= BnW;
when others => ave_buf_BnW(7 downto 0) <= BnW;
end case;
end if;
end process Buffer_for_Binary_average;


FrameBUF: if kFrameBuf generate
    FrameBufX: entity work.FrameBuf
    port map
    (
      Hcount => Hcount,
      Vcount => Vcount,
      HSize => HSize,
      VSize => VSize,
      Vdatathis => GS1,
      
       
      Vdata_past_1_this => Vdata_past_1_this,
      Vdata_past_1_up => Vdata_past_1_up,
      Vdata_past_1_down => Vdata_past_1_down,
      Vdata_past_1_left => Vdata_past_1_left,
      Vdata_past_1_right => Vdata_past_1_right 
    );
end generate FrameBUF;

--Average_BnW:if kAverage_BnW generate
--averageBnW: entity work.average
--    generic map(
--    kStage => 2)
--    port map
--    (
--    Sample_Clk => PixelClk,
--    Vdata => BnW,
--    Videodata_ave => BnW_ave
--    );
--    end generate Average_BnW;
    
    
    
--Average_GS:if kAverage_GS generate
--averageGS: entity work.average
--        generic map(
--        kStage => 2)
--        port map
--        (
--        Sample_Clk => PixelClk,
--        Vdata => GS3,
--        Videodata_ave => GS3_ave
--        );
--        end generate Average_GS;
----------------------------------------------------------------------------------
-- Generate a gray scale and black n white from the RGB 
--Because the ability to save processing effort when process on gray scale or
-- Black n white image compare to RGB image. A parallel version of Gray scale and
-- Black n white image is generated and ready for using.
-- After Gray scale reduction, the data only need to be processed with 8 bit which have value ranging from  x"00" and X"FF"
-- After Black n White reduction, the data only need to be processed with 8 bit which only have 2 value x"00" and X"FF"
-- Black n White threshold is set to x"8F",  every grayscale pixel >= x"8F" is considered White
--                                           every grayscale pixel >= x"8F" is considered Black
-- The threshold can be changed by going to BlacknWhite.vhd file                                        
----------------------------------------------------------------------------------
Blacknwhite_generator:if KGenerateBnW generate
    BlacknwhiteX:entity work.BlacknWhite
    port map
    (
    PixelClk => PixelClk,
    RGBVideodata => vid_pData,
    GSVideodata1 => GS1,
    GSVideodata2 => GS2,
    GSVideodata3 => GS3,
    BnWVideodata => BnW
    );
end generate Blacknwhite_generator;  

----------------------------------------------------------------------------------
-- Re-buffer not only PixelClk but also SerialClk with a BUFG so that both can reach
-- the whole device, unlike through a BUFR (only regional)
-- Since BUFG introduces a delay on the clock path, pixel data is
-- re-timing with the PixelClk here.
----------------------------------------------------------------------------------
GenerateBUFG_SerialClk: if (kAddPUBG_Serial) generate
   ResyncToBUFG_SerialCLK_X: entity work.ResyncToBUFG_SerialCLK
      port map (
         -- Video in
         piData => vid_pData_process,
         piVDE => vid_pVDE,
         piHSync => vid_pHSync,
         piVSync => vid_pVSync,
         PixelClkIn => PixelClk,
         SerialClkIN => SerialClk, -- fast 5x pixel clock for advanced use only
         -- Video out
         poData => vid_pData_out,
         poVDE => vid_pVDE_out,
         poHSync => vid_pHSync_out,
         poVSync => vid_pVSync_out,
         PixelClkOut => PixelClk_out,
         SerialClkOut => SerialClk_out -- fast 5x pixel clock for advanced use only
      );
end generate GenerateBUFG_SerialClk;


----------------------------------------------------------------------------------
-- Not buffer anything - the signal may not able to reach other region of the board
-- Or the signal may not be timing with PixelClk, which may introduce a skew between
-- video data and PixelClk, which result in the wrong result is display or nothing
-- is displayed at all
----------------------------------------------------------------------------------
DontGenerateBUFG_SerialClk:if (not kAddPUBG_Serial) generate
      vid_pData_out <= vid_pData_process;
      vid_pVDE_out <= vid_pVDE;
      vid_pHSync_out <= vid_pHSync;
      vid_pVSync_out <= vid_pVSync;
      PixelClk_out <= PixelClk;
      SerialClk_out <= SerialClk;      
end generate DontGenerateBUFG_SerialClk;


end Behavioral;
