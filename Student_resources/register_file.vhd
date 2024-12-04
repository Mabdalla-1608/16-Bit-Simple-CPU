----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Antonio Andara Lara, Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Module Name: register file
-- Description: CPU LAB 3 - ECE 410 (2021)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments:
--*********************************************************************************
-- This register_file design provides an 8-location memory array, where each location is 16-bits wide. 
-- The `rf_address` lines select one of the eight registers, R[0] through R[7], and the `rf_write` 
-- signal enables writing data to the selected register. 
-- 
-- The `mode` input determines the access mode:
--   - When `mode = '0'`, the register file operates in "single access mode," where only one register 
--     (selected by `rf_address`) can be written to or read at a time.
--   - When `mode = '1'`, the design allows "dual access mode," enabling simultaneous read or write 
--     operations on two registers. Specifically, the address given by `rf_address` is interpreted to 
--     access paired registers, such that data can be written to or read from the selected register 
--     and another register offset by +/- 4. This feature enables simultaneous access to two registers 

-- Constraints:
--   - Only one type of operation (read or write) is performed per clock cycle, governed by the `rf_write` signal.
--   - Address conflicts between `rf0` and `rf1` in dual mode are prevented by restricting access to complementary register pairs.
--*********************************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Use numeric_std for arithmetic operations

ENTITY register_file IS
    PORT (
        clock      : IN STD_LOGIC;
        rf_write   : IN STD_LOGIC;
        rf_mode    : IN STD_LOGIC;
        rf_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        rf0_in     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        rf1_in     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        rf0_out    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        rf1_out    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END register_file;

ARCHITECTURE Behavioral OF register_file IS
    TYPE register_array IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL registers     : register_array := (OTHERS => (OTHERS => '0'));
    SIGNAL rf0_aux       : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rf1_aux       : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
BEGIN

    PROCESS (clock)
        VARIABLE address_int      : INTEGER;
        VARIABLE offset_address   : INTEGER := -1; --Initialize to invalid
    BEGIN
        IF rising_edge(clock) THEN
            -- Convert rf_address to integer
            address_int := to_integer(unsigned(rf_address));

            -- Initialize offset_address
--            offset_address := -1; -- Invalid by default

            -- Determine offset register address in dual access mode
            IF rf_mode = '1' THEN -- Dual access mode
                IF address_int <= 3 THEN
                    offset_address := address_int + 4;
                ELSE
                    offset_address := address_int - 4;
                END IF;
            END IF;

            -- Writing to register file
            IF rf_write = '1' THEN
                -- Write to primary register if address is valid
                IF address_int >= 0 AND address_int <= 7 THEN
                    IF rf_mode = '0' THEN -- Single access mode
                        registers(address_int) <= rf0_in;
                    ELSE -- Dual access mode
                            registers(address_int) <= rf0_in;
                            registers(offset_address) <= rf1_in;
                    END IF;
                END IF;
            END IF;

            -- Reading from register file
            IF rf_mode = '0' THEN -- Single access mode
                IF address_int >= 0 AND address_int <= 7 THEN
                    rf0_aux <= registers(address_int);
                ELSE
                    rf0_aux <= (OTHERS => '0');
                END IF;
                rf1_aux <= (OTHERS => '0');
            ELSE -- Dual access mode
                IF address_int >= 0 AND address_int <= 7 THEN
                    rf0_aux <= registers(address_int);
                    rf1_aux <= registers(offset_address);
                ELSE
                    rf0_aux <= (OTHERS => '0');
                    rf1_aux <= (OTHERS => '0');
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Assigning temp values to outputs
    rf0_out <= rf0_aux;
    rf1_out <= rf1_aux;

END Behavioral;

