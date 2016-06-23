LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY switchesIO IS
PORT (boot 					: IN 		STD_LOGIC;
		CLOCK_50	 			: IN 		STD_LOGIC;
		inta					: IN		STD_LOGIC;
		switches				: IN		STD_LOGIC_VECTOR(7 DOWNTO 0);
		intr					: OUT		STD_LOGIC := '0';
		rd_switches			: OUT		STD_LOGIC_VECTOR(7 DOWNTO 0));	
END switchesIO;

ARCHITECTURE Structure OF switchesIO IS

	SIGNAL last				:	STD_LOGIC_VECTOR(7 DOWNTO 0); --valor de switches en el ciclo anterior
	SIGNAL changed			:	STD_LOGIC := '0'; --indica si ha habido algun cambio mientras se estaba atendiendo otra interrupcion
	
	SIGNAL value_int		:  STD_LOGIC_VECTOR(7 DOWNTO 0); --valor de switches de la interrupcion actual
	SIGNAL interrupt		:	STD_LOGIC := '0'; --indica si se esta atendiendo una interrupcion
	
BEGIN

	PROCESS(CLOCK_50)
	BEGIN
		IF RISING_EDGE(CLOCK_50) THEN
			IF boot = '1' THEN
				interrupt <= '0';
				changed 	 <= '0';
			ELSIF((last /= switches AND interrupt = '0') 
					OR (changed = '1' AND interrupt = '0')) THEN --si ve un cambio en el valor de switches o hay el flag de changed activado, genera una interrupcion
				interrupt <= '1';
				value_int <= switches;
				changed <= '0';
			ELSIF (last /= switches) THEN
				changed <= '1';
			END IF;	
			
			IF (inta = '1') THEN --si recibe un acknowledge, termina la interrupion
				interrupt <= '0';
			END IF;
			
			last <= switches;
		END IF;
	END PROCESS;
	 
	 intr <= interrupt;
	 rd_switches <= value_int;
	 
END Structure;