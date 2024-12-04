----------------------------------------------------------------------------------
-- Filename : mux_tb.vhdl
-- Author : Antonio Alejandro Andara Lara
-- Date : 31-Oct-2023
-- Design Name: mux_tb
-- Project Name: ECE 410 lab 3 2023
-- Description : testbench for the multiplexer of the simple CPU design
-- Revision 1.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments:
-- Copyright : University of Alberta, 2023
-- License : CC0 1.0 Universal
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux4_tb IS
END mux4_tb;

ARCHITECTURE sim OF mux4_tb IS

    SIGNAL in_0    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in_1    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in_2    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in_3    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mux_sel : STD_LOGIC_VECTOR(1 DOWNTO 0)  := "00";
    SIGNAL mux_out : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    UUT: entity work.mux4(Dataflow)
    port map (in_0, in_1, in_2, in_3, mux_sel, mux_out );
    stimulus : PROCESS
    BEGIN
        -- Setup test data

        --Should be 16 bits I think
        in_0     <= "0000000010101010";
        in_1     <= "0000000011001100";
        in_2     <= "0000000011110000";
        in_3     <= "0000000000001111";

        -- Select in_0
        mux_sel <= "00";
        WAIT FOR 20 ns;
        -- Assertion to check if output matches in0
        ASSERT (mux_out = in_0)
        REPORT "Mismatch for mux_sel = 00!"
            SEVERITY ERROR;

        -- Select in_1
        mux_sel <= "01";
        WAIT FOR 20 ns;
        -- Assertion to check if output matches in0
        ASSERT (mux_out = in_1)
        REPORT "Mismatch for mux_sel = 00!"
            SEVERITY ERROR;

        
        -- Select in_2
        mux_sel <= "10";
        WAIT FOR 20 ns;
        -- Assertion to check if output matches in0
        ASSERT (mux_out = in_1)
        REPORT "Mismatch for mux_sel = 00!"
            SEVERITY ERROR;

        --Select in_3
        mux_sel <= "11";
        WAIT FOR 20 ns;
        -- Assertion to check if output matches in0
        ASSERT (mux_out = in_2)
        REPORT "Mismatch for mux_sel = 00!"
            SEVERITY ERROR;


        
        -- End the test
        WAIT;
    END PROCESS stimulus;

END sim;
