----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Antonio Andara Lara, Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/28/2024 01:01:24 PM
-- Module Name: register_file_tb
-- Description: CPU LAB 3 - ECE 410 (2021)
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-----------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY register_file_tb IS
END register_file_tb;

ARCHITECTURE behavioral OF register_file_tb IS

    -- Signals for the UUT
    SIGNAL clock        : STD_LOGIC := '0';
    SIGNAL rf_write     : STD_LOGIC;
    SIGNAL mode         : STD_LOGIC;
    SIGNAL rf_address   : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL rf0_in       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf1_in       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf0_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf1_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);

    CONSTANT clk_period : TIME := 8 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: ENTITY WORK.register_file PORT MAP (
        clock      => clock,
        rf_write   => rf_write,
        rf_mode    => mode,
        rf_address => rf_address,
        rf0_in     => rf0_in,
        rf1_in     => rf1_in,
        rf0_out    => rf0_out,
        rf1_out    => rf1_out
    );

    -- Clock process
    clk_process : PROCESS
    BEGIN
        clock <= '0';
        WAIT FOR clk_period / 2;
        clock <= '1';
        WAIT FOR clk_period / 2;
    END PROCESS;

    -- Stimulus process
    stim_process : PROCESS
    BEGIN
        -- Test 1: Single Access Mode - Write and Read from Register 0
        rf_write   <= '1';                -- Enable write
        mode       <= '0';                -- Single access mode
        rf_address <= "000";              -- Address 0
        rf0_in     <= X"0003";            -- Input value for rf0
        WAIT FOR clk_period;

        rf_write   <= '0';                -- Disable write
        WAIT FOR clk_period * 2;          -- Wait for output update

        ASSERT (rf0_out = "0000000000000011") REPORT "Error: rf0_out should be 0000000000000011 in single access mode" SEVERITY ERROR;
        ASSERT (rf1_out = "0000000000000000") REPORT "Error: rf1_out should be 0000000000000000 in single access mode" SEVERITY ERROR;

        -- Test 2: Dual Access Mode - Write to Register 1 and Paired Register 5
        rf_write   <= '1';                -- Enable write
        mode       <= '1';                -- Dual access mode
        rf_address <= "001";              -- Address 1
        rf0_in     <= X"0001";            -- Input value for rf0
        rf1_in     <= X"0004";            -- Input value for rf1
        WAIT FOR clk_period;

        rf_write   <= '0';                -- Disable write
        WAIT FOR clk_period * 2;          -- Wait for output update

        ASSERT (rf0_out = "0000000000000001") REPORT "Error: rf0_out should be 0000000000000011 in dual access mode" SEVERITY ERROR;
        ASSERT (rf1_out = "0000000000000100") REPORT "Error: rf1_out should be 0000000000000100 in dual access mode" SEVERITY ERROR;

        -- Test 3: Dual Access Mode - Write to Register 6 and Paired Register 2
        rf_write   <= '1';                -- Enable write
        rf_address <= "110";              -- Address 6
        rf0_in     <= X"AAAA";            -- Input value for rf0
        rf1_in     <= X"FF00";            -- Input value for rf1
        WAIT FOR clk_period;

        rf_write   <= '0';                -- Disable write
        WAIT FOR clk_period * 2;          -- Wait for output update

        ASSERT (rf0_out = "1010101010101010") REPORT "Error: rf0_out should be 1010101010101010 in dual access mode" SEVERITY ERROR;
        ASSERT (rf1_out = "1111111100000000") REPORT "Error: rf1_out should be 1111111100000000 in dual access mode" SEVERITY ERROR;

        -- Test 4: Dual Access Mode - Reading Only (No Write)
        rf_write   <= '0';                -- Disable write
        rf_address <= "001";              -- Address 1 (read previously written values)
        WAIT FOR clk_period * 2;

        ASSERT (rf0_out = "0000000000000001") REPORT "Error: rf0_out should be 0000000000000011 during read in dual access mode" SEVERITY ERROR;
        ASSERT (rf1_out = "0000000000000100") REPORT "Error: rf1_out should be 0000000000000100 during read in dual access mode" SEVERITY ERROR;

        -- Test 5: Single Access Mode - Write and Overwrite Register 0
        rf_write   <= '1';                -- Enable write
        mode       <= '0';                -- Single access mode
        rf_address <= "000";              -- Address 0
        rf0_in     <= X"F0F0"; -- New value for rf0
        WAIT FOR clk_period;

        rf_write   <= '0';                -- Disable write
        WAIT FOR clk_period * 2;

        ASSERT (rf0_out = "1111000011110000") REPORT "Error: rf0_out should be 1111000011110000 after overwrite in single access mode" SEVERITY ERROR;

       
    END PROCESS;

END behavioral;

