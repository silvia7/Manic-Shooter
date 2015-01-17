module PS2_Keyboard (clock, key_data, key_pressed, movement);
	input clock;
	input key_pressed;
	input [7:0]key_data;
	output reg [3:0]movement;
	
	always@(posedge clock)
	if(key_pressed)begin
		if(key_data == 8'hE075)	//up
			movement <= 4'b0001;
		else if(key_data == 8'hE072)	//down
			movement <= 4'b0010;
		else if(key_data == 8'hE06B)	//left
			movement <= 4'b0100;
		else if(key_data == 8'hE074)	//right
			movement <= 4'b1000;
		else
			movement <= 4'b0000;
	end
/*	
	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50			(CLOCK_50),
	.reset				(0),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
	);*/
endmodule
