----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.07.2018 10:07:32
-- Design Name: 
-- Module Name: system_rgb_processing_0_0 - Behavioral
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

entity system_rgb_processing_0_0 is
  Generic(
  kAddPUBG_Serial: BOOLEAN:= true
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
end system_rgb_processing_0_0;

architecture system_rgb_processing_0_0_arch of system_rgb_processing_0_0 is
    component rgb_processing is
    port
    (
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
    end component rgb_processing;
begin
U0: rgb_processing
    port map
    (
     --Input signal
           vid_pData => vid_pData,
           vid_pVDE => vid_pVDE,
           vid_pHSync => vid_pHSync,
           vid_pVSync => vid_pVSync,
           PixelClk => PixelClk,
           SerialClk => SerialClk,
       
           --Output signal
           vid_pData_out => vid_pData_out,
           vid_pVDE_out => vid_pVDE_out,
           vid_pHSync_out => vid_pHSync_out,
           vid_pVSync_out => vid_pVSync_out,
           PixelClk_out => PixelClk_out,
           SerialClk_out => SerialClk_out,
      
           --switch for choosing the manipulation method
            sw1 => sw1,
            sw2 => sw2,
            sw3 => sw3,
            sw4 => sw4
    );



end system_rgb_processing_0_0_arch;
