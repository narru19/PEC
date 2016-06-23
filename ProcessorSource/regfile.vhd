LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
--USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER

ENTITY regfile IS
    PORT (clk    		: IN  STD_LOGIC;
			 boot			: IN	STD_LOGIC;
			 exc			: IN STD_LOGIC := '0';
			 async_exc	: IN STD_LOGIC := '0';
			 id_exc		: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          wrd    		: IN  STD_LOGIC := '0';
          d     		: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a 		: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b 		: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_d 		: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 a_sys_rd  	: IN STD_LOGIC;
			 a_sys_wr  	: IN STD_LOGIC;
			 mask	  		: IN STD_LOGIC; -- si activado, solo deja escribir en el bit 1 (ENABLE/DISABLE INTERRUPT) de sys(1)
          a      		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 b		  		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 int_enable	: OUT STD_LOGIC;
			 mode			: OUT STD_LOGIC);
END regfile;


ARCHITECTURE Structure OF regfile IS
	CONSTANT RSG_DIR	:	STD_LOGIC_VECTOR := x"D000"; --REVISAR

	TYPE 		register_bank IS ARRAY(7 DOWNTO 0) of STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL	registers_user	: register_bank;
	SIGNAL	registers_sys	: register_bank;
	
	SIGNAL	prev_reti_write : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL	prev_reti 		 : STD_LOGIC := '0';
	
BEGIN

	a <= 	registers_sys(5)								WHEN exc = '1' 		ELSE --leer S5 para ponerlo en el PC en caso de excepcion
			registers_user(conv_integer(addr_a)) 	WHEN a_sys_rd = '0' 	ELSE
			registers_sys(conv_integer(addr_a)) 	WHEN a_sys_rd = '1';
			
	b <= 	registers_user(conv_integer(addr_b))	WHEN a_sys_rd = '0' 	ELSE
			registers_sys(conv_integer(addr_b)) 	WHEN a_sys_rd = '1';
			
	int_enable <= registers_sys(7)(1);
	
	mode <= registers_sys(7)(0);

	PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			
			IF prev_reti = '1' THEN
				registers_sys(7) 	<= prev_reti_write;
				prev_reti <= '0';
			END IF;
			
			IF wrd = '1' THEN
				IF exc = '1' THEN --preparacion de excepcio
					registers_sys(0) <= registers_sys(7);
					registers_sys(1) <= d;
					registers_sys(2) <= x"000" & id_exc;
					registers_sys(7)(1 DOWNTO 0) <= "01"; --PSW
				
				ELSIF a_sys_wr = '1' AND (async_exc = '0' OR id_exc = x"F" OR id_exc = x"E") AND mask = '1' THEN	-- DI or EI
					registers_sys(7)(1) 	<= d(0);
				
				ELSIF (a_sys_wr = '1' AND (async_exc = '0' OR id_exc = x"F" OR id_exc = x"E")) THEN	--WRS + no excepcio OR interrupt 
					IF addr_d = "111" THEN
						prev_reti <= '1';
						prev_reti_write <= d;
					ELSE
						registers_sys(conv_integer(addr_d)) 	<= d;
					END IF;
				ELSIF (a_sys_wr = '0' AND (async_exc = '0' OR id_exc = x"F" OR id_exc = x"E")) THEN	--WR	+ no excepcio OR interrupt
					registers_user(conv_integer(addr_d)) 	<= d;
				END IF;				
			END IF;
			
			IF boot = '1' THEN --inicializacion de registros de sistema
					registers_sys(5) <= RSG_DIR;
					registers_sys(7)(2 DOWNTO 0) <= "001";	-- bit 0 a 1 ya que PSW = 1 para declarar rutina exc
			END IF;
		END IF;
	END PROCESS;
	
END Structure;