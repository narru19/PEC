
module DE2_Audio_Example (
	
	CLOCK_50,
	CLOCK_27,
	KEY,

	AUD_ADCDAT,

	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	I2C_SCLK,
	SW
);


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input				CLOCK_27;
input				[3:0]	KEY;
input				[3:0]	SW;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				I2C_SDAT;

// Outputs
output			AUD_XCK;
output			AUD_DACDAT;

output			I2C_SCLK;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire				[31:0]	left_channel_audio_in;
wire			   [31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire			   [31:0]	left_channel_audio_out;
wire				[31:0]	right_channel_audio_out;
wire				write_audio_out;


/* 
	
	Wires i regs fets servir per a la reproduccio d'audio.
	
	delay_cnt => comptador fet servir per a generar una ona amb una determinada frequencia
	notes 	 => vector de senyals amb els valors que el conversor DAC prendra per a generar les notes
	temps     => vector de senyals amb els valors de durada de cada nota
	index_seq => index que indica a quina posicio dels vectors accedir
	iter 		 => comptador que serveix per a generar la frequencia de la nota en questio
	snd		 => es nega constantment, serveix per a generar una ona amb una frequencia igual a la frequencia amb que aquesta canvia de valor

*/
reg [28:0] delay_cnt;
wire[31:0] notes [19:0];
wire[31:0] temps [19:0];
reg [31:0] index_seq = 0;
reg [31:0] iter = 0;
reg snd = 0;


assign notes[0] = 32'd46750; // C5
assign notes[1] = 32'd50000; // B4
assign notes[2] = 32'd56000; // A4
assign notes[3] = 32'd63000; // G4
assign notes[4] = 32'd72750; // E4
assign notes[5] = 32'd63000; // G4
assign notes[6] = 32'd46750; // C5
assign notes[7] = 32'd37000; // E5
assign notes[8] = 32'd1;
assign notes[9] = 32'd35375;
assign notes[10] = 32'd37000;
assign notes[11] = 32'd41875; 
assign notes[12] = 32'd46750;
assign notes[13] = 32'd63000;
assign notes[14] = 32'd46750;
assign notes[15] = 32'd37000;
assign notes[16] = 32'd41875; //CHECK
assign notes[17] = 32'd46750;
assign notes[18] = 32'd1;

assign temps[0] = 48000000;
assign temps[1] = 36000000;
assign temps[2] = 12000000;
assign temps[3] = 12000000;
assign temps[4] = 12000000;
assign temps[5] = 12000000;
assign temps[6] = 12000000;
assign temps[7] = 36000000;
assign temps[8] = 12000000;
assign temps[9] = 24000000;
assign temps[10] = 18000000;
assign temps[11] = 6000000;
assign temps[12] = 12000000;
assign temps[13] = 12000000;
assign temps[14] = 12000000;
assign temps[15] = 12000000;
assign temps[16] = 48000000;
assign temps[17] = 48000000;
assign temps[18] = 48000000;


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

 
 /*
	En aquest process fem sonar una nota durant un temps determinat.
 */
always @(posedge CLOCK_50)
begin
	if(iter == temps[index_seq])
	begin
		if(index_seq < 18)
			index_seq <= index_seq + 1;
		else
			index_seq <= 0;
		iter <= 0;
	end
	else
		iter <= iter + 1;
end
	
/*
	En aquest process el senyal 'snd' canvia tan rapid com la frequencia de la nota que volem generar
*/
always @(posedge CLOCK_50)
begin
	if(delay_cnt >= notes[index_seq])
	begin
		delay_cnt <= 0;
		snd <= !snd;
	end
	else
		delay_cnt <= delay_cnt + 1;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

//assign delay = {SW[3:0], 15'd3000};

/*
	En aquesta linia de codi simplement mirem que com a minim un polsador estigui en posicio de '0' logic
	Si es aixi, es genera la melodia.
*/
wire [31:0] sound = (SW == 0) ? 0 : snd ? 32'd200000000: -32'd200000000;


assign read_audio_in					= audio_in_available & audio_out_allowed;
assign left_channel_audio_out	   = sound;
assign right_channel_audio_out	= sound;
assign write_audio_out			   = 1;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset							(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in					(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out				(write_audio_out),

	.AUD_ADCDAT						(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK						(AUD_BCLK),
	.AUD_ADCLRCK					(AUD_ADCLRCK),
	.AUD_DACLRCK					(AUD_DACLRCK),

	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK							(AUD_XCK),
	.AUD_DACDAT						(AUD_DACDAT),

);

avconf #(.USE_MIC_INPUT(1)) avc (

	.I2C_SCLK					(I2C_SCLK),
	.I2C_SDAT					(I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule

