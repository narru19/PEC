LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY unidad_control IS
    PORT (boot   		: IN  STD_LOGIC;
          clk    		: IN  STD_LOGIC;
          datard_m 	: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 jmp_addr	: IN 	STD_LOGIC_VECTOR(15 DOWNTO 0); -- address de los saltos absolutos (jmp)
			 br_off		: IN 	STD_LOGIC_VECTOR(15 DOWNTO 0);  -- offset para los saltos relativos (BR)
			 tknbr		: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);  --senyal de control del pc
			 intr			: IN 	STD_LOGIC; --interrupcion
			 not_align	: IN 	STD_LOGIC; --acceso no alineado
			 div_zero	: IN 	STD_LOGIC; --division por cero
			 int_enable	: IN 	STD_LOGIC;
			 mode			: IN 	STD_LOGIC;
			 ilegal_acc	: IN 	STD_LOGIC;
          op     		: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
          wrd    		: OUT STD_LOGIC;
          addr_a 		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b 		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d 		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc     		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 ins_dad		: OUT STD_LOGIC;
			 in_d			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			 immed_x2	: OUT STD_LOGIC;
			 wr_m			: OUT STD_LOGIC := '0';
			 word_byte	: OUT STD_LOGIC;
			 y_b			: OUT STD_LOGIC;
			 op_salt		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_io		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 wr_out		: OUT STD_LOGIC := '0';
			 rd_in		: OUT STD_LOGIC;
			 a_sys_rd 	: OUT STD_LOGIC;
			 a_sys_wr 	: OUT STD_LOGIC;
			 mask	 	 	: OUT STD_LOGIC;
			 inta			: OUT STD_LOGIC;
			 exc			: OUT STD_LOGIC := '0';
			 id_exc		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			 async_exc	: OUT STD_LOGIC := '0');
END unidad_control;

ARCHITECTURE Structure OF unidad_control IS

    -- Aqui iria la declaracion de las entidades que vamos a usar
    -- Usaremos la palabra reservada COMPONENT ...
    -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades
    -- Aqui iria la definicion del program counter

	COMPONENT control_l IS
		PORT (ir     		: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 mode			: IN  STD_LOGIC;
          op     		: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
          ldpc   		: OUT STD_LOGIC;
          wrd    		: OUT STD_LOGIC;
          addr_a 		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b 		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d 		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_m	  		: OUT STD_LOGIC := '0';
			 in_d			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			 immed_x2	: OUT STD_LOGIC;
			 word_byte	: OUT STD_LOGIC;
			 y_b			: OUT STD_LOGIC;
			 op_salt		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_io		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 wr_out		: OUT STD_LOGIC := '0';
			 rd_in		: OUT STD_LOGIC;
			 a_sys_rd 	: OUT STD_LOGIC;
			 a_sys_wr 	: OUT STD_LOGIC;
			 mask	 	 	: OUT STD_LOGIC;
			 inta			: OUT STD_LOGIC := '0';
			 ilegal_ins : OUT STD_LOGIC := '0';
			 load_store : OUT STD_LOGIC := '0';
			 calls		: OUT STD_LOGIC := '0';
			 mode_exc	: OUT STD_LOGIC := '0';
			 mem_instr	: OUT STD_LOGIC);
	END COMPONENT;
	 
	 COMPONENT multi IS
		PORT(clk       : IN  STD_LOGIC;
         boot      	: IN  STD_LOGIC;
			int_enable	: IN	STD_LOGIC;	--Nos informa si las interrupciones estan activadas
         ldpc_1    	: IN  STD_LOGIC;
         wrd_1     	: IN  STD_LOGIC;
         wr_m_1    	: IN  STD_LOGIC;
         w_b       	: IN  STD_LOGIC;
			wr_out_1	 	: IN	STD_LOGIC;
			in_d_1	 	: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			intr_1	 	: IN  STD_LOGIC := '0';		-- Si hay o no interrupt
			ilegal_ins	: IN  STD_LOGIC := '0';
			not_align	: IN  STD_LOGIC := '0';
			div_zero		: IN  STD_LOGIC := '0';
			load_store	: IN  STD_LOGIC := '0';
			calls			: IN  STD_LOGIC;
			mode_exc		: IN 	STD_LOGIC;
			ilegal_acc	: IN	STD_LOGIC;
			mem_instr	: IN  STD_LOGIC;
         ldpc      	: OUT STD_LOGIC;
         wrd      	: OUT STD_LOGIC;
         wr_m     	: OUT STD_LOGIC := '0';
         ldir    	  	: OUT STD_LOGIC;
         ins_dad 	  	: OUT STD_LOGIC;
         word_byte 	: OUT STD_LOGIC;
			wr_out	 	: OUT STD_LOGIC := '0';
			in_d		 	: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			exc	 		: OUT STD_LOGIC := '0'; 	
			id_exc		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			async_exc	: OUT STD_LOGIC := '0');	
	END COMPONENT;
	 
	 --Ponts entre logica de control i multi
	 SIGNAL wrd_bridge			:	STD_LOGIC;
	 SIGNAL ldpc_bridge			:	STD_LOGIC;
	 SIGNAL wr_m_bridge			:	STD_LOGIC;
	 SIGNAL word_byte_bridge	:	STD_LOGIC;
	 SIGNAL wr_out_bridge		:  STD_LOGIC;
	 SIGNAL in_d_bridge			:  STD_LOGIC_VECTOR(2 DOWNTO 0);
	 SIGNAL calls_bridge			:	STD_LOGIC	:= '0';
	 SIGNAL mode_exc_bridge		:	STD_LOGIC	:= '0';
	 SIGNAL mem_instr_bridge	:	STD_LOGIC;
	 
	 --Ponts entre multi i logica de control
	 SIGNAL ldir_bridge	:	STD_LOGIC;
	 
	 --Ponts auxiliars
	 SIGNAL ldpc_bridge_out	:	STD_LOGIC;
	 
	 --Auxiliars
	 SIGNAL instr	:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	 
	 SIGNAL COUNTER	:	STD_LOGIC_VECTOR(15 DOWNTO 0) := x"C000";
	 
	 SIGNAL ilegal_ins, load_store : STD_LOGIC := '0';
	 
BEGIN


	--Seleccio d'instruccio
	PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF boot = '1' THEN
				instr <= (OTHERS => '0');
			ELSIF ldir_bridge = '1' THEN
				instr <= datard_m;
			END IF;
		END IF;
	END PROCESS;

	--Seleccio next pc
	PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF boot = '1' THEN
				COUNTER <= x"C000";
			ELSIF ldpc_bridge_out = '1'  THEN 
				CASE tknbr IS
					WHEN "00" => COUNTER <= COUNTER + 2;				
					WHEN "01" => COUNTER <= COUNTER + 2 + br_off;
					WHEN "10" => COUNTER <= jmp_addr;
					WHEN "11" => COUNTER <= jmp_addr;
					WHEN OTHERS => COUNTER <= COUNTER;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	
	pc <= COUNTER;
	
	c1	:	control_l	
		Port Map(	ir 			=> instr,
						immed_x2 	=> immed_x2,
						in_d 			=> in_d_bridge,
						ldpc			=> ldpc_bridge,
						word_byte	=> word_byte_bridge,
						wr_m			=> wr_m_bridge,
						wrd			=> wrd_bridge,
						op				=> op,
						addr_a		=> addr_a,
						addr_b		=> addr_b,
						addr_d		=> addr_d,
						immed			=> immed,
						y_b 			=> y_b,
						op_salt		=> op_salt,
						addr_io		=> addr_io,
						wr_out		=> wr_out_bridge,
						rd_in			=> rd_in,
						a_sys_rd		=> a_sys_rd,
						a_sys_wr		=> a_sys_wr,
						mask			=> mask,
						inta 			=> inta,
						ilegal_ins  => ilegal_ins,
						load_store	=> load_store,
						calls			=> calls_bridge,
						mode			=> mode,
						mode_exc		=> mode_exc_bridge,
						mem_instr	=> mem_instr_bridge);
				
	m0	:	multi	
		Port Map(	boot			=> boot,
						clk			=> clk,
						int_enable	=> int_enable,
						ldpc_1		=> ldpc_bridge,
						w_b			=>	word_byte_bridge,
						wr_m_1		=> wr_m_bridge,
						wrd_1			=> wrd_bridge,
						wr_out_1		=> wr_out_bridge,
						in_d_1		=> in_d_bridge,
						intr_1		=> intr,
						ilegal_ins	=> ilegal_ins,
						not_align	=> not_align,
						div_zero		=> div_zero,
						ins_dad		=> ins_dad,
						ldir			=> ldir_bridge,
						ldpc			=> ldpc_bridge_out,
						word_byte	=> word_byte,
						wr_m			=> wr_m,
						wrd			=> wrd,
						wr_out		=> wr_out,
						exc			=> exc,
						id_exc		=> id_exc,
						in_d			=> in_d,
						load_store	=> load_store,
						async_exc	=> async_exc,
						calls			=> calls_bridge,
						mode_exc		=> mode_exc_bridge,
						ilegal_acc	=> ilegal_acc,
						mem_instr	=> mem_instr_bridge);


END Structure;