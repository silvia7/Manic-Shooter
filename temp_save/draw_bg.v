

//module draw_bg(begin_draw, clk, address, x, y, color, drawEn, done);
module proj	
	(
		CLOCK_50,						//	On Board 50 MHz
		SW,							//	Push Button[0:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,	  						//	VGA Blue[9:0]
		KEY
	);

	input	CLOCK_50;				//	50 MHz
	input	[3:0] KEY;				//	Button[0:0]
	input	[17:0] SW;				//	Button[0:0]
	output	VGA_CLK;   				//	VGA Clock
	output	VGA_HS;					//	VGA H_SYNC
	output	VGA_VS;					//	VGA V_SYNC
	output	VGA_BLANK;				//	VGA BLANK
	output	VGA_SYNC;				//	VGA SYNC
	output	[9:0] VGA_R;   			//	VGA Red[9:0]
	output	[9:0] VGA_G;	 		//	VGA Green[9:0]
	output	[9:0] VGA_B;   			//	VGA Blue[9:0]

	wire resetn;
	assign resetn =KEY[1];
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(color),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
//coding here
parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100, F = 3'b101, G = 3'b110;
bg (address, CLOCK_50, 3'b000, 1'b0, color_in);	

	reg [14:0] address; 
	reg [2:0] color;
	reg [7:0] x;
	reg [6:0] y;
	reg writeEn;
	wire [2:0] color_in;
	wire begin_draw = ~KEY[2];
	initial begin 
	address = 15'b0;
	end
reg [2:0]state, n_state;

always @(*)
	begin
		case(state)
		A://initializing write elements
				if(begin_draw)
				n_state = C;
				else
				n_state = A;
				/*
		B://initializing erase elements
				n_state = E;	*/
		C://write only: increase address by 1
				n_state = D;
		D:	//write only: reading colour
				n_state = E; 
		E:	//x increment
			if(x < (8'd159)) begin
				n_state = C;
				end
			else
				n_state = F;
		F: //y increment
			if(y < (7'd119)) begin
				n_state = C;
			end
			else begin
				n_state = A;
			end
		default: n_state = A;
		endcase
	end	

always@(posedge CLOCK_50) begin
	state <= n_state;

	if(state == A) begin //initializing write
		x <= 8'b0;
		y <= 7'b0;
		writeEn <= 1'b1;
		address <= 15'b0;
	end 
	
	else if (state == C)
		address <= address + 1;
	
	else if (state == D)
		color <= color_in;
		
	else if (state == E)begin
		x <= x + 1'b1;
		if(x == (8'd159))
		writeEn <= 1'b0;
		end
	else if (state == F) begin
		y <= y + 1'b1;
		x <= 8'b0;
		if (y == (7'd119))
			writeEn <= 1'b0;
		else
			writeEn <= 1'b1;
		end
end	
endmodule


