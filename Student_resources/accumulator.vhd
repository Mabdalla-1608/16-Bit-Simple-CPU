----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
-- Engineering Student: Mohamad Abdallah
-- Create Date: 10/29/2020 07:18:24 PM
-- Module Name: accumulator
-- Description: 16-bit accumulator register for CPU datapath in Lab 3 (ECE 410)
-- Revision History:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Revision 5.01 - Added missing bits of code by Mohamad Abdallah (December 8, 2024)
--
-- Additional Comments:
-- - To write data to the accumulator, the 'acc_write' signal must be asserted (set to '1').
-- - Writing occurs only on the rising edge of the clock when 'acc_write' is high.
-- - The accumulator supports asynchronous reset, clearing the output to 0 when 'reset' is high.
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Entity Declaration
ENTITY accumulator IS
    PORT(
        clock     : IN  STD_LOGIC;                   -- Clock signal
        reset     : IN  STD_LOGIC;                   -- Asynchronous reset signal
        acc_write : IN  STD_LOGIC;                   -- Write enable signal for the accumulator
        acc_in    : IN  STD_LOGIC_VECTOR (15 DOWNTO 0); -- Input data to the accumulator
        acc_out   : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)  -- Output data from the accumulator
    );
END accumulator;

-- Architecture Definition
ARCHITECTURE Behavioral OF accumulator IS
BEGIN
    PROCESS (clock, reset)
    BEGIN
        -- Asynchronous reset logic
        IF reset = '1' THEN
            acc_out <= (OTHERS => '0');  -- Clear the accumulator output
        -- Writing data to the accumulator on the rising edge of the clock
        ELSIF rising_edge(clock) AND acc_write = '1' THEN
            acc_out <= acc_in;          -- Load input data into the accumulator
        END IF;
    END PROCESS;
    
END Behavioral;
