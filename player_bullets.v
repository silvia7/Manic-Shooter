module player_bullets(clk, activate, address, player_x, player_y, direction, DataIn, writeEn, done, coldtime); 
	input clk, activate;
	input [7:0]player_x;
	input [6:0]player_y;
	input [3:0]direction;
	
	output reg [7:0]address;
	output reg writeEn, done;
	output reg coldtime;//if coldtime = 1, bullets will not be activated
	output reg [7:0]DataIn;
	reg [31:0]hold;
	
	reg status;
	initial address = 8'd192;
	
	reg [2:0]state, n_state;
	parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011,
				 E = 3'b100, F = 3'b101, G = 3'b110, H = 3'b111;
	
always @(*)
	begin
		case(state)
		A:
			if(activate)
				n_state = B;
			else
				n_state = A;
		B:
				n_state = C;
		C:
				n_state = D;
		D:	
				n_state = E; 
		E:
				n_state = F;
		F: 
				n_state = G;
		G:
				n_state = H;
		H: if(hold < 32'd50000000)
				n_state = H;
			else 
				n_state = A;
				
		default: n_state = A;
		endcase
	end
	
always@(posedge clk) begin
	state <= n_state;
	
	if(state == A) begin //initializing write
		coldtime <= 0;
		if(activate) begin
			writeEn <= 1;
			DataIn <= 8'b0000_0001;
			hold <= 0;
		end
		else 
		   writeEn <= 0;
	end 

	else if (state == B) begin
		address <= address + 1;
	end
	
	else if (state == C)
		DataIn <= direction;
		
	else if (state == D)begin
		address <= address + 1;
	end
		
	else if (state == E) begin
		DataIn <= player_x;
	end

	else if (state == F) begin
		address <= address + 1;
	end
	else if (state == G) begin
		DataIn <= player_y;
	end
	
	else begin
		if(hold == 0) begin
			coldtime <= 1;
			done <= 1;
			hold <= hold + 1;
			
			if (address != 8'd255)
				address <= address + 1;
			else
				address <= 8'd192;
		end
		else begin
			hold <= hold + 1;
			done <= 0;
		end
	
	end
	
end	

endmodule
