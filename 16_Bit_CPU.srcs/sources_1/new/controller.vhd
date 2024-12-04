----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Updated Date: 01/11/2021
-- Design Name: CONTROLLER FOR THE CPU
-- Module Name: cpu - behavioral(controller)
-- Description: CPU_LAB 3 - ECE 410 (2021)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments:
--*********************************************************************************
-- The controller implements the states for each instructions and asserts appropriate control signals for the datapath during every state.
-- For detailed information on the opcodes and instructions to be executed, refer the lab manual.
-----------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY controller IS
    PORT( clock          : IN STD_LOGIC
        ; reset          : IN STD_LOGIC
        ; enter          : IN STD_LOGIC
        ; zero_flag      : IN STD_LOGIC
        ; sign_flag      : IN STD_LOGIC
        ; of0_flag       : IN STD_LOGIC
        ; of1_flag       : IN STD_LOGIC
        ; immediate_data : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0)
        ; mux_sel        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        ; acc_mux_sel    : OUT STD_LOGIC
        ; alu_mux_sel    : OUT STD_LOGIC
        ; acc0_write     : OUT STD_LOGIC
        ; acc1_write     : OUT STD_LOGIC
        ; rf_address     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        ; rf_write       : OUT STD_LOGIC
        ; rf_mode        : OUT STD_LOGIC
        ; alu_sel        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; shift_amt      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; output_en      : OUT STD_LOGIC
        ; PC_out         : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        ; OPCODE_output  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; done           : OUT STD_LOGIC
        );
END controller;

ARCHITECTURE Behavioral OF controller IS
    -- Instructions and their opcodes (pre-decided)
    CONSTANT OPCODE_INA  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    CONSTANT OPCODE_LDI  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    CONSTANT OPCODE_LDA  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    CONSTANT OPCODE_STA  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
    CONSTANT OPCODE_ADD  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT OPCODE_SUB  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
    CONSTANT OPCODE_CMPL : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
    CONSTANT OPCODE_SHFL : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
    CONSTANT OPCODE_INC  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    CONSTANT OPCODE_DEC  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
    CONSTANT OPCODE_AND  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011";
    CONSTANT OPCODE_SHFR : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";
    CONSTANT OPCODE_JMPZ : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
    CONSTANT OPCODE_OUTA : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
    CONSTANT OPCODE_HALT : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

    TYPE state_type IS ( STATE_FETCH
                       , STATE_DECODE
                       , STATE_INA
                       , STATE_LDI
                       , STATE_LDA
                       , STATE_STA
                       , STATE_ADD
                       , STATE_SUB
                       , STATE_CMPL
                       , STATE_SHFL
                       , STATE_INC
                       , STATE_DEC
                       , STATE_AND
                       , STATE_SHFR
                       , STATE_JMPZ
                       , STATE_OUTA
                       , STATE_HALT
                       );

    SIGNAL state : state_type;
    SIGNAL IR    : STD_LOGIC_VECTOR(15 DOWNTO 0); -- instruction register
    SIGNAL PC    : INTEGER RANGE 0 TO 31 := 0;    -- program counter
    SIGNAL SIMD  : STD_LOGIC;
    SIGNAL jump_address : STD_LOGIC_VECTOR(4 downto 0); --trial
    -- program memory that will store the instructions sequentially from part 1 and part 2 test program
    TYPE PM_BLOCK IS ARRAY(0 TO 31) OF STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

    --opcode is kept up-to-date
    OPCODE_output <= IR(7 DOWNTO 4);
    SIMD <= IR(15);

    PROCESS (reset, clock)
        -- "PM" is the program memory that holds the instructions to be executed by the CPU 
        VARIABLE PM     : PM_BLOCK;
        VARIABLE CMPL_conut : INTEGER RANGE 0 to 1 := 0; -- trial

        -- To STATE_DECODE the 4 MSBs from the PC content
        VARIABLE OPCODE : STD_LOGIC_VECTOR(3 DOWNTO 0);

    BEGIN
        IF (reset = '1') THEN -- RESET initializes all the control signals to 0.
            PC             <= 0;
            IR             <= (OTHERS => '0');
            PC_out         <= STD_LOGIC_VECTOR(to_unsigned(PC, PC_out'length));
            mux_sel        <= "00";
            alu_mux_sel    <= '0';
            acc_mux_sel    <= '0';
            immediate_data <= (OTHERS => '0');
            acc0_write     <= '0';
            acc1_write     <= '0';
            rf_address     <= "000";
            rf_write       <= '0';
            rf_mode        <= '0';
            alu_sel        <= "0000";
            output_en      <= '0';
            done           <= '0';
            shift_amt      <= "0000";
            
            state          <= STATE_FETCH;

            -- Test program for STA, LDI and INC
            PM(0)  := X"0010"; -- IN A
            PM(1)  := X"0041"; -- STA R[1], A
            PM(2)  := X"0031"; -- LDA A, R[1]
            PM(3)  := X"00A0"; -- DEC A
            PM(4)  := X"0041"; -- STA R[1], A -- will be the same used in PC(1)
            PM(5)  := X"00E0"; -- OUT A
            PM(6)  := X"0AD0"; -- JMPZ x0A
            PM(7)  := X"0020"; -- LDI A, x0000
            PM(8)  := X"0000"; -- x0000
            PM(9)  := X"02D0"; -- JMPZ x02
            PM(10) := X"0020"; -- LDI A, x000F -- you may use any 16-bit value
            PM(11) := X"000F"; -- x000F
            PM(12) := X"0041"; -- STA R[1]
            PM(13) := X"0020"; -- LDI xBABA
            PM(14) := X"BABA"; -- xBABA
            PM(15) := X"00B1"; -- AND A, R[1]
            PM(16) := X"00E0"; -- OUT A
            PM(17) := X"0090"; -- INC A
            PM(18) := X"0041"; -- STA R[1]
            PM(19) := X"0020"; -- LDI A, xDEAD
            PM(20) := X"DEAD"; -- xDEAD
            PM(21) := X"0051"; -- ADD A, R[1] 
            PM(22) := X"00E0"; -- OUT A
            PM(23) := X"0070"; -- CMPL      --TRIAL 
            PM(24) := X"0020"; -- LDI A, XD1ED
            PM(25) := X"D1ED"; -- xD1ED
            PM(26) := X"0044"; -- STA R[4], A
            PM(27) := X"0040"; -- STA R[0], A
            PM(28) := X"8030"; -- LDA R[0],R[4] into accumulators
            PM(29) := X"8035"; -- LDA R[5],R[1] into accumulators 0 and 1 respectively
            PM(30) := X"00F0"; -- HALT

        ELSIF RISING_EDGE(clock) THEN
            CASE state IS

                WHEN STATE_FETCH => -- FETCH instruction
                    IF enter = '1' THEN
                        PC_out         <= STD_LOGIC_VECTOR(to_unsigned(PC, PC_out'length));
--                        mux_sel        <= "00"; -- trial (uncomment)
                        alu_mux_sel    <= '1';
                        acc_mux_sel    <= '0';
                        immediate_data <= (OTHERS => '0');
                        acc0_write     <= '0';
                        acc1_write     <= '0';
                        rf_address     <= "000";
                        rf_write       <= '0';
                        rf_mode        <= '0';
                        alu_sel        <= "0010";
                        shift_amt      <= "0000";
                        done           <= '0';
                        IR             <= PM(PC);
                        PC             <= PC + 1;
--                        output_en      <= '0';
                        state          <= STATE_DECODE;

                    ELSIF  enter = '0' THEN
                        state <= STATE_FETCH;
                    END IF;

                WHEN STATE_DECODE => -- DECODE instruction

                    OPCODE := IR(7 DOWNTO 4);

                    CASE OPCODE IS
                        WHEN OPCODE_LDI  => state <= STATE_LDI ;
                        WHEN OPCODE_STA  => state <= STATE_STA ;
                        WHEN OPCODE_INC  => state <= STATE_INC ;
                        WHEN OPCODE_INA  => state <= STATE_INA ;
                        WHEN OPCODE_LDA  => state <= STATE_LDA ;
                        WHEN OPCODE_ADD  => state <= STATE_ADD ;
                        WHEN OPCODE_SUB  => state <= STATE_SUB ;
                        WHEN OPCODE_CMPL => state <= STATE_CMPL ;
                        WHEN OPCODE_SHFL => state <= STATE_SHFL ;
                        WHEN OPCODE_DEC  => state <= STATE_DEC ;
                        WHEN OPCODE_AND  => state <= STATE_AND ;
                        WHEN OPCODE_SHFR => state <= STATE_SHFR ;
                        WHEN OPCODE_JMPZ => state <= STATE_JMPZ ;
                        WHEN OPCODE_OUTA => state <= STATE_OUTA ;
                        WHEN OPCODE_HALT => state <= STATE_HALT ;
                        WHEN OTHERS      => state <= STATE_HALT ;
                    END CASE;

                    -----------------------------
                    -- multiplexer set up
--                    mux_sel        <= "00"; --trial (uncomment)
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    -----------------------------
                    -- accumulator setup
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    -----------------------------
                    -- register file setup
                    rf_address     <= IR(2 DOWNTO 0); -- decode pre-emptively sets up the register file
                    rf_write       <= '0';
                    rf_mode        <= IR(15); -- SIMD mode
                    -----------------------------
                    -- ALU setup
                    alu_sel        <= "0010"; -- Pass B
                    shift_amt      <= IR(3 DOWNTO 0);
                    -----------------------------
                    immediate_data <= PM(PC); -- pre-fetching immediate data
                    jump_address <= IR(12 downto 8); --trial
                    output_en      <= '0';
                    done           <= '0';

                WHEN STATE_LDI            => -- LDI exceute
                    mux_sel        <= "10";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    immediate_data <= PM(PC);
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    rf_address     <= "000";
                    rf_write       <= '0';
                    alu_sel        <= "0010";
                    output_en      <= '0';
                    done           <= '0';
                    PC             <= PC + 1; -- This is to skip the immediate and not decode it
                    state          <= STATE_FETCH;
                    
                WHEN STATE_INC            => --INC (increment) executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0111";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1';
                    acc1_write     <= '0';
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                    
                WHEN STATE_INA            => -- INA executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0000";
                    shift_amt      <= "0000";
                    mux_sel        <= "11";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    acc0_write     <= '1';
                    acc1_write     <= '0';
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;    
                    
                WHEN STATE_LDA            => -- LDA executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0001";
                    shift_amt      <= "0000";
                    mux_sel        <= "01";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    rf_address     <= IR(2 downto 0);
                    rf_write       <= '0';
                    output_en      <= '0';
                    rf_mode        <= SIMD;
                    done           <= '0';
                    state          <= STATE_FETCH;
                    
                    -- WHEN STATE_STA            => -- STA exceute
                    --     immediate_data <= (OTHERS => '0');
                    --     acc0_write     <= '0';
                    --     acc1_write     <= '0';
                    --     alu_sel        <= "0000";
                    --     mux_sel        <= "00";
                    --     rf_write       <= '1';
                    --     acc_mux_sel    <= '1';
                    --     alu_mux_sel    <= '0';
                    --     output_en      <= '0';
                    --     done           <= '0';
                    --     state          <= STATE_FETCH;

                WHEN STATE_STA            => -- STA executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0010";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '1';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    rf_address     <= IR(2 downto 0);
                    rf_write       <= '1';
                    rf_mode        <= SIMD;
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                    
                WHEN STATE_ADD            => -- ADD executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0101";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    rf_address     <= IR(2 downto 0);
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                    
                WHEN STATE_SUB            => -- SUB executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0110";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    rf_address     <= IR(2 downto 0);
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                    
                WHEN STATE_CMPL            => -- CMPL executes, load the 2's complement of number into ACC
                         immediate_data <= (OTHERS => '0');
                         alu_sel        <= "1100";
                         shift_amt      <= "0000";
                         mux_sel        <= "00";
                         acc_mux_sel    <= '0';
                         alu_mux_sel    <= '1';
                         acc0_write     <= '1';
                         acc1_write     <= SIMD;
                         rf_address     <= "000";
                         rf_write       <= '0';
                         output_en      <= '0';
                         done           <= '0';
                         state          <= STATE_INC;
                    
                WHEN STATE_SHFL           => -- SHFL executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0011";
                    shift_amt      <= IR(3 downto 0);
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                    
                WHEN STATE_DEC            => -- DEC executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "1000";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                    
                WHEN STATE_AND            => -- AND executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "1001";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    rf_address     <= IR(2 downto 0);
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                    
                WHEN STATE_SHFR            => -- SHFR executes
                     immediate_data <= (OTHERS => '0');
                     alu_sel        <= "0100";
                     shift_amt      <= IR(3 downto 0);
                     mux_sel        <= "00";
                     acc_mux_sel    <= '0';
                     alu_mux_sel    <= '1';
                     acc0_write     <= '1';
                     acc1_write     <= SIMD;
                     rf_address     <= "000";
                     rf_write       <= '0';
                     output_en      <= '0';
                     done           <= '0';
                     state          <= STATE_FETCH;
                    
                    --------------------------------------------
                    --  START EDITING HERE:
                    --------------------------------------------

                WHEN STATE_JMPZ           => -- JMPZ executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0000";
                    shift_amt      <= "0000";
--                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '0';
                    acc1_write     <= SIMD;
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    if (zero_flag = '1') then
--                        PC         <= to_integer(unsigned(IR(12 downto 8))) ; -- Check if this is right
                        PC <= to_integer(unsigned(jump_address)) ; --trial
                    end if;
                    state          <= STATE_FETCH;
                
                WHEN STATE_OUTA           => -- OUTA executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0010";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    acc0_write     <= '0';
                    acc1_write     <= SIMD;
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '1';
                    done           <= '0';
                    state          <= STATE_FETCH;
                
                WHEN STATE_HALT           => -- HALT executes
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0000";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '1';
                    state          <= STATE_HALT;

                WHEN OTHERS =>
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    immediate_data <= (OTHERS => '0');
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    rf_address     <= "000";
                    rf_write       <= '0';
                    alu_sel        <= "0000";
                    output_en      <= '0';
                    done           <= '1';
                    state          <= STATE_HALT;

            END CASE;
        END IF;
    END PROCESS;

END Behavioral;