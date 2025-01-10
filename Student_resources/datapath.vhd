----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Antonio Andara Lara, Shyama Gandhi, and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Design Name: Datapath for the CPU
-- Module Name: cpu - structural(datapath)
-- Description: Top-level module for CPU datapath for Part 1 of Lab 3 - ECE 410 (2021)
-- Revision History:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
--
-- Additional Comments:
-- - This module implements the structural datapath for the CPU.
-- - The datapath integrates multiplexers, accumulators, ALUs, and a register file.
-- - The output of the datapath is routed through a tri-state buffer.
-- - Flags are generated based on accumulator values (zero and positive flags).
-----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_misc.ALL;
USE ieee.numeric_std.ALL;

-- Entity Declaration: Interface definition for the datapath
ENTITY datapath IS
    PORT(
        clock       : IN std_logic;                       -- Clock signal
        reset       : IN std_logic;                       -- Asynchronous reset
        user_input  : IN std_logic_vector(15 DOWNTO 0);   -- External user input
        immediate   : IN std_logic_vector(15 DOWNTO 0);   -- Immediate value for operations
        mux4_sel    : IN std_logic_vector(1 DOWNTO 0);    -- Selection bits for 4:1 multiplexer
        acc0_write  : IN std_logic;                       -- Write enable for accumulator 0
        acc_mux_sel : IN std_logic;                       -- Selector for accumulator multiplexer
        rf_address  : IN std_logic_vector(2 DOWNTO 0);    -- Register file address
        rf_mode     : IN std_logic;                       -- Register file mode (single/dual)
        rf_write    : IN std_logic;                       -- Write enable for register file
        output_en   : IN std_logic;                       -- Enable signal for tri-state buffer
        alu1_sel    : IN std_logic_vector(3 DOWNTO 0);    -- ALU1 operation selector
        alu1_amt    : IN std_logic_vector(3 DOWNTO 0);    -- ALU1 shift amount
        alu_mux_sel : IN std_logic;                       -- Selector for ALU multiplexer
        acc1_write  : IN std_logic;                       -- Write enable for accumulator 1
        alu0_sel    : IN std_logic_vector(3 DOWNTO 0);    -- ALU0 operation selector
        alu0_amt    : IN std_logic_vector(3 DOWNTO 0);    -- ALU0 shift amount
        zero_flag   : OUT std_logic;                      -- Zero flag output
        postiv_flag : OUT std_logic;                      -- Positive flag output
        of0_flag    : OUT std_logic;                      -- Overflow flag for ALU0
        of1_flag    : OUT std_logic;                      -- Overflow flag for ALU1
        output_bus  : OUT std_logic_vector(15 DOWNTO 0)   -- Final CPU output bus
    );
END datapath;

-- Architecture Definition: Structural implementation of the datapath
ARCHITECTURE Structural OF datapath IS
    ---------------------------------------------------------------------------
    -- Internal signals connecting various components
    SIGNAL alu0_out     : STD_LOGIC_VECTOR(15 DOWNTO 0); -- ALU0 output
    SIGNAL alu1_out     : STD_LOGIC_VECTOR(15 DOWNTO 0); -- ALU1 output
    SIGNAL acc0_out     : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Accumulator 0 output
    SIGNAL acc1_out     : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Accumulator 1 output
    SIGNAL rf1_in       : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Input to register file (secondary)
    SIGNAL rf0_out      : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Register file output 0
    SIGNAL rf1_out      : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Register file output 1
    SIGNAL input_mux_out: STD_LOGIC_VECTOR(15 DOWNTO 0); -- 4:1 multiplexer output
    SIGNAL alu_mux_out  : STD_LOGIC_VECTOR(15 DOWNTO 0); -- ALU multiplexer output
    SIGNAL acc_mux_out  : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Accumulator multiplexer output
    ---------------------------------------------------------------------------
BEGIN
    -- 4:1 Multiplexer: Selects between ALU0, RF0, immediate, or user input
    input_mux4 : entity work.mux4(Dataflow)
        port map (
            in0      => alu0_out, 
            in1      => rf0_out,
            in2      => immediate,
            in3      => user_input,
            mux_sel  => mux4_sel,
            mux_out  => input_mux_out
        );

    -- 2:1 Multiplexer: Selects between outputs of accumulator 0 and accumulator 1
    acc_mux : entity work.mux2(Dataflow)
        port map (
            in0      => acc0_out,
            in1      => acc1_out,
            mux_sel  => acc_mux_sel,
            mux_out  => rf1_in        
        );

    -- 2:1 Multiplexer: Selects between register file output 1 and accumulator 0
    alu_mux : entity work.mux2(Dataflow)
        port map (
            in0      => rf1_out,
            in1      => acc0_out,
            mux_sel  => alu_mux_sel,
            mux_out  => alu_mux_out
        );

    -- Accumulator 0: Stores results and interfaces with the datapath
    accumulator0 : entity work.accumulator(Behavioral)
        port map(
            acc_in    => input_mux_out,
            acc_out   => acc0_out,
            acc_write => acc0_write,
            clock     => clock,
            reset     => reset
        );

    -- Accumulator 1: Secondary accumulator for parallel processing
    accumulator1 : entity work.accumulator(Behavioral)
        port map(
            acc_in    => alu1_out,
            acc_out   => acc1_out,
            acc_write => acc1_write,
            clock     => clock,
            reset     => reset
        );

    -- Register File: Holds data for processing, supporting dual read/write mode
    register_file : entity work.register_file(Behavioral)
        port map(
            clock      => clock,
            rf_write   => rf_write,
            rf_mode    => rf_mode,
            rf_address => rf_address,
            rf0_in     => acc0_out,
            rf1_in     => rf1_in,
            rf0_out    => rf0_out,
            rf1_out    => rf1_out
        );

    -- ALU0: Performs arithmetic/logical operations for primary datapath
    alu0 : entity work.alu16(Dataflow)
        port map(
            A           => rf0_out,
            B           => alu_mux_out,
            shift_amt   => alu0_amt,
            alu_sel     => alu0_sel,
            alu_out     => alu0_out,
            of_flag     => of0_flag
        );

    -- ALU1: Performs arithmetic/logical operations for parallel datapath
    alu1 : entity work.alu16(Dataflow)
        port map(
            A           => rf1_out,
            B           => acc0_out,
            shift_amt   => alu1_amt,
            alu_sel     => alu1_sel,
            alu_out     => alu1_out,
            of_flag     => of1_flag
        );

    -- Tri-state buffer: Controls output to the CPU's output bus
    tri_state_buffer : entity work.tri_state_buffer(Behavioral)
        port map(
            output_en     => output_en,
            buffer_input  => acc0_out,
            buffer_output => output_bus
        );

    -- Flags process: Generates zero and positive flags based on accumulator 0 input
    flags : PROCESS (input_mux_out)
    BEGIN
        if acc0_write = '1' then
            -- Zero flag: Asserted when accumulator 0 is zero
            if input_mux_out = X"0000" then
                zero_flag <= '1';
            else 
                zero_flag <= '0';
            end if;
            -- Positive flag: Asserted when the MSB of accumulator 0 is not set
            postiv_flag <= NOT input_mux_out(15);
        end if;
    END process;
END Structural;
