LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

ENTITY driverDisplay IS
	PORT(	codigoCaracter	:	IN	 STD_LOGIC_VECTOR(15 DOWNTO 0);
			enableBits		:	IN	 STD_LOGIC_VECTOR(3  DOWNTO 0);
			bitsCaracter0	:	OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			bitsCaracter1	:	OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			bitsCaracter2	:	OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			bitsCaracter3	:	OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END driverDisplay;

ARCHITECTURE Structure OF driverDisplay IS

SIGNAL aux0, aux1, aux2, aux3	:	STD_LOGIC_VECTOR(6 DOWNTO 0);

CONSTANT OFF : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111111";

BEGIN

	--Farem servir assignacions auxiliars per despres saber si estan activats o no.

	WITH codigoCaracter(3 DOWNTO 0) SELECT
					aux0 <=					"1000000" WHEN "0000",
												"1111001" WHEN "0001",
												"0100100" WHEN "0010",
												"0110000" WHEN "0011",
												"0011001" WHEN "0100",
												"0010010" WHEN "0101",
												"0000010" WHEN "0110",
												"1111000" WHEN "0111",
												"0000000" WHEN "1000",
												"0011000" WHEN "1001",
												"0001000" WHEN "1010",
												"0000011" WHEN "1011",
												"1000110" WHEN "1100",
												"0100001" WHEN "1101",
												"0000110" WHEN "1110",
												"0001110" WHEN "1111",
												"0111111" WHEN OTHERS;
												
	WITH codigoCaracter(7 DOWNTO 4) SELECT
					aux1 <=					"1000000" WHEN "0000",
												"1111001" WHEN "0001",
												"0100100" WHEN "0010",
												"0110000" WHEN "0011",
												"0011001" WHEN "0100",
												"0010010" WHEN "0101",
												"0000010" WHEN "0110",
												"1111000" WHEN "0111",
												"0000000" WHEN "1000",
												"0011000" WHEN "1001",
												"0001000" WHEN "1010",
												"0000011" WHEN "1011",
												"1000110" WHEN "1100",
												"0100001" WHEN "1101",
												"0000110" WHEN "1110",
												"0001110" WHEN "1111",
												"0111111" WHEN OTHERS;
												
		WITH codigoCaracter(11 DOWNTO 8) SELECT
					aux2 <= 					"1000000" WHEN "0000",
												"1111001" WHEN "0001",
												"0100100" WHEN "0010",
												"0110000" WHEN "0011",
												"0011001" WHEN "0100",
												"0010010" WHEN "0101",
												"0000010" WHEN "0110",
												"1111000" WHEN "0111",
												"0000000" WHEN "1000",
												"0011000" WHEN "1001",
												"0001000" WHEN "1010",
												"0000011" WHEN "1011",
												"1000110" WHEN "1100",
												"0100001" WHEN "1101",
												"0000110" WHEN "1110",
												"0001110" WHEN "1111",
												"0111111" WHEN OTHERS;
												
		WITH codigoCaracter(15 DOWNTO 12) SELECT
					aux3 <=					"1000000" WHEN "0000",
												"1111001" WHEN "0001",
												"0100100" WHEN "0010",
												"0110000" WHEN "0011",
												"0011001" WHEN "0100",
												"0010010" WHEN "0101",
												"0000010" WHEN "0110",
												"1111000" WHEN "0111",
												"0000000" WHEN "1000",
												"0011000" WHEN "1001",
												"0001000" WHEN "1010",
												"0000011" WHEN "1011",
												"1000110" WHEN "1100",
												"0100001" WHEN "1101",
												"0000110" WHEN "1110",
												"0001110" WHEN "1111",
												"0111111" WHEN OTHERS;
												
		bitsCaracter0	<=	aux0	WHEN	enableBits(0) = '1'	ELSE OFF;
		bitsCaracter1	<=	aux1	WHEN	enableBits(1) = '1'	ELSE OFF;
		bitsCaracter2	<=	aux2	WHEN	enableBits(2) = '1'	ELSE OFF;
		bitsCaracter3	<=	aux3	WHEN	enableBits(3) = '1'	ELSE OFF;

END Structure;