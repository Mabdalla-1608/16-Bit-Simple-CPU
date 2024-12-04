----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2024 11:32:37 AM
-- Design Name: 
-- Module Name: cpu_core_tb of Simulation
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

entity cpu_core_tb is
--  Port ( );
end cpu_core_tb;

architecture Simulation of cpu_core_tb is
    SIGNAL clock_tb         : STD_LOGIC                     := '0';
    SIGNAL reset_tb         : STD_LOGIC                     := '0';
    SIGNAL enter_tb         : STD_LOGIC                     := '0';
    SIGNAL user_input_tb    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL CPU_Output_tb    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_out_tb        : STD_LOGIC_VECTOR(4 DOWNTO 0)  := (OTHERS => '0');
    SIGNAL OPCODE_output_tb : STD_LOGIC_VECTOR(3 DOWNTO 0)  := (OTHERS => '0');
    SIGNAL done_tb          : STD_LOGIC;

begin

    uut : ENTITY work.cpu_core(Structural)
        PORT MAP(
              System_clock  => clock_tb
            , System_reset  => reset_tb
            , Enter         => enter_tb
            , user_Input    => user_input_tb
            , Done          => done_tb
            , CPU_Output    => CPU_Output_tb
            , PC_Output     => PC_out_tb
            , OPCODE_output => OPCODE_output_tb
        );
    user_input_tb <= X"0002";
    clk_process : PROCESS
        BEGIN
            WAIT FOR 4 ns;
            clock_tb <= NOT clock_tb;
        END PROCESS clk_process;

    stim_proc : PROCESS
        BEGIN
            -- Reset the system
            reset_tb <= '1';
            WAIT FOR 20 ns;
            reset_tb <= '0';
            WAIT FOR 20 ns;
            -- Start test
            enter_tb <= '1';
            WAIT;
        END PROCESS stim_proc;

end Simulation;
