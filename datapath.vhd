LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_signed.all;

ENTITY datapath IS
    PORT (clk    		: IN STD_LOGIC;
			 boot			: IN	STD_LOGIC;
			 exc			: IN STD_LOGIC := '0';
			 id_exc		: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          op     		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
          wrd    		: IN STD_LOGIC;
          addr_a 		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b 		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d 		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			 a_sys_rd 	: IN STD_LOGIC;
			 a_sys_wr 	: IN STD_LOGIC;
			 mask	 	 	: IN STD_LOGIC;
			 immed  		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 immed_x2  	: IN STD_LOGIC;
			 datard_m	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 ins_dad		: IN STD_LOGIC;
			 pc			: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 in_d			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			 y_b			: IN STD_LOGIC;
			 op_salt		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			 rd_io		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 async_exc	: IN STD_LOGIC := '0';
			 wr_io		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 addr_m		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 data_wr		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 jmp_addr	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
			 br_off		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
			 tknbr		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 int_enable	: OUT STD_LOGIC;
			 div_zero	: OUT STD_LOGIC := '0';
			 mode			: OUT STD_LOGIC);
END datapath;


ARCHITECTURE Structure OF datapath IS

    -- Aqui iria la declaracion de las entidades que vamos a usar
    -- Usaremos la palabra reservada COMPONENT ...
    -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades
	 
	COMPONENT alu IS
		PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				op : IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
				w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				z  : OUT STD_LOGIC;
				div_zero : OUT STD_LOGIC := '0');
	END COMPONENT;
	
	COMPONENT regfile IS
		PORT (clk  		: IN  STD_LOGIC;
			 boot			: IN	STD_LOGIC;
			 exc			: IN STD_LOGIC := '0';
			 async_exc	: IN STD_LOGIC := '0';
			 id_exc		: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          wrd    		: IN  STD_LOGIC;
          d      		: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a 		: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b 		: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d 		: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 a_sys_rd 	: IN  STD_LOGIC;
			 a_sys_wr 	: IN  STD_LOGIC;
			 mask	  		: IN  STD_LOGIC;
          a      		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 b      		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 int_enable	: OUT STD_LOGIC;
			 mode			: OUT STD_LOGIC);
	END COMPONENT;
	
	CONSTANT SALT_JALJMP	:	STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";
	CONSTANT SALT_JZ		:	STD_LOGIC_VECTOR(2 DOWNTO 0) := "110";
	CONSTANT SALT_JNZ		:	STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";
	CONSTANT SALT_BZ		:	STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
	CONSTANT SALT_BNZ		:	STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";
	CONSTANT SALT_RETI	:	STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
	
	--puentes entre modulos
	SIGNAL data_wr_reg	:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL w_out_alu		:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL ax				:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	--variables auxiliares
	SIGNAL immed_aux		:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL y_aux			:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL z_aux			:	STD_LOGIC;
	SIGNAL b_aux			:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	
BEGIN

    -- Aqui iria la declaracion del "mapeo" (PORT MAP) de los nombres de las entradas/salidas de los componentes
    -- En los esquemas de la documentacion a la instancia del banco de registros le hemos llamado reg0 y a la de la alu le hemos llamado alu0

	 data_wr_reg 	<= 	w_out_alu	WHEN in_d = "000"		ELSE
								datard_m		WHEN in_d = "001" 	ELSE
								pc	+ 2		WHEN in_d = "010" 	ELSE
								rd_io			WHEN in_d = "011"		ELSE
								pc				WHEN in_d = "100";
	 
	 immed_aux 		<=		immed	WHEN immed_x2 = '0'	ELSE
								immed(14 downto 0) & '0';
	 
	 reg0	:	regfile
		Port Map(		clk			=> clk,
							boot			=> boot,
							exc			=> exc,
							id_exc		=> id_exc,
							wrd			=> wrd,
							d				=> data_wr_reg,
							addr_a		=> addr_a,
							addr_b		=> addr_b,
							addr_d		=> addr_d,
							a_sys_rd		=> a_sys_rd,
							a_sys_wr		=> a_sys_wr,
							mask			=> mask,
							a				=> ax,
							b				=> b_aux,
							int_enable 	=> int_enable,
							async_exc	=> async_exc,
							mode			=>	mode);
	
	y_aux		<= immed_aux 	WHEN y_b = '0' ELSE
					b_aux;
	
	data_wr	<= b_aux;
	
	alu0	:	alu
		Port Map(		x	=> ax,
							y  => y_aux,
							op	=> op,
							w	=> w_out_alu,
							z	=> z_aux,
							div_zero	=> div_zero);
	 
	 
	 addr_m 	<= 	pc WHEN ins_dad = '0' ELSE
						w_out_alu;
	
	wr_io		<= b_aux;
	jmp_addr	<=	b_aux 	WHEN (op_salt = "010" AND exc = '0') ELSE -- op salt "010" indica RETI
					ax;
	br_off	<= immed_aux;
	tknbr		<=	"11" WHEN (op_salt = SALT_JALJMP OR op_salt = SALT_RETI OR exc = '1') 							ELSE	--Inconditional jumps, RETI o interrupcion
					"10" WHEN ((op_salt = SALT_JZ AND z_aux = '1') OR (op_salt = SALT_JNZ AND z_aux = '0'))	ELSE --Rest of jumps (conditional jumps)
					"01" WHEN ((op_salt = SALT_BZ AND z_aux = '1') OR (op_salt = SALT_BNZ AND z_aux = '0'))	ELSE	--Branchs
					"00";	--Rest of operations
	
END Structure;