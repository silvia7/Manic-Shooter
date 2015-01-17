module PS2_Keyboard(CLOCK_50,movement, shoot_signal, LEDR, ps2_key_data, ps2_key_pressed);

	output [17:0]LEDR;
	
	assign LEDR[7:0] =ps2_key_data;
	// Inputs
	input	CLOCK_50;
	output reg [3:0]movement;
	output reg shoot_signal;
	
	input [7:0]ps2_key_data;
	input ps2_key_pressed;

	reg a;
	assign LEDR[13] = a;
	
	initial begin
	 movement = 4'b0000;
	 shoot_signal = 0;
	 a = 0;
	 end
	
	
	assign LEDR[17:14] = movement;
	
	parameter A = 3'b000, B = 3'b001;
			 
	reg [2:0]state, n_state;
	
	always @(*)begin
		case(state)
		A:if(ps2_key_data == 8'hF0)
				n_state = B;
			else
				n_state = A;
				
		B: 
			n_state = A;
		default: n_state = A;
		endcase
	end	

	always@(posedge CLOCK_50)begin
	state <= n_state;

	if(state == A) begin 
	if(ps2_key_pressed) begin
			if(ps2_key_data == 8'h1D)	//up
				movement[0] <= 1;
				
			else if(ps2_key_data == 8'h1B)	//down
				movement[1] <= 1;
			
			else if(ps2_key_data == 8'h1C)	//left
				movement[2] <= 1;
				
			else if(ps2_key_data == 8'h23)	//right
				movement[3] <= 1;
			else if(ps2_key_data == 8'h29)	//shoot
				shoot_signal <= 1;
			else if (ps2_key_data == 8'h15)	//stop movement
				movement <= 0;
			else
				movement <= movement;
		end
		
	end
	
	if(state == B)begin
		movement <= 0;
		shoot_signal <= 0;
		a <= 1;
	end
end
	
endmodule

