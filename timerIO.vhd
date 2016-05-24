LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY timerIO IS
PORT (boot 					: IN 		STD_LOGIC;
		CLOCK_50	 			: IN 		STD_LOGIC;
		inta					: IN		STD_LOGIC;
		intr					: OUT		STD_LOGIC := '0');	
END timerIO;

ARCHITECTURE Structure OF timerIO IS

	SIGNAL interrupt	:	STD_LOGIC := '0';

	SIGNAL contador_ciclos			:	 STD_LOGIC_VECTOR(15 downto 0):=x"C350";
	SIGNAL contador_milisegundos	:	 STD_LOGIC_VECTOR(15 downto 0):=x"0032";
	
BEGIN

	PROCESS(CLOCK_50)
	BEGIN
		IF RISING_EDGE(CLOCK_50) THEN
			IF inta = '1' THEN
				interrupt <= '0';
			END IF;
			
			--timer
			IF contador_ciclos=0 THEN
				contador_ciclos<=x"C350"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos
				IF contador_milisegundos = 0 THEN
					contador_milisegundos <= x"0032";
					interrupt <= '1';
				ELSIF contador_milisegundos > 0 THEN
					contador_milisegundos <= contador_milisegundos-1;
				END IF;
			ELSE
				contador_ciclos <= contador_ciclos-1;
			END IF;
			
			--boot
			IF boot = '1' THEN 
				contador_ciclos<=x"C350";
				contador_milisegundos <= x"0032";
			END IF;
		END IF;
	END PROCESS;
	 
	 intr <= interrupt;
	 --intr <= '0';
	 
END Structure;