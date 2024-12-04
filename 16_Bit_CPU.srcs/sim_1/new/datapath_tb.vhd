LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY datapath_tb IS
END datapath_tb;

ARCHITECTURE behavior OF datapath_tb IS

    COMPONENT datapath
        PORT (
            clock          : IN  STD_LOGIC;
            reset          : IN  STD_LOGIC;
            user_input     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            immediate      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            mux4_sel       : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            acc0_write     : IN  STD_LOGIC;
            acc_mux_sel    : IN  STD_LOGIC;
            rf_address     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            rf_mode        : IN  STD_LOGIC;
            rf_write       : IN  STD_LOGIC;
            output_en      : IN  STD_LOGIC;
            alu1_sel       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            alu1_amt       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            alu_mux_sel    : IN  STD_LOGIC;
            acc1_write     : IN  STD_LOGIC;
            alu0_sel       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            alu0_amt       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            
            zero_flag      : OUT STD_LOGIC;
            postiv_flag  : OUT STD_LOGIC;
            of0_flag       : OUT STD_LOGIC;
            of1_flag       : OUT STD_LOGIC;
            output_bus     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clock          : STD_LOGIC := '0';
    SIGNAL reset          : STD_LOGIC := '0';
    SIGNAL user_input     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL immediate      : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mux4_sel       : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL acc0_write     : STD_LOGIC := '0';
    SIGNAL acc_mux_sel    : STD_LOGIC := '0';
    SIGNAL rf_address     : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL rf_mode        : STD_LOGIC := '0';
    SIGNAL rf_write       : STD_LOGIC := '0';
    SIGNAL output_en      : STD_LOGIC := '0';
    SIGNAL alu1_sel       : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL alu1_amt       : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL alu_mux_sel    : STD_LOGIC := '0';
    SIGNAL acc1_write     : STD_LOGIC := '0';
    SIGNAL alu0_sel       : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL alu0_amt       : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL zero_flag      : STD_LOGIC;
    SIGNAL positive_flag  : STD_LOGIC;
    SIGNAL of0_flag       : STD_LOGIC;
    SIGNAL of1_flag       : STD_LOGIC;
    SIGNAL output_bus     : STD_LOGIC_VECTOR(15 DOWNTO 0);

    CONSTANT clock_period : TIME := 8 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: datapath
        PORT MAP (
            clock          => clock,
            reset          => reset,
            user_input     => user_input,
            immediate      => immediate,
            mux4_sel       => mux4_sel,
            acc0_write     => acc0_write,
            acc_mux_sel    => acc_mux_sel,
            rf_address     => rf_address,
            rf_mode        => rf_mode,
            rf_write       => rf_write,
            output_en      => output_en,
            alu1_sel       => alu1_sel,
            alu1_amt       => alu1_amt,
            alu_mux_sel    => alu_mux_sel,
            acc1_write     => acc1_write,
            alu0_sel       => alu0_sel,
            alu0_amt       => alu0_amt,
            zero_flag      => zero_flag,
            postiv_flag  => positive_flag,
            of0_flag       => of0_flag,
            of1_flag       => of1_flag,
            output_bus     => output_bus
        );

    -- Clock generation process
    clock_process : PROCESS
    BEGIN
        clock <= '0';
        WAIT FOR clock_period / 2;
        clock <= '1';
        WAIT FOR clock_period / 2;
    END PROCESS;

    -- Testbench process
    test_process : PROCESS
    BEGIN
        ------------------------------------------------------------------------
        -- Test 1: Reset accumulators
        ------------------------------------------------------------------------
        reset <= '1';
        WAIT FOR clock_period;
        reset <= '0';

        -- Enable output and select ACC0 to output_bus
        output_en   <= '1';
        acc_mux_sel <= '0'; -- Select ACC0
        WAIT FOR clock_period;

        ASSERT output_bus = x"0000"
        REPORT "Test 1 failed: Output not 0000 after reset"
        SEVERITY ERROR;

        output_en <= '0';

        ------------------------------------------------------------------------
        -- Test 2: Load immediate data into ACC0
        ------------------------------------------------------------------------
        immediate   <= x"AAAA";
        mux4_sel    <= "10"; -- Select immediate
        acc0_write  <= '1';
        WAIT FOR clock_period;
        acc0_write  <= '0';

        -- Enable output and select ACC0 to output_bus
        output_en   <= '1';
        acc_mux_sel <= '0'; -- Select ACC0
        WAIT FOR clock_period;

        ASSERT output_bus = x"AAAA"
        REPORT "Test 2 failed: ACC0 not loaded with immediate data"
        SEVERITY ERROR;

        output_en <= '0';

        ------------------------------------------------------------------------
        -- Test 3: Store immediate data in register 0
        ------------------------------------------------------------------------
        rf_write   <= '1';                -- Enable write
        rf_mode    <= '0';                -- Single access mode
        rf_address <= "000";              -- Address 0
        WAIT FOR clock_period;
        
        rf_write   <= '0';                -- Disable write
        WAIT FOR clock_period * 2; 
        
        ------------------------------------------------------------------------
        -- Test 4: Increment the value by 1 and check output
        ------------------------------------------------------------------------
        rf_mode    <= '1';                --Dual access mode to be able to connect rf1_out to input B of ALU0
        rf_address <= "100";              -- Address 4
        alu_mux_sel<= '0';                -- Connect rf1_out (register 0) to input B of ALU0
        
        WAIT FOR clock_period;
        
        alu0_sel   <= "0111";             -- Increment B by 1
        mux4_sel   <= "00";
        acc0_write <= '1';
        output_en  <= '1';
        WAIT FOR clock_period * 2;
        acc0_write  <= '0';
        
        ASSERT output_bus = x"AAAB"
        REPORT "Test 4 failed: The value in register 0 was not incremented"
        SEVERITY ERROR;
        
        output_en <= '0';
        
        ------------------------------------------------------------------------
        -- Test 5: Test simple ALU1 and ACC1 
        ------------------------------------------------------------------------
        alu1_sel   <= "0010";             -- Pass B
        acc1_write  <= '1';
        WAIT FOR 2*clock_period;
        acc1_write  <= '0';
        
        ------------------------------------------------------------------------
        -- Test 6: Test ALU1 to see overflow output
        ------------------------------------------------------------------------
        acc_mux_sel <= '0';
        wait for clock_period;
        rf_write   <= '1';                -- Enable write
        rf_mode    <= '1';                -- Dual Access mode to get a value to input A of ALU1
        rf_address <= "101";              -- 101 = 5 > 4, rf1_in will write to register 1
                                          -- rf0_in will write to register 5
        WAIT FOR clock_period;
        
        rf_write   <= '0';                -- Disable write
        WAIT FOR clock_period * 2;
        
        alu1_sel   <= "0101";             -- Add A and B (0xAAAB + 0xAAAB)
        acc1_write  <= '1';
        
        WAIT FOR 2*clock_period;
        
        acc1_write  <= '0';
        acc_mux_sel <= '1';
        rf_address  <= "110";             -- 110 = 6 > 4, rf1_in will write to register 2
                                          -- rf0_in will write to register 6
        rf_write    <= '1';
        WAIT FOR clock_period;
        rf_write    <= '0';
        WAIT FOR clock_period;
        
        rf_mode    <= '0';
        rf_address  <= "010";
        WAIT FOR clock_period;
        
        mux4_sel   <= "01";
        acc0_write <= '1';
        WAIT FOR clock_period;
        acc0_write <= '0';
        output_en   <= '1';
        
        
--        ASSERT of1_flag = '1'
--        REPORT "Test 6 failed: The overflow flag (of1_flag) of ALU1 was not set!"
--        SEVERITY ERROR;
        
        WAIT FOR clock_period * 4;
        output_en   <= '0';
        
        ASSERT output_bus = x"5556"
        REPORT "Test 6 failed: The value of the addition was wrong"
        SEVERITY ERROR;
        
        
        
        ------------------------------------------------------------------------
        -- Test 7: Test Decrement Overflow
        ------------------------------------------------------------------------
        
        
        REPORT "All test cases completed successfully."
        SEVERITY NOTE;

        WAIT; -- Stop simulation
    END PROCESS;

END behavior;
