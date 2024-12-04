----------------------------------------------------------------------------------
-- Filename : alu.vhdl
-- Author : Antonio Alejandro Andara Lara
-- Date : 31-Oct-2023
-- Design Name: alu_tb
-- Project Name: ECE 410 lab 3 2023
-- Description : testbench for the ALU of the simple CPU design
-- Revision 1.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments:
-- Copyright : University of Alberta, 2023
-- License : CC0 1.0 Universal
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE sim OF alu_tb IS
    SIGNAL alu_sel   : STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0000";
    SIGNAL input_a   : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL input_b   : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL shift_amt : STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0000";
    SIGNAL alu_out   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL of_flag   : STD_LOGIC := '0';

    -- Define constants for all ones and all zeros

    CONSTANT all_ones  : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '1');
    CONSTANT all_zeros : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN

    uut : ENTITY WORK.alu16(Dataflow)
        PORT MAP( alu_sel     => alu_sel
                , A           => input_a
                , B           => input_b
                , shift_amt   => shift_amt
                , alu_out     => alu_out
                , of_flag     => of_flag
                );

  stim_proc : PROCESS
    BEGIN
        -- Test Pass A (alu_sel = "0001")
        alu_sel <= "0001";
        input_a <= x"0064"; -- 100 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"0064"
            REPORT "Test failed: Pass A" SEVERITY ERROR;

        -- Test Pass B (alu_sel = "0010")
        alu_sel <= "0010";
        input_b <= x"0033"; -- 51 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"0033"
            REPORT "Test failed: Pass B" SEVERITY ERROR;

        -- Test Logical Shift Left (alu_sel = "0011")
        alu_sel <= "0011";
        input_a <= x"000A"; -- 10 in hex
        shift_amt <= "0001"; -- Shift by 1
        WAIT FOR 20 ns;
        ASSERT alu_out = x"0014" -- 20 in hex
            REPORT "Test failed: Logical shift left" SEVERITY ERROR;

        -- Test Logical Shift Right (alu_sel = "0100")
        alu_sel <= "0100";
        input_a <= x"0014"; -- 20 in hex
        shift_amt <= "0001"; -- Shift by 1
        WAIT FOR 20 ns;
        ASSERT alu_out = x"000A" -- 10 in hex
            REPORT "Test failed: Logical shift right" SEVERITY ERROR;

        -- Test Arithmetic Addition (alu_sel = "0101")
        alu_sel <= "0101";
        input_a <= x"003F"; -- 63 in hex
        input_b <= x"003F"; -- 63 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"007E" -- 126 in hex
            REPORT "Test failed: Addition" SEVERITY ERROR;
        ASSERT of_flag = '0'
            REPORT "Test failed: Addition overflow flag" SEVERITY ERROR;

        -- Test Arithmetic Subtraction (alu_sel = "0110")
        alu_sel <= "0110";
        input_a <= x"003F"; -- 63 in hex
        input_b <= x"001F"; -- 31 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"0020" -- 32 in hex
            REPORT "Test failed: Subtraction" SEVERITY ERROR;
        ASSERT of_flag = '0'
            REPORT "Test failed: Subtraction overflow flag" SEVERITY ERROR;

        -- Test Increment (alu_sel = "0111")
        alu_sel <= "0111";
        input_a <= x"0001"; -- 1 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"0002"
            REPORT "Test failed: Increment" SEVERITY ERROR;
        ASSERT of_flag = '0'
            REPORT "Test failed: Increment overflow flag" SEVERITY ERROR;
            
        -- Test Increment (alu_sel = "0111")
        alu_sel <= "0111";
        input_a <= x"ffff"; -- 1 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"0000"
            REPORT "Test failed: Increment with overflow" SEVERITY ERROR;
        ASSERT of_flag = '1'
            REPORT "Test failed: Increment with overflow overflow flag" SEVERITY ERROR;

        -- Test Decrement (alu_sel = "1000")
        alu_sel <= "1000";
        input_a <= x"0002"; -- 2 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"0001"
            REPORT "Test failed: Decrement" SEVERITY ERROR;
        ASSERT of_flag = '0'
            REPORT "Test failed: Decrement overflow flag" SEVERITY ERROR;

        -- Test Bitwise AND (alu_sel = "1001")
        alu_sel <= "1001";
        input_a <= x"0064"; -- 100 in hex
        input_b <= x"0033"; -- 51 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"0020" -- Result of 100 AND 51
            REPORT "Test failed: Bitwise AND" SEVERITY ERROR;

        -- Test Bitwise OR (alu_sel = "1010")
        alu_sel <= "1010";
        input_a <= x"0064"; -- 100 in hex
        input_b <= x"0033"; -- 51 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"0077" -- Result of 100 OR 51
            REPORT "Test failed: Bitwise OR" SEVERITY ERROR;

        -- Test Set Not A (alu_sel = "1011")
        alu_sel <= "1011";
        input_a <= x"000F"; -- 15 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"FFF0" -- NOT 15
            REPORT "Test failed: Set Not A" SEVERITY ERROR;

        -- Test Set Not B (alu_sel = "1100")
        alu_sel <= "1100";
        input_b <= x"000F"; -- 15 in hex
        WAIT FOR 20 ns;
        ASSERT alu_out = x"FFF0" -- NOT 15
            REPORT "Test failed: Set Not B" SEVERITY ERROR;

        -- Test Set 1 (alu_sel = "1101")
        alu_sel <= "1101";
        WAIT FOR 20 ns;
        ASSERT alu_out = x"0001"
            REPORT "Test failed: Set 1" SEVERITY ERROR;

        -- Test Set 0 (alu_sel = "1110")
        alu_sel <= "1110";
        WAIT FOR 20 ns;
        ASSERT alu_out = all_zeros
            REPORT "Test failed: Set 0" SEVERITY ERROR;

        -- Test Set -1 (alu_sel = "1111")
        alu_sel <= "1111";
        WAIT FOR 20 ns;
        ASSERT alu_out = all_ones
            REPORT "Test failed: Set -1" SEVERITY ERROR;

        -- Finish simulation
        WAIT;
    END PROCESS stim_proc;

END sim;
