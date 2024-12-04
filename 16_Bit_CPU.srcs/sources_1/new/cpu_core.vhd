----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2024 01:10:49 PM
-- Design Name: 
-- Module Name: cpu_core - Behavioral
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

entity cpu_core is
    Port (  System_clock : in STD_LOGIC
          ; System_reset : in STD_LOGIC
          ; Enter        : in STD_LOGIC
          ; user_Input   : in STD_LOGIC_VECTOR (15 downto 0)
          ; Done         : out STD_LOGIC
          ; CPU_Output   : out STD_LOGIC_VECTOR (15 downto 0)
          ; PC_Output    : out STD_LOGIC_VECTOR (4 downto 0)
          ; OPCODE_output: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)

         );
end cpu_core;

architecture Structural of cpu_core is
 SIGNAL Zero          : STD_LOGIC                     := '0';
 SIGNAL Positiv       : STD_LOGIC                     := '0';
 SIGNAL OverFlow_0    : STD_LOGIC                     := '0';
 SIGNAL OverFlow_1    : STD_LOGIC                     := '0';
 SIGNAL internal_imm16: STD_LOGIC_VECTOR(15 downto 0) := (OTHERS => '0');
 SIGNAL MUX4_Sel      : STD_LOGIC_VECTOR (1 downto 0) := "00";
 SIGNAL ACC_MUX_Sel   : STD_LOGIC                     := '0';
 SIGNAL ALU_MUX_Sel   : STD_LOGIC                     := '0';
 SIGNAL ACC0_write    : STD_LOGIC                     := '0';
 SIGNAL ACC1_write    : STD_LOGIC                     := '0';
 SIGNAL rf_address    : STD_LOGIC_VECTOR(2 DOWNTO 0)  := (OTHERS => '0');
 SIGNAL rf_write      : STD_LOGIC                     := '0';
 SIGNAL rf_mode       : STD_LOGIC                     := '0';
 SIGNAL ALU_sel       : STD_LOGIC_VECTOR(3 DOWNTO 0)  := (OTHERS => '0');
 SIGNAL shift_amt     : STD_LOGIC_VECTOR(3 DOWNTO 0)  := (OTHERS => '0');
 SIGNAL output_ENa    : STD_LOGIC                     := '0';
--  SIGNAL PC_out       : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
--  SIGNAL OPCODE_output: STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

begin

--Instantiate Datapath
  Datapath: entity work.Datapath(Structural)
  port map( 
            clock       => System_clock
          , reset       => System_reset
          , user_input  => user_Input
          , immediate   => internal_imm16
          , mux4_sel    => MUX4_Sel
          , acc0_write  => ACC0_write
          , acc1_write  => ACC1_write
          , acc_mux_sel => ACC_MUX_Sel
          , rf_address  => rf_address
          , rf_mode     => rf_mode
          , rf_write    => rf_write
          , output_en   => output_ENa
          , alu0_sel    => ALU_sel
          , alu0_amt    => shift_amt
          , alu1_sel    => ALU_sel
          , alu1_amt    => shift_amt
          , alu_mux_sel => ALU_MUX_Sel
          , zero_flag   => Zero
          , postiv_flag => Positiv
          , of0_flag    => OverFlow_0
          , of1_flag    => OverFlow_1
          , output_bus  => CPU_Output
          );
      
    
  --Instintiate Controller
  controller: entity work.controller(Behavioral)
      port map( 
            clock          => System_clock
          , reset          => System_reset
          , enter          => Enter
          , zero_flag      => Zero
          , sign_flag      => Positiv
          , of0_flag       => OverFlow_0
          , of1_flag       => OverFlow_1
          , immediate_data => internal_imm16
          , mux_sel        => MUX4_Sel
          , acc_mux_sel    => ACC_MUX_Sel
          , alu_mux_sel    => ALU_MUX_Sel
          , acc0_write     => ACC0_write
          , acc1_write     => ACC1_write
          , rf_address     => rf_address
          , rf_write       => rf_write
          , rf_mode        => rf_mode
          , alu_sel        => ALU_sel
          , shift_amt      => shift_amt
          , output_en      => output_ENa
          , PC_out         => PC_Output
          , OPCODE_output  => OPCODE_output
          , done           => Done
          );
  
  

end Structural;
