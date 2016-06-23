library ieee;
USE ieee.std_logic_1164.all;

entity multi is
    port(clk       	: IN  STD_LOGIC;
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
			exc	 		: OUT STD_LOGIC := '0'; 	-- Si hay o no excepcion emmascarada para poder leerlo solo al acabar DEMW
			id_exc		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			async_exc	: OUT STD_LOGIC := '0');	
end entity;

architecture Structure of multi is


	CONSTANT FETCH		:	STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	CONSTANT DEMW		:	STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
	CONSTANT SYSTEM	:	STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";
	
	CONSTANT EXCCODE_ILEGAL_INSTR		: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	CONSTANT EXCCODE_UNALIGNED			: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
	CONSTANT EXCCODE_DIV_ZERO			: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
	CONSTANT EXCCODE_ILEGAL_MEMACC	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011";
	CONSTANT EXCCODE_WRONG_MODE		: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
	CONSTANT EXCCODE_CALLS				: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
	CONSTANT EXCCODE_INTERRUPT			: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	
	SIGNAL PREV_STATE :  STD_LOGIC_VECTOR(1 DOWNTO 0) := FETCH;
	SIGNAL STATE		:	STD_LOGIC_VECTOR(1 DOWNTO 0) := FETCH;
	SIGNAL int_prep	:	STD_LOGIC := '0';
	SIGNAL id			: 	STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	SIGNAL exception	:  STD_LOGIC := '0';

begin

	exception <=	'1' WHEN (ilegal_ins = '1') 														OR		--0:	ilegal instruction
									(not_align = '1' AND (load_store = '1' OR STATE = FETCH)) 	OR 	--1:	load/store unalgined
									(div_zero = '1') 															OR		--4:	division by zero
									(ilegal_acc = '1' AND mem_instr = '1' AND STATE = DEMW)		OR		--11: ilegal access in memory with resp. to the mode
									(mode_exc = '1')															OR 	--13:	ilegal execution with resp. to the mode
									(calls = '1' AND STATE = DEMW) 										OR		--14:	calls
									(intr_1 = '1' AND int_enable = '1' AND STATE = DEMW)			ELSE	--15:	interrupt
						'0';
						
	
	id	<= 				EXCCODE_ILEGAL_INSTR 		WHEN  (ilegal_ins = '1') 														ELSE
							EXCCODE_UNALIGNED				WHEN	(not_align = '1' AND (load_store = '1' OR STATE = FETCH)) 	ELSE 
							EXCCODE_DIV_ZERO				WHEN	(div_zero = '1') 															ELSE
							EXCCODE_ILEGAL_MEMACC		WHEN	(ilegal_acc = '1' AND mem_instr = '1')								ELSE
							EXCCODE_WRONG_MODE			WHEN	(mode_exc = '1')															ELSE
							EXCCODE_CALLS					WHEN	(calls = '1' AND STATE = DEMW)										ELSE
							EXCCODE_INTERRUPT				WHEN	(intr_1 = '1' AND int_enable = '1' AND STATE = DEMW);
						
	async_exc <= exception;
	
	PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF (boot = '1') THEN	--Si boot, FETCH de la primera instr	
				STATE <= FETCH;
			ELSIF STATE = SYSTEM THEN	
				STATE <= FETCH;
			ELSIF (exception = '1' AND PREV_STATE /= SYSTEM) THEN
				STATE <= SYSTEM;
				id_exc <= id;
			ELSIF STATE = DEMW THEN
				STATE <= FETCH;
			ELSE
				STATE <= DEMW;
			END IF;
			PREV_STATE <= STATE;
		END IF;
	END PROCESS;
	 
	 PROCESS(clk, STATE, wrd_1, wr_m_1, w_b, wr_out_1, intr_1, ilegal_ins, not_align, div_zero, load_store)
	 BEGIN
			IF STATE = DEMW THEN
				ldpc  		<= ldpc_1;
				wrd 			<= wrd_1;
				wr_m			<= wr_m_1;
				word_byte 	<= w_b;
				ins_dad		<= '1';
				ldir			<= '0';
				wr_out		<= wr_out_1;
				in_d			<= in_d_1;
			ELSIF STATE = FETCH THEN
				ldpc 			<= '0';
				wrd 			<= '0';
				wr_m			<= '0';
				word_byte 	<= '0';
				ins_dad		<= '0';
				ldir			<= '1';
				wr_out		<= '0';
				in_d			<= in_d_1;
			ELSIF STATE = SYSTEM THEN
				ldpc 			<= '1';
				wrd 			<= '1';
				wr_m			<= '0';
				word_byte 	<= '0';
				ins_dad		<= '0';
				ldir			<= '0';
				wr_out		<= '0';
				in_d			<= "100";
			END IF;
			
			IF STATE = SYSTEM THEN
				exc <= '1';
			ELSE
				exc <= '0';
			END IF;
				
	 END PROCESS;
									
	 
end Structure;
