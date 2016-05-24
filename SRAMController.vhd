library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SRAMController is
    port (clk         : in    std_logic;
          -- senales para la placa de desarrollo
          SRAM_ADDR   : out   std_logic_vector(17 downto 0);
          SRAM_DQ     : inout std_logic_vector(15 downto 0);
          SRAM_UB_N   : out   std_logic;
          SRAM_LB_N   : out   std_logic;
          SRAM_CE_N   : out   std_logic := '1';
          SRAM_OE_N   : out   std_logic := '1';
          SRAM_WE_N   : out   std_logic := '1';
          -- senales internas del procesador
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(15 downto 0);
          dataToWrite : in    std_logic_vector(15 downto 0);
          WR          : in    std_logic := '0';
          byte_m      : in    std_logic := '0';
			 not_align	 : OUT	STD_LOGIC := '0');
end SRAMController;

architecture comportament of SRAMController is
	
	--indica si se ha hecho una lectura el ciclo anterior, para leer el valor
	SIGNAL READING	:	STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	SIGNAL EXT		:	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL WR_STATE	:	INTEGER := 0;
	
begin
	
	-- Senyals independents del clk
	SRAM_ADDR <= "000" & address(15 DOWNTO 1);
	SRAM_OE_N <= '0';
	
	EXT <= 	(OTHERS => SRAM_DQ(7)) 	WHEN byte_m ='1' AND address(0) = '0' ELSE
				(OTHERS => SRAM_DQ(15));
	dataReaded	<=	EXT & SRAM_DQ(7 DOWNTO 0)	WHEN byte_m = '1' AND address(0) = '0' ELSE
						EXT & SRAM_DQ(15 DOWNTO 8)	WHEN byte_m = '1' AND address(0) = '1' ELSE
						SRAM_DQ;
	
	SRAM_DQ	<= (OTHERS => 'Z') WHEN WR = '0' ELSE
					dataToWrite(7 DOWNTO 0) & dataToWrite(7 DOWNTO 0) WHEN WR = '1' AND byte_m = '1' ELSE ---modificar en 2 casos
					dataToWrite;
	
	--SRAM_LB_N siempre es 0 cuando address(0) = 0 independientemente de byte_m y WR
	SRAM_LB_N	<= '0' WHEN address(0) = '0' ELSE
						'1';
	
	SRAM_UB_N	<= '0' WHEN (address(0) XOR byte_m) = '0' ELSE
						'1';
						
	
	PROCESS(clk)
	BEGIN
		
		IF rising_edge(clk) THEN
			not_align <= '0';
			IF WR = '0' THEN		-- Lectura
				--WR_STATE <= '0'; Descomentar per si hi ha lectura abans d'acabar escriptura (estat0..7)
				SRAM_CE_N <= '0';
				SRAM_WE_N <= '1';
				
				IF (byte_m = '0' AND address(0) = '1') THEN
					not_align <= '1';
				END IF;
				
			ELSIF WR = '1' THEN	--Escriptura
				CASE WR_STATE IS
					WHEN 0 =>						--Estat 1 - Activacio
						SRAM_CE_N <= '0';
						IF byte_m = '1' THEN 	-- Escriptura de byte
							SRAM_WE_N <= '0';
							WR_STATE <= WR_STATE + 1;
						ELSIF address(0) = '0' THEN 	-- Escriptura de word alineat
							SRAM_WE_N <= '0';
							WR_STATE <= WR_STATE + 1;
						ELSE --desactiva permis en cas de escritura de word no alineat
							not_align <= '1';
							SRAM_WE_N <= '1';
						END IF;
				
					WHEN 1 =>						--Estat 2 - Desactivacio
						SRAM_WE_N 	<= '1';
						SRAM_CE_N 	<= '1';
						WR_STATE 	<= WR_STATE + 1;
						
					WHEN OTHERS =>					--Estat 3..7 - No fem res
						IF WR_STATE = 7 THEN		--Estat 7 - Reset
							WR_STATE <= 0;
						ELSE
							WR_STATE <= WR_STATE + 1;
						END IF;
						
				END CASE;
				
			END IF;
		END IF;
	END PROCESS;
	
end comportament;
