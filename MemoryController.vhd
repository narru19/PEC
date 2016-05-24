library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MemoryController is
    port (CLOCK_50  	: in  	STD_LOGIC;
	       addr      	: in  	STD_LOGIC_VECTOR(15 downto 0);
          wr_data   	: in  	STD_LOGIC_VECTOR(15 downto 0);
          rd_data   	: out 	STD_LOGIC_VECTOR(15 downto 0);
          we        	: in  	STD_LOGIC := '0';
          byte_m    	: in  	STD_LOGIC;
			 not_align	: out		STD_LOGIC := '0';
			 mode			: in		STD_LOGIC;
			 ilegal_acc	: out		STD_LOGIC := '0';
          -- senales para la placa de desarrollo
          SRAM_ADDR 	: out   	STD_LOGIC_VECTOR(17 downto 0);
          SRAM_DQ   	: inout 	STD_LOGIC_VECTOR(15 downto 0);
          SRAM_UB_N 	: out   	STD_LOGIC;
          SRAM_LB_N 	: out   	STD_LOGIC;
          SRAM_CE_N 	: out   	STD_LOGIC := '1';
          SRAM_OE_N 	: out   	STD_LOGIC := '1';
          SRAM_WE_N 	: out   	STD_LOGIC := '1';
			 vga_addr	: out		STD_LOGIC_VECTOR(12 downto 0);
			 vga_we		: out		STD_LOGIC := '0';
			 vga_wr_data: out		STD_LOGIC_VECTOR(15 downto 0);
			 vga_rd_data: in		STD_LOGIC_VECTOR(15 downto 0);
			 vga_byte_m	: out		STD_LOGIC);
end MemoryController;

architecture comportament of MemoryController is

	COMPONENT SRAMController IS
	port ( clk         : in    STD_LOGIC;
          SRAM_ADDR   : out   STD_LOGIC_VECTOR(17 downto 0);
          SRAM_DQ     : inout STD_LOGIC_VECTOR(15 downto 0);
          SRAM_UB_N   : out   STD_LOGIC;
          SRAM_LB_N   : out   STD_LOGIC;
          SRAM_CE_N   : out   STD_LOGIC := '1';
          SRAM_OE_N   : out   STD_LOGIC := '1';
          SRAM_WE_N   : out   STD_LOGIC := '1';
          address     : in    STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
          dataReaded  : out   STD_LOGIC_VECTOR(15 downto 0);
          dataToWrite : in    STD_LOGIC_VECTOR(15 downto 0);
          WR          : in    STD_LOGIC := '0';
          byte_m      : in    STD_LOGIC := '0';
			 not_align	 : out	STD_LOGIC := '0');
    END COMPONENT;

	 
	 CONSTANT VGA_START_ADDRESS	: STD_LOGIC_VECTOR(15 DOWNTO 0)	:= x"A000";
	 CONSTANT VGA_END_ADDRESS		: STD_LOGIC_VECTOR(15 DOWNTO 0)	:= x"BFFF";
	 
	 CONSTANT USER_START_ADDRESS	: STD_LOGIC_VECTOR(15 DOWNTO 0)	:= x"0000";
	 CONSTANT USER_END_ADDRESS		: STD_LOGIC_VECTOR(15 DOWNTO 0)	:= x"7FFF";
	 
	 CONSTANT SYST_START_ADDRESS	: STD_LOGIC_VECTOR(15 DOWNTO 0)	:= x"8000";
	 CONSTANT SYST_END_ADDRESS		: STD_LOGIC_VECTOR(15 DOWNTO 0)	:= x"FFFF";
	 
	 
	 SIGNAL WR_bridge			:	STD_LOGIC := '0';		--permiso de escritura en SRAM
	 SIGNAL rd_sram			:	STD_LOGIC_VECTOR(15 downto 0);
	 SIGNAL ilegal_access	: 	STD_LOGIC := '0';
	 
begin
	
	--Como de A000 a BFFF los tres primeros bits no cambian, los restantes
	--son la direccion de la pantalla:
	--Ejemplo: A000 = 1010 0000 0000 0000 => (12DOWNTO0) => 0000 0000 0000 => Posicion 0 en la pantalla
	vga_addr <= addr(12 DOWNTO 0);
	
	vga_we <= 	we 	WHEN 	addr >= VGA_START_ADDRESS AND addr <= VGA_END_ADDRESS 		ELSE
					'0';
	
	vga_wr_data <= wr_data;
					
	rd_data <= 	vga_rd_data	WHEN (addr >= VGA_START_ADDRESS AND addr <= VGA_END_ADDRESS) ELSE
					rd_sram;
					
	
	vga_byte_m 	<= byte_m;
	
	ilegal_access <=	'1' WHEN (mode = '0' AND addr >= SYST_START_ADDRESS AND addr <= SYST_END_ADDRESS)	ELSE	
							'0';
	
	WR_bridge <= 	we WHEN (addr < VGA_START_ADDRESS AND ilegal_access = '0')	ELSE
						'0';
	
	ilegal_acc <= ilegal_access;
	
	sram: SRAMController
		Port Map(		clk			=> CLOCK_50,
							SRAM_ADDR	=> SRAM_ADDR,
							SRAM_DQ		=> SRAM_DQ,
							SRAM_UB_N	=> SRAM_UB_N,
							SRAM_LB_N	=> SRAM_LB_N,
							SRAM_CE_N	=> SRAM_CE_N,
							SRAM_OE_N	=> SRAM_OE_N,
							SRAM_WE_N	=> SRAM_WE_N,
							address		=> addr,
							dataReaded	=> rd_sram,
							dataToWrite	=> wr_data,
							WR				=> WR_bridge,
							byte_m		=> byte_m,
							not_align	=> not_align);
	
end comportament;
