LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY sisa IS
    PORT (CLOCK_50  	: IN    	STD_LOGIC;
          SRAM_ADDR 	: OUT    STD_LOGIC_VECTOR(17 downto 0);
          SRAM_DQ   	: INOUT 	STD_LOGIC_VECTOR(15 downto 0);
          SRAM_UB_N 	: OUT    STD_LOGIC;
          SRAM_LB_N 	: OUT    STD_LOGIC;
          SRAM_CE_N 	: OUT    STD_LOGIC := '1';
          SRAM_OE_N 	: OUT    STD_LOGIC := '1';
          SRAM_WE_N 	: OUT    STD_LOGIC := '1';
			 LEDG 	  	: OUT  	STD_LOGIC_VECTOR(7 DOWNTO 0);
			 LEDR      	: OUT    STD_LOGIC_VECTOR(7 DOWNTO 0);
          SW        	: IN 	 	STD_LOGIC_VECTOR(9 downto 0);
			 KEY		  	: IN	 	STD_LOGIC_VECTOR(3 downto 0);
			 HEX0 	  	: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
			 HEX1 		: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
			 HEX2 		: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
			 HEX3 		: OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
			 PS2_CLK 	: INOUT  STD_LOGIC;
			 PS2_DAT 	: INOUT  STD_LOGIC;
			 VGA_HS		: OUT 	STD_LOGIC;
			 VGA_VS		: OUT 	STD_LOGIC;
			 VGA_R		: OUT		STD_LOGIC_VECTOR(3 DOWNTO 0);
			 VGA_G		: OUT		STD_LOGIC_VECTOR(3 DOWNTO 0);
			 VGA_B		: OUT		STD_LOGIC_VECTOR(3 DOWNTO 0);
			 AUD_ADCDAT : IN STD_LOGIC;
			 AUD_BCLK		: INOUT STD_LOGIC;
			 AUD_ADCLRCK 	: INOUT STD_LOGIC;
			 AUD_DACLRCK 	: INOUT STD_LOGIC;
			 I2C_SDAT	   : INOUT STD_LOGIC;
			 AUD_XCK			: OUT STD_LOGIC;
			 AUD_DACDAT 	: OUT STD_LOGIC;
			 I2C_SCLK	 	: OUT STD_LOGIC
			 );
END sisa;

ARCHITECTURE Structure OF sisa IS


	COMPONENT DE2_Audio_Example IS 
		port(
		
		CLOCK_50 	: IN STD_LOGIC;
		CLOCK_27 	: IN STD_LOGIC;
		KEY			: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		SW				: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		AUD_ADCDAT  : IN STD_LOGIC;
		AUD_BCLK		: INOUT STD_LOGIC;
		AUD_ADCLRCK : INOUT STD_LOGIC;
		AUD_DACLRCK : INOUT STD_LOGIC;
		I2C_SDAT	   : INOUT STD_LOGIC;
		AUD_XCK		: OUT STD_LOGIC;
		AUD_DACDAT  : OUT STD_LOGIC;
		I2C_SCLK	 	: OUT STD_LOGIC
		 
		);
	END COMPONENT;


	COMPONENT MemoryController IS
	port ( CLOCK_50  	: IN  	STD_LOGIC;
	       addr     	: IN  	STD_LOGIC_VECTOR(15 downto 0);
          wr_data   	: IN  	STD_LOGIC_VECTOR(15 downto 0);
          rd_data   	: OUT 	STD_LOGIC_VECTOR(15 downto 0);
          we        	: IN  	STD_LOGIC;
          byte_m    	: IN  	STD_LOGIC;
			 not_align 	: OUT		STD_LOGIC := '0';
			 mode			: in		STD_LOGIC;
			 ilegal_acc	: out		STD_LOGIC := '0';
          SRAM_ADDR 	: OUT   	STD_LOGIC_VECTOR(17 downto 0);
          SRAM_DQ   	: INOUT 	STD_LOGIC_VECTOR(15 downto 0);
          SRAM_UB_N 	: OUT   	STD_LOGIC;
          SRAM_LB_N 	: OUT   	STD_LOGIC;
          SRAM_CE_N 	: OUT   	STD_LOGIC := '1';
          SRAM_OE_N 	: OUT   	STD_LOGIC := '1';
          SRAM_WE_N 	: OUT   	STD_LOGIC := '1';
			 vga_addr	: out		std_logic_vector(12 downto 0);
			 vga_we		: out		std_logic;
			 vga_wr_data: out		std_logic_vector(15 downto 0);
			 vga_rd_data: in		std_logic_vector(15 downto 0);
			 vga_byte_m	: out		std_logic);
    END COMPONENT;

	 COMPONENT proc IS
	 PORT (	clk      	: IN   STD_LOGIC;
				boot     	: IN   STD_LOGIC := '1';
				datard_m 	: IN   STD_LOGIC_VECTOR(15 DOWNTO 0);
				addr_m   	: OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
				data_wr   	: OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_m     	: OUT  STD_LOGIC;
				word_byte  	: OUT  STD_LOGIC;
				addr_io		: OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
				wr_io			: OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
				rd_io			: IN   STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_out		: OUT  STD_LOGIC := '0';
				rd_in			: OUT  STD_LOGIC;
				inta			: OUT  STD_LOGIC := '0';
				intr			: IN   STD_LOGIC := '0';
				not_align	: IN   STD_LOGIC;
				mode			: OUT  STD_LOGIC;
				ilegal_acc	: IN	 STD_LOGIC);
    END COMPONENT;
	 
	 COMPONENT controladores_IO IS
	 PORT(	boot 					: IN 		STD_LOGIC;
				CLOCK_50 			: IN 		STD_LOGIC;
				addr_io 				: IN 		STD_LOGIC_VECTOR(7 DOWNTO 0);
				wr_io 				: IN 		STD_LOGIC_VECTOR(15 DOWNTO 0);
				rd_io 				: OUT 	STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_out 				: IN 		STD_LOGIC;
				rd_in 				: IN 		STD_LOGIC;
				led_verdes			: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
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
	 END COMPONENT;
	 
	 COMPONENT vga_controller IS
	 PORT(	clk_50mhz 			: IN 	STD_LOGIC;
				reset 				: IN 	STD_LOGIC;
				blank_out 			: OUT STD_LOGIC;
				csync_out 			: OUT STD_LOGIC;
				horiz_sync_out 	: OUT STD_LOGIC;
				vert_sync_out	 	: OUT STD_LOGIC;
				red_out 				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				green_out 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				blue_out 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				addr_vga 			: IN 	STD_LOGIC_VECTOR(12 DOWNTO 0);
				we 					: IN 	STD_LOGIC := '0';
				wr_data 				: IN 	STD_LOGIC_VECTOR(15 DOWNTO 0);
				rd_data 				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				byte_m 				: IN 	STD_LOGIC;
				vga_cursor 			: IN 	STD_LOGIC_VECTOR(15 DOWNTO 0);
				vga_cursor_enable : IN 	STD_LOGIC);
	  END COMPONENT;
	 
	 
	 --para el divisor de frecuencia
	 SIGNAL CLK_8		:	STD_LOGIC		:= '0';
	 SIGNAL COUNT		:	INTEGER			:= 0;
	 
	--puentes
	SIGNAL word_byte_byte_m		:	STD_LOGIC;
	SIGNAL wr_m_we					:	STD_LOGIC;
	SIGNAL addr_m_addr			:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL data_wr_wr_data		:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL rd_data_datard_m		:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	SIGNAL addr_io					:	STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL wr_io					:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL rd_io					:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL wr_out					:	STD_LOGIC;
	SIGNAL rd_in					:	STD_LOGIC;
	
	SIGNAL mode_bridge			:	STD_LOGIC;
	
	--signals no utiles
	SIGNAL NOTHING	:	STD_LOGIC;
	
	--puentes vga
	SIGNAL blue_bridge, green_bridge, red_bridge	:	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL vga_addr	:	STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL vga_we, vga_byte_m	:	STD_LOGIC := '0';
	SIGNAL vga_wr_data, vga_rd_data	:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	SIGNAL vga_cursor	:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL vga_cursor_enable	:	STD_LOGIC := '0';
	
	SIGNAL inta_bridge : STD_LOGIC := '0';
	SIGNAL intr_bridge :	STD_LOGIC := '0';
	
	SIGNAL bridge_not_align 	    : STD_LOGIC := '0';
	SIGNAL ilegal_acc_bridge	    : STD_LOGIC := '0';
	
	SIGNAL audio_in_available	    : STD_LOGIC;
	SIGNAL left_channel_audio_in   : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL right_channel_audio_in  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_audio_in 		    : STD_LOGIC;

	SIGNAL audio_out_allowed       : STD_LOGIC;
	SIGNAL left_channel_audio_out  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL right_channel_audio_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL write_audio_out			 : STD_LOGIC;
	

BEGIN

	PROCESS(CLOCK_50)
	BEGIN
		IF rising_edge(CLOCK_50) THEN
			IF COUNT < 3 THEN
				COUNT <= COUNT + 1;
			ELSE
				COUNT <= 0;
				CLK_8 <= NOT CLK_8;
			END IF;
		END IF;
	END PROCESS;
	

	proc0: proc
		Port Map(		clk			=> CLK_8,
							boot			=> SW(9),
							datard_m		=> rd_data_datard_m,
							addr_m		=> addr_m_addr,
							data_wr		=> data_wr_wr_data,
							wr_m			=> wr_m_we,
							word_byte	=> word_byte_byte_m,
							addr_io		=> addr_io,
							wr_io			=> wr_io,
							rd_io			=> rd_io,
							wr_out		=> wr_out,
							rd_in			=> rd_in,
							inta			=> inta_bridge,
							intr			=> intr_bridge,
							not_align	=> bridge_not_align,
							mode 			=> mode_bridge,
							ilegal_acc	=>	ilegal_acc_bridge);
							
	mem0: MemoryController
		Port Map(		CLOCK_50		=> CLOCK_50,
							addr			=> addr_m_addr,
							wr_data		=> data_wr_wr_data,
							rd_data		=> rd_data_datard_m,
							we				=> wr_m_we,
							byte_m		=> word_byte_byte_m,
							not_align	=> bridge_not_align,
							mode			=> mode_bridge,
							ilegal_acc	=>	ilegal_acc_bridge,
							SRAM_ADDR	=> SRAM_ADDR,
							SRAM_DQ		=> SRAM_DQ,
							SRAM_UB_N	=> SRAM_UB_N,
							SRAM_LB_N	=> SRAM_LB_N,
							SRAM_CE_N	=> SRAM_CE_N,
							SRAM_OE_N	=> SRAM_OE_N,
							SRAM_WE_N	=> SRAM_WE_N,
							vga_addr		=> vga_addr,
							vga_we		=> vga_we,
							vga_wr_data	=> vga_wr_data,
							vga_rd_data	=> vga_rd_data,
							vga_byte_m	=> vga_byte_m);
							
	io0: controladores_IO
		Port Map(		boot			=> SW(9),
							CLOCK_50		=> CLOCK_50,
							addr_io		=> addr_io,
							wr_io			=> wr_io,
							rd_io			=> rd_io,
							wr_out		=> wr_out,
							rd_in			=> rd_in,
							led_verdes	=> LEDG,
							led_rojos	=> LEDR,
							SW				=>	SW(7 DOWNTO 0),
							KEY			=>	KEY,
							HEX0			=> HEX0,
							HEX1			=> HEX1,
							HEX2			=> HEX2,
							HEX3			=> HEX3,
							PS2_CLK		=> PS2_CLK,
							PS2_DATA		=> PS2_DAT,
							vga_cursor	=> vga_cursor,
							vga_cursor_enable	=> vga_cursor_enable,
							inta					=> inta_bridge,
							intr					=> intr_bridge);
	
	vga0 : vga_controller
	Port Map(			clk_50mhz			=> CLOCK_50,
							reset					=> SW(9),
							blank_out			=> NOTHING,
							csync_out			=> NOTHING,
							horiz_sync_out 	=> VGA_HS,
							vert_sync_out		=> VGA_VS,
							red_out				=> red_bridge,
							blue_out				=> blue_bridge,
							green_out			=> green_bridge,
							addr_vga				=> vga_addr,
							we						=> vga_we,
							wr_data				=> vga_wr_data,
							rd_data				=> vga_rd_data,
							byte_m				=> vga_byte_m,
							vga_cursor			=> vga_cursor,
							vga_cursor_enable	=> vga_cursor_enable);
							
							
	aud0 : DE2_Audio_Example
	Port Map(
	
			CLOCK_50 	=> CLOCK_50,
			CLOCK_27 	=> '0',
			KEY			=> KEY,
			SW				=>	SW(3 DOWNTO 0),
			AUD_ADCDAT  => AUD_ADCDAT,
			AUD_BCLK		=> AUD_BCLK,
			AUD_ADCLRCK => AUD_ADCLRCK,
			AUD_DACLRCK => AUD_DACLRCK,
			I2C_SDAT	   => I2C_SDAT,
			AUD_XCK		=> AUD_XCK,
			AUD_DACDAT  => AUD_DACDAT,
			I2C_SCLK	 	=> I2C_SCLK
	 
	);
--							
							
	VGA_R <= red_bridge(3 DOWNTO 0);
	VGA_B <= blue_bridge(3 DOWNTO 0);
	VGA_G <= green_bridge(3 DOWNTO 0);
	
	
END Structure;