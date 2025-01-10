----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
-- Engineering student: Mohamad Abdallah
-- Create Date: 10/29/2020 07:18:24 PM
-- Module Name: tri_state_buffer
-- Description: Tri-state buffer for CPU output in Lab 3 (ECE 410, 2021)
-- Revision History:
-- Revision 0.01 - File Created
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
--
-- Additional Comments:
-- - The tri-state buffer allows the CPU to control when its output is driven to external components.
-- - When `output_en` is asserted ('1'), the `buffer_input` value is passed to `buffer_output`.
-- - When `output_en` is deasserted ('0'), `buffer_output` is set to high impedance ('Z'), effectively disconnecting it.
----------------------------------------------------------------------------------

-- Import the IEEE standard library for basic logic types
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Entity Declaration: Defines the tri-state buffer module interface
ENTITY tri_state_buffer IS
    PORT(
        output_en     : IN STD_LOGIC;                  -- Enable signal for the buffer
        buffer_input  : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Input data to the buffer
        buffer_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)  -- Output data from the buffer
    );
END tri_state_buffer;

-- Architecture Definition: Describes the behavior of the tri-state buffer
ARCHITECTURE Behavioral OF tri_state_buffer IS
BEGIN
    -- Assign `buffer_output` based on the value of `output_en`
    -- If `output_en` is '1', pass `buffer_input` to `buffer_output`
    -- Otherwise, set `buffer_output` to high-impedance ('Z'), disconnecting it
    buffer_output <= buffer_input WHEN output_en = '1' ELSE (OTHERS => 'Z');
END Behavioral;
