
module proj
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							//	Push Button[3:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		SW
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;						//	Button[3:0]
	input [3:0] SW; 						// 0(down), 1(up), 2(left), 3(right)
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the color, x, y and writeEn wires that are inputs to the controller.

	reg [7:0] address; 
	reg [2:0] color;
	reg [7:0] x_in;
	reg [6:0] y_in;
	reg [7:0] x;
	reg [6:0] y;
	reg writeEn;
	wire [2:0] color_in;
	
	initial begin 
	address = 8'b0;
	
	//initial position of unit
	x_in = 8'd76; //center (unit bitmap has 8 pixel in width)
	y_in = 7'd90; //1/4 to the bottom
	
	end
	

	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(color),
			.x(x),
			.y(y),
			.plot(writeEn),
			
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK)
			);
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "display.mif";
			
	// Put your code here. Your code should produce signals x,y,color and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100, F = 3'b101, G = 3'b110;
	reg [2:0]state, n_state;
	reg erase;
	
	wire [2:0]horizontal, vertical; //11 = increment in coordinates, 00 = decrement and stays still otherwise 
	
	player (address, CLOCK_50, 3'b000, 1'b0, color_in); //only reads from memory
	
	motion hm(SW[1:0], vertical);
	motion vm(SW[3:2], horizontal);
		
	//state table	
	always @(*)
	begin
		case(state)
		A://initializing write elements
				n_state = C;
		B://initializing erase elements
				n_state = E;	
		C://write only: increase address by 1
				n_state = D;
		D:	//write only: reading colour
				n_state = E; 
		E:	//x increment
			if(x < (x_in + 4'd7)) begin
				if (erase)
				n_state = E;
				else
				n_state = C;
				end
			else
				n_state = F;
		F: //y increment
			if(y < (y_in + 4'd7)) begin
				if (erase)
				n_state = E;
				else
				n_state = C;
			end
			else begin
				n_state = G;
			end
		G://still state, allowing the image to show2000000
			if((!erase && hold < 28'd933333) ||(erase && hold< 28'd1) )
			n_state = G;
			else
			begin 
				if (erase)
				n_state = A;
				else
				n_state = B;
			end
			
		default: n_state = A;
		endcase
	end

	reg [28:0]hold;
	initial hold = 28'b0;
	

	//datapath
	always@(posedge CLOCK_50) begin
	state <= n_state;
	
	if(state == A) begin //initializing write
		hold <= 28'b0;
		writeEn <= 1'b1;
		erase <= 1'b0;
		address <= 7'b0;
		
		if(((horizontal == 2'b11) &( x_in < 8'd152)) |((horizontal == 2'b00) & (x_in > 8'd0)))
		begin
		x_in <= x_in - SW[2] + SW[3];
		x <= x_in - SW[2] + SW[3];
		end
		else 
		x <= x_in;
		
		if(((vertical == 2'b11) & (y_in < 7'd112)) |((vertical == 2'b00) & (y_in > 7'd0)))
		begin
		y_in <= y_in - SW[0]  + SW[1];
		y <= y_in - SW[0] + SW[1];
		end
		else 
		y <= y_in;
	end 
	
	
	else if (state == B)begin //initializing erase
		hold <= 28'b0;
		x <= x_in;
		y <= y_in;
		erase <= 1'b1;
		color <= 3'b000;
		writeEn <= 1'b1;
		end

	else if (state == C)
		address <= address + 1;
	
	else if (state == D)
		color <= color_in;
		
	else if (state == E)begin
		x <= x + 1'b1;
		if(x == (x_in + 4'd7))
		writeEn <= 1'b0;
		end
	else if (state == F) begin
		y <= y + 1'b1;
		x <= x_in;
		if (y == (y_in + 3'd7))
			writeEn <= 1'b0;
		else
			writeEn <= 1'b1;
		end
	else if (state == G) begin
		hold <= hold + 1;
	end
end
	

endmodule
