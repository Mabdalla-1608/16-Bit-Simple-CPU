----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/25/2024 02:56:28 PM
-- Design Name: 
-- Module Name: mux2_tb - Behavioral
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

entity mux2_tb is
--  Port ( );
end mux2_tb;

architecture Testbench of mux2_tb is
    SIGNAL in_0_tb   : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in_1_tb    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mux_sel_tb : STD_LOGIC  := '0';
    SIGNAL mux_out_tb : STD_LOGIC_VECTOR(15 DOWNTO 0);
begin
    UUT: entity work.mux2(Dataflow)
    port map (
            in0 => in_0_tb
        ,   in1 => in_1_tb
        ,   mux_sel => mux_sel_tb
        ,   mux_out => mux_out_tb );
    stimulus : PROCESS
    BEGIN
        -- Setup test data

        --Should be 16 bits I think
        in_0_tb     <= "0000000010101010"; -- 0x00AA
        in_1_tb     <= "0000000011001100"; -- 0x00CC

        -- Select in_0
        mux_sel_tb <= '0';
        WAIT FOR 20 ns;
        -- Assertion to check if output matches in0
        ASSERT (mux_out_tb = in_0_tb)
        REPORT "Mismatch for mux_sel = 0!"
            SEVERITY ERROR;

        -- Select in_1
        mux_sel_tb <= '1';
        WAIT FOR 20 ns;
        -- Assertion to check if output matches in1
        ASSERT (mux_out_tb = in_1_tb)
        REPORT "Mismatch for mux_sel = 1!"
            SEVERITY ERROR;
            
        -- End the test
        WAIT;
    END PROCESS stimulus;

end Testbench;