LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY keyboardIO IS
PORT (clear_char 			: IN 		STD_LOGIC;
		CLOCK_50	 			: IN 		STD_LOGIC;
		inta					: IN		STD_LOGIC;
		reset					: IN		STD_LOGIC;
		data_ready			: OUT		STD_LOGIC;
		PS2_CLK 				: INOUT 	STD_LOGIC;
		PS2_DATA 			: INOUT 	STD_LOGIC;
		intr					: OUT		STD_LOGIC := '0';
		read_char			: OUT		STD_LOGIC_VECTOR(7 DOWNTO 0));	
END keyboardIO;

ARCHITECTURE Structure OF keyboardIO IS

	COMPONENT keyboard_controller IS
		PORT ( clk        : in    STD_LOGIC;
				 reset      : in    STD_LOGIC;
				 ps2_clk    : inout STD_LOGIC;
				 ps2_data   : inout STD_LOGIC;
				 read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
				 clear_char : in    STD_LOGIC;
				 data_ready : out   STD_LOGIC);
	END COMPONENT;
	
	SIGNAL ps2_intr		:	STD_LOGIC := '0';	
	SIGNAL ps2_inta		:	STD_LOGIC := '0';	
	
BEGIN

	ps2_inta	<= '1' WHEN (inta = '1' OR clear_char = '1') ELSE
					'0';
					
	intr <= ps2_intr;
	--intr <= '0';
	data_ready	<= ps2_intr;

	k0: keyboard_controller
		Port Map(	clk			=> CLOCK_50,
						reset 		=> reset,
						ps2_clk		=> PS2_CLK,
						ps2_data		=> PS2_DATA,
					   read_char	=> read_char,
						clear_char	=> ps2_inta,
						data_ready	=> ps2_intr);
	 
END Structure;