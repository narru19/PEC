LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY controladores_IO IS
PORT (boot 					: IN 		STD_LOGIC;
		CLOCK_50	 			: IN 		STD_LOGIC;
		addr_io 				: IN 		STD_LOGIC_VECTOR(7  DOWNTO 0);
		wr_io 				: IN 		STD_LOGIC_VECTOR(15 DOWNTO 0);
		rd_io 				: OUT 	STD_LOGIC_VECTOR(15 DOWNTO 0);
		wr_out 				: IN 		STD_LOGIC := '0';
		rd_in 				: IN 		STD_LOGIC;
		led_verdes 			: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		led_rojos  			: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		SW						: IN 		STD_LOGIC_VECTOR(7 DOWNTO 0);
		KEY					: IN 		STD_LOGIC_VECTOR(3 DOWNTO 0);
		HEX0					: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1					: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2					: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3					: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
		PS2_CLK 				: INOUT 	STD_LOGIC;
		PS2_DATA 			: INOUT 	STD_LOGIC;
		VGA_CURSOR			: OUT 	STD_LOGIC_VECTOR(15 DOWNTO 0);
		VGA_CURSOR_ENABLE	: OUT 	STD_LOGIC;
		intr					: OUT		STD_LOGIC;
		inta					: IN 		STD_LOGIC);
END controladores_IO;

ARCHITECTURE Structure OF controladores_IO IS

	COMPONENT driverDisplay IS
	PORT(	codigoCaracter	:	IN	 STD_LOGIC_VECTOR(15 DOWNTO 0);
			enableBits		:	IN	 STD_LOGIC_VECTOR(3  DOWNTO 0);
			bitsCaracter0	:	OUT STD_LOGIC_VECTOR(6  DOWNTO 0);
			bitsCaracter1	:	OUT STD_LOGIC_VECTOR(6  DOWNTO 0);
			bitsCaracter2	:	OUT STD_LOGIC_VECTOR(6  DOWNTO 0);
			bitsCaracter3	:	OUT STD_LOGIC_VECTOR(6  DOWNTO 0));
    END COMPONENT;
	
	COMPONENT interrupt_controller IS
	PORT (boot 			: IN 		STD_LOGIC;
		CLOCK_50	 	: IN 		STD_LOGIC;
		inta			: IN		STD_LOGIC;
		key_intr		: IN		STD_LOGIC;
		ps2_intr		: IN		STD_LOGIC;
		switch_intr	: IN		STD_LOGIC;
		timer_intr	: IN		STD_LOGIC;
		intr			: OUT		STD_LOGIC := '0';
		key_inta		: OUT		STD_LOGIC := '0';
		ps2_inta		: OUT		STD_LOGIC := '0';
		switch_inta	: OUT 	STD_LOGIC := '0';
		timer_inta	: OUT		STD_LOGIC := '0';
		iid			: OUT		STD_LOGIC_VECTOR(7 DOWNTO 0));	
    END COMPONENT;
	
	COMPONENT keyboardIO IS
	PORT (clear_char 			: IN 		STD_LOGIC;
		CLOCK_50	 			: IN 		STD_LOGIC;
		inta					: IN		STD_LOGIC;
		reset					: IN		STD_LOGIC;
		data_ready			: OUT		STD_LOGIC;
		PS2_CLK 				: INOUT 	STD_LOGIC;
		PS2_DATA 			: INOUT 	STD_LOGIC;
		intr					: OUT		STD_LOGIC := '0';
		read_char			: OUT		STD_LOGIC_VECTOR(7 DOWNTO 0));	
    END COMPONENT;
	 
	COMPONENT keysIO IS
	PORT (boot 					: IN 		STD_LOGIC;
		CLOCK_50	 			: IN 		STD_LOGIC;
		inta					: IN		STD_LOGIC;
		keys					: IN		STD_LOGIC_VECTOR(3 DOWNTO 0);
		intr					: OUT		STD_LOGIC := '0';
		read_key				: OUT		STD_LOGIC_VECTOR(3 DOWNTO 0));	
    END COMPONENT;
	
	COMPONENT switchesIO IS
	PORT (boot 					: IN 		STD_LOGIC;
		CLOCK_50	 			: IN 		STD_LOGIC;
		inta					: IN		STD_LOGIC;
		switches				: IN		STD_LOGIC_VECTOR(7 DOWNTO 0);
		intr					: OUT		STD_LOGIC := '0';
		rd_switches			: OUT		STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT;
	 
	COMPONENT timerIO IS
	PORT (boot 					: IN 		STD_LOGIC;
		CLOCK_50	 			: IN 		STD_LOGIC;
		inta					: IN		STD_LOGIC;
		intr					: OUT		STD_LOGIC := '0');
    END COMPONENT;
	
	CONSTANT PORT_GREEN_LED 		: INTEGER := 5;
	CONSTANT PORT_RED_LED 			: INTEGER := 6;
	CONSTANT PORT_KEYS 				: INTEGER := 7;
	CONSTANT PORT_SWITCHES			: INTEGER := 8;
	CONSTANT PORT_ENABLE_DISPLAY	: INTEGER := 9;
	CONSTANT PORT_CONTENT_DISPLAY	: INTEGER := 10;
	CONSTANT PORT_KEYBOARD_DATA	: INTEGER := 15;
	CONSTANT PORT_KEYBOARD_POLL	: INTEGER := 16;
	CONSTANT PORT_RANDOM				: INTEGER := 20;
	CONSTANT PORT_TIMER				: INTEGER := 21;
	
	
	TYPE 	 io_bank IS ARRAY(255 DOWNTO 0) of STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL registers	: io_bank;
	SIGNAL contador_ciclos : STD_LOGIC_VECTOR(15 downto 0):=x"0000";
	
	
	--bridges
	SIGNAL clear_char 	:	STD_LOGIC := '0';
	SIGNAL data_ready 	:	STD_LOGIC;
	SIGNAL IID				:	STD_LOGIC_VECTOR (7 downto 0);
	
	SIGNAL timer_intr		:	STD_LOGIC;
	SIGNAL ps2_intr		:	STD_LOGIC;
	SIGNAL switch_intr	:	STD_LOGIC;
	SIGNAL key_intr		:	STD_LOGIC;
	
	SIGNAL timer_inta		:	STD_LOGIC;
	SIGNAL ps2_inta		:	STD_LOGIC;
	SIGNAL switch_inta	:	STD_LOGIC;
	SIGNAL key_inta		:	STD_LOGIC;
	
	SIGNAL rd_switches	:	STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL read_key		:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL read_char		:	STD_LOGIC_VECTOR (7 downto 0);
	
	
BEGIN


	VGA_CURSOR <= (OTHERS => '0');
	VGA_CURSOR_ENABLE <= '0';

	 --actualizacion de dispositivos de salida
	 led_rojos 					<= 	registers(PORT_RED_LED)(7 DOWNTO 0);
	 led_verdes					<=		registers(PORT_GREEN_LED)(7 DOWNTO 0);
	 d0: driverDisplay
		Port Map(		codigoCaracter		=> registers(PORT_CONTENT_DISPLAY),
							enableBits			=> registers(PORT_ENABLE_DISPLAY)(3 DOWNTO 0),
							bitsCaracter0		=> HEX0,
							bitsCaracter1		=> HEX1,
							bitsCaracter2		=> HEX2,
							bitsCaracter3		=> HEX3);
							
	 
	 PROCESS(CLOCK_50)
	 BEGIN
		IF RISING_EDGE(CLOCK_50) THEN
		   --actualizacion dispositivos de salida
			clear_char <= '0';
			IF boot = '1' THEN
				registers(PORT_RED_LED) 			<= (OTHERS => '0');	--Leds off at start
				registers(PORT_GREEN_LED) 			<= (OTHERS => '0');
				registers(PORT_CONTENT_DISPLAY)	<=	(OTHERS => '0');	--Nothing to display at start
				registers(PORT_ENABLE_DISPLAY)	<= (OTHERS => '0');	--Displays disabled at start
			ELSIF wr_out = '1' THEN
				IF (conv_integer(addr_io) = PORT_KEYS 		OR
					 conv_integer(addr_io) = PORT_SWITCHES	OR
					 conv_integer(addr_io) = PORT_KEYBOARD_DATA) THEN
						--No permitir escritura de dispositivos de entrada.
				ELSIF conv_integer(addr_io) = PORT_KEYBOARD_POLL THEN
					clear_char	<= '1';
				ELSE
					registers(conv_integer(addr_io)) <= wr_io;
				END IF;
			END IF;
				
				
			IF inta = '0' AND rd_in = '1' THEN 
				rd_io	<= registers(conv_integer(addr_io));
			ELSIF inta = '1' THEN
				rd_io <= "00000000" & IID;
			END IF;
			
			
			--actualizacion de dispositivos de entrada
			registers(PORT_KEYS)(3 DOWNTO 0)				<=	KEY;	
			registers(PORT_SWITCHES)(7 DOWNTO 0)		<= SW;
			registers(PORT_KEYBOARD_DATA)(7 DOWNTO 0) <= read_char;
			registers(PORT_KEYBOARD_POLL) <= "000000000000000" & data_ready;
			registers(PORT_RANDOM) <= contador_ciclos;
			
			--timer
			IF contador_ciclos=0 THEN
				contador_ciclos<=x"C350"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos
				IF registers(PORT_TIMER)>0 THEN
					registers(PORT_TIMER) <= registers(PORT_TIMER)-1;
				END IF;
			ELSE
				contador_ciclos <= contador_ciclos-1;
			END IF;
			
			
		END IF;
	 END PROCESS;

	 s0: switchesIO
		Port Map(	boot			=> boot,
						CLOCK_50 	=> CLOCK_50,
						inta			=> switch_inta,
						switches		=> registers(PORT_SWITCHES)(7 DOWNTO 0),
					   intr			=> switch_intr,
						rd_switches	=> rd_switches);
						
	 k0: keysIO
		Port Map(	boot			=> boot,
						CLOCK_50 	=> CLOCK_50,
						inta			=> key_inta,
						keys			=> registers(PORT_KEYS)(3 DOWNTO 0),
					   intr			=> key_intr,
						read_key	=> read_key);
						
	 ps20: keyboardIO
		Port Map(	clear_char  => clear_char,
						reset			=> boot,
						CLOCK_50 	=> CLOCK_50,
						inta			=> ps2_inta,
						PS2_CLK		=> PS2_CLK,
						PS2_DATA		=> PS2_DATA,
						data_ready 	=> data_ready,
					   intr			=> ps2_intr,
						read_char	=> read_char);
						
	t0: timerIO
		Port Map(	boot			=> boot,
						CLOCK_50 	=> CLOCK_50,
						inta			=> timer_inta,
					   intr			=> timer_intr);
						
	i0: interrupt_controller
		Port Map(	boot			=> boot,
						CLOCK_50 	=> CLOCK_50,
						inta			=> inta,
						key_intr		=> key_intr,
						ps2_intr		=> ps2_intr,
					   switch_intr	=> switch_intr,
						timer_intr	=> timer_intr,
						intr			=> intr,
					   key_inta		=> key_inta,
						ps2_inta		=> ps2_inta,
						switch_inta	=> switch_inta,
						timer_inta	=> timer_inta,
						iid			=> IID);
	 
	 
END Structure;