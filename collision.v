//whenever posedge collision, HP - 1

module check_collision( clk, bullet_x, bullet_y, unit_x, unit_y, collision);
	input clk;
	input [7:0]bullet_x, unit_x;
	input [6:0]bullet_y, unit_y;
	output reg collision;
	initial collision = 0;

parameter Check = 3'b000, Coldtime = 3'b001, C = 3'b010, D = 3'b011;

reg [31:0] coldtime;
reg [2:0]state, n_state;

always @(*)
	begin
		case(state)
		Check: begin
			if(((bullet_x - unit_x) < 3'd7) & ((bullet_y - unit_y) < 3'd7) )
				n_state = Coldtime;
			else
				n_state = Check;
			end
			
		Coldtime:
		begin
			if(coldtime == 32'd8000000)
				n_state = Check;
			else
				n_state = Coldtime;
		end
		
		default: n_state = Check;
		endcase
	end	

always@(posedge clk) begin
	state <= n_state;

	if(state == Check) begin //initializing write
		collision <= 0;
		coldtime <= 0;
	end 
	
	else begin
		collision <= 1;
		coldtime <= coldtime + 1;
	end
end	

endmodule 