LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY keysIO IS
PORT (boot 					: IN 		STD_LOGIC;
		CLOCK_50	 			: IN 		STD_LOGIC;
		inta					: IN		STD_LOGIC;
		keys					: IN		STD_LOGIC_VECTOR(3 DOWNTO 0);
		intr					: OUT		STD_LOGIC := '0';
		read_key				: OUT		STD_LOGIC_VECTOR(3 DOWNTO 0));	
END keysIO;

ARCHITECTURE Structure OF keysIO IS

	SIGNAL last				:	STD_LOGIC_VECTOR(3 DOWNTO 0); --valor de keys en el ciclo anterior
	SIGNAL changed			:	STD_LOGIC := '0'; --indica si ha habido algun cambio mientras se estaba atendiendo otra interrupcion
	
	SIGNAL value_int		:  STD_LOGIC_VECTOR(3 DOWNTO 0); --valor de keys de la interrupcion actual
	SIGNAL interrupt		:	STD_LOGIC := '0'; --indica si se esta atendiendo una interrupcion
	
BEGIN

	PROCESS(CLOCK_50)
	BEGIN
		IF RISING_EDGE(CLOCK_50) THEN
			IF boot = '1' THEN
				interrupt <= '0';
				changed 	 <= '0';
			ELSIF((last /= keys AND interrupt = '0') 
					OR (changed = '1' AND interrupt = '0')) THEN --si ve un cambio en el valor de keys o hay el flag de changed activado, genera una interrupcion
				interrupt <= '1';
				value_int <= keys;
				changed <= '0';
			ELSIF (last /= keys) THEN
				changed <= '1';
			END IF;	
			
			IF (inta = '1') THEN --si recibe un acknowledge, termina la interrupion
				interrupt <= '0';
			END IF;
			
			last <= keys;
		END IF;
	END PROCESS;
	 
	 intr <= interrupt;
	 read_key <= value_int;
	 
END Structure;