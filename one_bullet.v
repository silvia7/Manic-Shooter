module one_bullets(clk, start, direction, shoot, x, y, color, wren, done, player_x, player_y);

input [7:0] player_x;
input [6:0] player_y;
input shoot, clk, start;
input [3:0]direction;
output reg [7:0]x;
output reg [6:0]y;
output reg [2:0]color;
output reg done, wren;
//output reg [17:0]LEDR;

reg bullet_status;
reg [3:0] movement;
initial bullet_status = 0;



reg [2:0]state, n_state;
parameter Idel = 3'b000, set = 3'b001, print = 3'b010, update = 3'b011,
				 disable_print = 3'b100, F = 3'b101, G = 3'b110, Done = 3'b111;
	
always @(*)
	begin
		case(state)
		Idel: begin
			if(start) begin
				if(!bullet_status & shoot)
					n_state = set;
				else if (!bullet_status  & !shoot)
					n_state = Done;
				else
					n_state = print;
			end
			else
				n_state = Idel;
			end
		set:
				n_state = print;
		print:
				n_state = update;
		//disable_print:
				//n_state = update;
		update:
				n_state = Done;
		Done:	
			if(!start)
				n_state = Idel;
			else
				n_state = Done;
		default: n_state = Idel;
		endcase
	end
	
always@(posedge clk) begin
	state <= n_state;
	
	if(state == Idel) begin //initializing write
		done <= 0;
		//LEDR[17] <= bullet_status;
		if(start & bullet_status) 
			wren <= 1;
	end 

	else if (state == set) begin
		x <= player_x + 4;
		y <= player_y - 8;
		color <= 3'b111;
		bullet_status <= 1;
		movement <= direction;
		//LEDR[3:0] <= direction;
	end
	
	else if (state == print) begin
		wren <= 0;
		end
		
	else if (state == update)begin
		x <= x + movement[3] - movement [2];
		y <= y + movement[1] - movement [0];
	end

	else begin

		done <= 1;
		if (bullet_status&((x < 0) | (x > 8'd159) | (y < 0 )| (y > 7'd119)))
			bullet_status <= 0;
	
	end
	
end	


endmodule 