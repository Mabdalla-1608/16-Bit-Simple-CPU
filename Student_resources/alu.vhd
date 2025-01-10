----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
-- Engineering Student: Mohamad Abdallah
-- Create Date: 10/29/2020 07:18:24 PM
-- Module Name: cpu - structural(datapath)
-- Description: CPU LAB 3 - ECE 410 (2023)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments:
--*********************************************************************************
-- A total of fifteen operations can be performed using 4 select lines of this ALU.
-- The select line codes have been given to you in the lab manual.
-----------------------------



-- ADD LIBRARIES for arithmetic and for data types
-- ALSO something else is wrong
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


ENTITY alu16 IS
    PORT ( A         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
         ; B         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
         ; shift_amt : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)
         ; alu_sel   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)
         ; alu_out   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	 ; of_flag   : OUT STD_LOGIC := '0'
         );
END alu16;

ARCHITECTURE Dataflow OF alu16 IS
BEGIN
	PROCESS (A, B, shift_amt, alu_sel)

	Variable temp : SIGNED (15 downto 0); --

	BEGIN
	
	    -- Reset overflow flag at the beginning of each operation 
	    -- TRIAL
	    of_flag <= '0';
	   
		--Check handout to know what each alu_sel do
		-- The when bits should be 4 not 3, the missing bit is the LSB
		CASE alu_sel IS
			WHEN "0001" => -- Pass A
				alu_out <= A; 

			WHEN "0010" => -- Pass B
				alu_out <= B;

			WHEN "0011" => -- Logical shift left
				alu_out <= STD_LOGIC_VECTOR(shift_left(unsigned(B), to_integer(unsigned(shift_amt)))); 

			WHEN "0100" => -- Logical shift right
				alu_out <= STD_LOGIC_VECTOR(shift_right(unsigned(B), to_integer(unsigned(shift_amt)))); 

			WHEN "0101" => -- Add
				temp := (SIGNED(A) + SIGNED(B));
				alu_out <= STD_LOGIC_VECTOR(temp);
                if ( ((A(15) XOR B(15)) = '0') AND (temp(15) /= A(15)) ) then
                    -- Signs of A and B are the same but sign of the output is different
                    -- Overflow occured
                    of_flag <= '1';
                else 
                    of_flag <= '0';
                end if;
                
			WHEN "0110" => -- Subtract
				temp := (SIGNED(A) - SIGNED(B));
				alu_out <= STD_LOGIC_VECTOR(temp);
                if ( ((A(15) XOR B(15)) = '0') AND (temp(15) /= A(15)) ) then
                    -- Signs of A and B are the same but sign of the output is different
                    -- Overflow occured
                    of_flag <= '1';
                else 
                    of_flag <= '0';
                end if;
                
			WHEN "0111" => -- Increment by 1
			    temp := (SIGNED(B) + 1);
				alu_out <= STD_LOGIC_VECTOR(temp);
                if ( temp(15) /= B(15) ) then
                    -- Sign flipped Overflow occured
                    of_flag <= '1';
                else 
                    of_flag <= '0';
                end if;

			WHEN "1000" => -- Decrement by 1
			    temp := (SIGNED(B) - 1);
				alu_out <= STD_LOGIC_VECTOR(temp);
                if ( temp(15) /= B(15) ) then
                    -- Sign flipped Overflow occured
                    of_flag <= '1';
                else 
                    of_flag <= '0';
                end if;

			WHEN "1001" => -- Bitwise AND of A,B
				alu_out <= A AND B;

			WHEN "1010" => -- Bitwise OR of A,B
				alu_out <= A OR B;

			WHEN "1011" => -- Pass NOT of A
				alu_out <= NOT(A);

			WHEN "1100" => -- Pass NOT of B
				Alu_out <= NOT(B);
				
			WHEN "1101" => -- Pass 1
				alu_out <= X"0001";

			WHEN "1110" => -- Pass 0
				alu_out <= X"0000";

			WHEN "1111" => -- Pass -1
				alu_out <= X"FFFF";

			WHEN OTHERS =>
				alu_out <= (OTHERS => '0');
		END CASE;
	END PROCESS;
END Dataflow;
