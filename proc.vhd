LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY proc IS
    PORT (	clk      	: IN  STD_LOGIC;
				boot     	: IN  STD_LOGIC := '1';
				datard_m 	: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				addr_m   	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				data_wr   	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_m     	: OUT STD_LOGIC := '0';
				word_byte  	: OUT STD_LOGIC;
				addr_io		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				wr_io			: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				rd_io			: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_out		: OUT STD_LOGIC := '0';
				rd_in			: OUT STD_LOGIC;
				inta			: OUT STD_LOGIC := '0';
				intr			: IN  STD_LOGIC := '0';
				not_align	: IN  STD_LOGIC;	--acceso no alineado
				mode			: OUT STD_LOGIC;
				ilegal_acc	: IN	STD_LOGIC); 
END proc;


ARCHITECTURE Structure OF proc IS

   COMPONENT unidad_control IS
		PORT (boot   	: IN STD_LOGIC;
          clk    		: IN STD_LOGIC;
          datard_m 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 jmp_addr	: IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- address de los saltos absolutos (jmp)
			 br_off		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);  -- offset para los saltos relativos (BR)
			 tknbr		: IN STD_LOGIC_VECTOR(1 DOWNTO 0);  --senyal de control del pc
          intr			: IN STD_LOGIC;
			 not_align	: IN STD_LOGIC; --acceso no alineado
			 div_zero	: IN STD_LOGIC; --division por cero
			 int_enable	: IN STD_LOGIC;
			 mode			: IN STD_LOGIC;
			 ilegal_acc	: IN STD_LOGIC;
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
   END COMPONENT;
    
	COMPONENT datapath IS
		PORT (clk    	: IN STD_LOGIC;
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
    END COMPONENT;

	SIGNAL bridge_immed_x2  	:	STD_LOGIC;
	SIGNAL bridge_in_d 			:	STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL bridge_ins_dad 		:	STD_LOGIC;
	SIGNAL bridge_wrd 			:	STD_LOGIC;
	SIGNAL bridge_op				: 	STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL bridge_addr_a 		:	STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL bridge_addr_b 		:	STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL bridge_addr_d 		:	STD_LOGIC_VECTOR(2 DOWNTO 0); 
   SIGNAL bridge_immed 			:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL bridge_pc 				:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL bridge_y_b				:	STD_LOGIC;
	SIGNAL bridge_op_salt		:	STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL bridge_jmp_addr		:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL bridge_br_off			:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL bridge_tknbr			:	STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL bridge_a_sys_rd		:	STD_LOGIC;
	SIGNAL bridge_a_sys_wr		:	STD_LOGIC;
	SIGNAL bridge_mask			:	STD_LOGIC;
	SIGNAL bridge_exc				:	STD_LOGIC := '0';
	SIGNAL bridge_id_exc 		:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL bridge_int_enable	: 	STD_LOGIC;
	SIGNAL bridge_div_zero		: 	STD_LOGIC := '0';
	SIGNAL bridge_async_exc 	:	STD_LOGIC := '0';
	SIGNAL bridge_mode			:	STD_LOGIC;
    
BEGIN

	 mode <= bridge_mode;

    c0	:	unidad_control	
		Port Map(		boot			=> boot,
							clk			=> clk,
							datard_m		=> datard_m,
							jmp_addr		=> bridge_jmp_addr,
							br_off		=> bridge_br_off,
							tknbr			=> bridge_tknbr,
							immed_x2 	=> bridge_immed_x2,
							in_d			=> bridge_in_d,
							ins_dad		=> bridge_ins_dad,
							word_byte	=> word_byte,
							wr_m			=> wr_m,
							wrd			=> bridge_wrd,
							op				=> bridge_op,
							addr_a		=> bridge_addr_a,
							addr_b		=> bridge_addr_b,
							addr_d		=> bridge_addr_d,
							immed			=> bridge_immed,
							pc				=> bridge_pc,
							y_b			=> bridge_y_b,
							op_salt		=> bridge_op_salt,
							addr_io		=> addr_io,
							wr_out		=> wr_out,
							rd_in			=> rd_in,
							a_sys_rd		=> bridge_a_sys_rd,
							a_sys_wr		=> bridge_a_sys_wr,
							mask			=> bridge_mask,
							inta			=> inta,
							exc			=> bridge_exc,
							id_exc		=> bridge_id_exc,
							int_enable 	=> bridge_int_enable,
							intr			=> intr,
							div_zero		=> bridge_div_zero,
							not_align 	=> not_align,
							async_exc	=> bridge_async_exc,
							mode			=>	bridge_mode,
							ilegal_acc	=> ilegal_acc);
		
	e0	:	datapath	
		Port Map(		clk			=> clk,
							boot			=> boot,
							exc			=> bridge_exc,
							id_exc		=> bridge_id_exc,
							immed_x2 	=> bridge_immed_x2,
							in_d			=> bridge_in_d,
							ins_dad		=> bridge_ins_dad,
							wrd			=> bridge_wrd,
							op				=> bridge_op,
							addr_a		=> bridge_addr_a,
							addr_b		=> bridge_addr_b,
							addr_d		=> bridge_addr_d,
							a_sys_rd		=> bridge_a_sys_rd,
							a_sys_wr		=> bridge_a_sys_wr,
							mask			=> bridge_mask,
							immed			=> bridge_immed,
							datard_m		=> datard_m,
							pc 			=> bridge_pc,
							y_b			=> bridge_y_b,
							op_salt		=> bridge_op_salt,
							addr_m		=> addr_m,
							data_wr		=> data_wr,
							jmp_addr		=> bridge_jmp_addr,
							br_off		=> bridge_br_off,
							tknbr			=> bridge_tknbr,
							wr_io			=> wr_io,
							rd_io			=> rd_io,
							int_enable	=> bridge_int_enable,
							div_zero		=> bridge_div_zero,
							async_exc	=> bridge_async_exc,
							mode			=>	bridge_mode); 
							
    
END Structure;