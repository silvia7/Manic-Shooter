module boss_bullets(begin_draw, clk, color, x, y, drawEn, done);

	input begin_draw, clk;
	output reg drawEn; //drawEnable of vga
	output reg done;//done signal for drawing image
	
	//output to vga drawing elements
	output reg [2:0] color;
	output reg [7:0] x;
	output reg [6:0] y;
					 
	reg [7:0]  address;
	initial address = 8'b0;
	wire [7:0]DataOut;
	
	reg RamWrite; //Ram write enable
	reg [7:0]WriteData;//data write to the ram
	reg [7:0]movement;
	//reg [32:0]last_activation;//stores memory address in the ram for the set of bullets that was lastly activated
	bullets b1(address, clk, WriteData, RamWrite, DataOut);
	
parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011,
			 E = 4'b0100, F = 3'b0101, G = 4'b0110, H = 4'b0111,
			 I = 4'b1000, J = 4'b1001, K = 4'b1010, L = 4'b1011,
			 M = 4'b1100, N = 3'b1101, O = 4'b1110, P = 4'b1111;
			 
reg [3:0]state, n_state;

always @(*)
	begin
		case(state)
		A://idel
			if(begin_draw)
				n_state = C;
			else
				n_state = A;
		B://check Active
			if(DataOut[0] == 0)
				n_state = B;
			else
				n_state = C;
		C://Read Movement
			n_state = D;
		D:	//increase address by 1
			n_state = E; 
		E:	//read x
			n_state = F;
		F: //Check X and update if in bound
			if((x + movement[3]) > 8'd159 | (x - movement[2])<8'd0)
				n_state = K;
			else
				n_state = G;
		G://disable write and increase address 
			n_state = H;
		
		H://read y
			n_state = I;
		I://Check Y and update if in bound
			if((y + movement[1]) > 8'd119 | (y - movement[0])< 8'd0)
				n_state = K;
			else
				n_state = J;
		J://disable write and increase address 
			if (address > 8'd223)
				n_state = M;
			else
				n_state = B;
		K://inactivate bullet status
			n_state = M;
		
		L://move to next set of bullet
			n_state = B;
		
		M://done
			if(!begin_draw)
				n_state = A;
			else
				n_state = M;
				
		default: n_state = A;
		endcase
	end	

	reg [7:0]active;
	always@(posedge clk) begin
	state <= n_state;

	if(state == A) begin //idel
		done <= 1'b0;
		if(begin_draw) 
		RamWrite <= 1'b0;
	end 
	
	else if (state == B)begin
		drawEn <=1'b0;
		if(DataOut[0] == 0)
			address <= address + 4;
		else
			address <= address + 1;
	end
	
	else if (state == C)
		movement <= DataOut;
	
	else if (state == D)
		address <= address + 1;
	
	else if (state == E) 
		x <= DataOut;
	
	else if (state == F) begin
		x <= x + movement[3] - movement[2];
		if((x + movement[3]) > 8'd159 | (x - movement[2])<8'd0)
			address <= address - 2;
		else
			RamWrite <= 1'b1;
			WriteData <= x + movement[3] - movement[2];
	end

	else if (state == G) begin
		RamWrite <= 1'b0;
		address <= address + 1;
		end
		
	else if (state == H) 
		y <= DataOut;
		
		
	else if (state == I) begin
		y <= y + movement[1] - movement[0];
		if((y + movement[1]) > 8'd119 | (y - movement[0])< 8'd0)
			address <= address - 3;
		else begin
			RamWrite <= 1'b1;
			WriteData <= y + movement[1] - movement[0];
		end
	end
	
	else if (state == J) begin
		RamWrite <= 1'b0;
		drawEn <= 1'b1;
	end
	
	else if (state == K) begin
		RamWrite <= 1'b1;
		WriteData <= 0;
	end
	
	else if (state == L)  
		address <= address + 4;
	
	else begin //done
		drawEn <= 1'b0;
		done <= 1'b1;
	end 

end	
endmodule 