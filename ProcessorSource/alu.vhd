LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_signed.all;


ENTITY alu IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          z  : OUT STD_LOGIC;
			 div_zero : OUT STD_LOGIC := '0');
END alu;


ARCHITECTURE Structure OF alu IS

CONSTANT OP_MOVI 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
CONSTANT OP_MOVHI 	:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "00001";

CONSTANT OP_AND 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "00010";
CONSTANT OP_OR 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "00011";
CONSTANT OP_XOR 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "00100";
CONSTANT OP_NOT 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "00101";
CONSTANT OP_ADD 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "00110";
CONSTANT OP_SUB 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "00111";

CONSTANT OP_SHA 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "01000";
CONSTANT OP_SHL 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "01001";

CONSTANT OP_MUL 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "01010";
CONSTANT OP_MULH 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "01011";
CONSTANT OP_MULHU 	:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "01100";
CONSTANT OP_DIV 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "01101";
CONSTANT OP_DIVU 		:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "01110";

CONSTANT OP_CMPLT 	:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "01111";
CONSTANT OP_CMPLE 	:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "10000";
CONSTANT OP_CMPEQ 	:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "10001";
CONSTANT OP_CMPLTU 	:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "10010";
CONSTANT OP_CMPLEU 	:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "10011";

CONSTANT OP_Y			:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "11110";

CONSTANT TRUE			:	STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000001";
CONSTANT FALSE			:	STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";

SIGNAL AUX_MULT		:	STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL AUX_MULTU		:	STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL AUX_DIV			:	STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL AUX_DIVU 		:	STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL AUX_CMPLT	:	STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL AUX_CMPLE	:	STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL AUX_CMPEQ	:	STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL AUX_CMPLTU	:	STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL AUX_CMPLEU	:	STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
	
	AUX_DIV <= std_logic_vector(signed(x) / signed(y));
	AUX_DIVU <= std_logic_vector(unsigned(x) / unsigned(y));
	
	AUX_MULT <= std_logic_vector(signed(x) * signed(y));
	AUX_MULTU <= std_logic_vector(unsigned(x) * unsigned(y));
	
	AUX_CMPLT <= 	TRUE WHEN signed(x) < signed(y) ELSE
			FALSE;	
	AUX_CMPLE <= 	TRUE WHEN signed(x) <= signed(y) ELSE
			FALSE;	
	AUX_CMPEQ <= 	TRUE WHEN signed(x) = signed(y) ELSE
			FALSE;			
	AUX_CMPLTU <= 	TRUE WHEN unsigned(x) < unsigned(y) ELSE
			FALSE;	
	AUX_CMPLEU <= 	TRUE WHEN unsigned(x) <= unsigned(y) ELSE
			FALSE;	
			
    w <=			y(15 DOWNTO 0) 						WHEN op = OP_MOVI		ELSE
					y(7 DOWNTO 0) & x(7 DOWNTO 0) 	WHEN op = OP_MOVHI	ELSE
					x AND y									WHEN op = OP_AND		ELSE
					x OR y									WHEN op = OP_OR		ELSE
					x XOR y									WHEN op = OP_XOR		ELSE
					NOT x										WHEN op = OP_NOT		ELSE
					x + y										WHEN op = OP_ADD		ELSE
					x - y										WHEN op = OP_SUB		ELSE
					to_stdlogicvector(to_bitvector(x) SLL to_integer(signed(y(4 DOWNTO 0)))) WHEN op = OP_SHL	ELSE
					to_stdlogicvector(to_bitvector(x) SLA to_integer(signed(y(4 DOWNTO 0)))) WHEN op = OP_SHA and (signed(y) <0) ELSE
					to_stdlogicvector(to_bitvector(x) SLL to_integer(signed(y(4 DOWNTO 0)))) WHEN op = OP_SHA and (signed(y)>=0) ELSE
					AUX_MULT(15 DOWNTO 0) 				WHEN op = OP_MUL 		ELSE
					AUX_MULT(31 DOWNTO 16)				WHEN op = OP_MULH 	ELSE
					AUX_MULTU(31 DOWNTO 16)				WHEN op = OP_MULHU	ELSE
					AUX_DIV									WHEN op = OP_DIV		ELSE
					AUX_DIVU									WHEN op = OP_DIVU		ELSE
					AUX_CMPLT								WHEN op = OP_CMPLT 	ELSE
					AUX_CMPLE								WHEN op = OP_CMPLE 	ELSE
					AUX_CMPEQ								WHEN op = OP_CMPEQ 	ELSE
					AUX_CMPLTU								WHEN op = OP_CMPLTU 	ELSE
					AUX_CMPLEU								WHEN op = OP_CMPLEU 	ELSE
					y											WHEN op = OP_Y			ELSE --dejamos pasar la entrada y
					x;											-- por defecto dejamos pasar la x
			
	z <= 	'1' WHEN (y = FALSE) ELSE
			'0';

	div_zero <= 	'1' WHEN ((op = OP_DIV OR op = OP_DIVU) AND y = FALSE) ELSE
						'0';
	
END Structure;
