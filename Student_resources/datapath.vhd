----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Antonio Andara Lara, Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Design Name: DATAPATH FOR THE CPU
-- Module Name: cpu - structural(datapath)
-- Description: CPU_PART 1 OF LAB 3 - ECE 410 (2021)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments:
--*********************************************************************************
-- datapath top level module that maps all the components used inside of it
-----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_misc.ALL;
USE ieee.numeric_std.ALL;

ENTITY datapath IS
    PORT (  clock       : in std_logic;
            reset       : in std_logic;
            user_input  : in std_logic_vector(15 downto 0);
            immediate   : in STD_LOGIC_VECTOR(15 DOWNTO 0);
            mux4_sel    : in STD_LOGIC_VECTOR(1 DOWNTO 0);
            acc0_write  : in std_logic;
            acc_mux_sel : in std_logic;
            rf_address  : in std_logic_vector(2 downto 0);
            rf_mode     : in std_logic;
            rf_write    : in std_logic;
            output_en   : in std_logic;
            alu1_sel    : in std_logic_vector(3 downto 0);
            alu1_amt    : in std_logic_vector(3 downto 0);
            alu_mux_sel : in std_logic;
            acc1_write  : in std_logic;
            alu0_sel    : in std_logic_vector(3 downto 0);
            alu0_amt    : in std_logic_vector(3 downto 0);
            zero_flag   : out std_logic;
            postiv_flag : out std_logic;
            of0_flag    : out std_logic;
            of1_flag    : out std_logic;
            output_bus  : out std_logic_vector(15 downto 0)
             );
END datapath;

ARCHITECTURE Structural OF datapath IS
    ---------------------------------------------------------------------------
    SIGNAL alu0_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL alu1_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL acc0_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL acc1_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
--    SIGNAL rf0_in       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf1_in       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf0_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf1_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL input_mux_out: STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL alu_mux_out  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL acc_mux_out  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    ---------------------------------------------------------------------------
BEGIN
    -- Instantiate all components here
    input_mux4 : entity work.mux4(Dataflow)
        port map (
            in0 => alu0_out, 
            in1 =>rf0_out,
            in2 => immediate,
            in3 => user_input,
            mux_sel => mux4_sel,
            mux_out => input_mux_out
        );

    acc_mux : entity work.mux2(Dataflow)
        port map (
            in0      => acc0_out,
            in1      => acc1_out,
            mux_sel  => acc_mux_sel,
            mux_out  => rf1_in        
        );

    alu_mux : entity work.mux2(Dataflow)
        port map (
            in0      => rf1_out,
            in1      => acc0_out,
            mux_sel  => alu_mux_sel,
            mux_out  => alu_mux_out
        );

    accumulator0 : entity work.accumulator(Behavioral)
        port map(
            acc_in    => input_mux_out,
            acc_out   => acc0_out,
            acc_write => acc0_write,
            clock     => clock,
            reset     => reset
        );
    -- Connect output of accumulator to rf0_in
--    rf0_in <= acc0_out;
    
    -- Ask antonio why this is wrong
--    acc0_out <= rf0_in;
    
    
    accumulator1 : entity work.accumulator(Behavioral)
        port map(
            acc_in    => alu1_out,
            acc_out   => acc1_out,
            acc_write => acc1_write,
            clock     => clock,
            reset     => reset
        );

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

    alu0 : entity work.alu16(Dataflow)
        port map(
            A           => rf0_out,
            B           => alu_mux_out,
            shift_amt   => alu0_amt,
            alu_sel     => alu0_sel,
            alu_out     => alu0_out,
            of_flag     => of0_flag
        );

    alu1 : entity work.alu16(Dataflow)
        port map(
            A           => rf1_out,
            B           => acc0_out,
            shift_amt   => alu1_amt,
            alu_sel     => alu1_sel,
            alu_out     => alu1_out,
            of_flag     => of1_flag

        );

    tri_state_buffer : entity work.tri_state_buffer(Behavioral)
        port map(
            output_en     => output_en,
            buffer_input  => acc0_out,
            buffer_output => output_bus
        );
      
--      zero_flag <= '1' when input_mux_out = X"0000" else '0';
--      postiv_flag <= NOT input_mux_out(15);
      
    flags : PROCESS (input_mux_out)
    Begin
        -- logic for flags
        if acc0_write = '1' then
            if input_mux_out = X"0000" then
                zero_flag     <= '1';
            else 
                zero_flag     <= '0';
            end if;
            postiv_flag <= NOT input_mux_out(15);
        end if;
    END process;
    
    
END Structural;
