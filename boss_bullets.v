module boss_bullets(
	start, 
	clk,
	x_bullet,
	y_bullet,
	x_boss,
	y_boss,
	x_player,
	y_player,
	writeEn,
	collision,
	done);
	
	input start, clk;
	input [7:0]x_player, x_boss;
	input [6:0]y_player, y_boss;


	output reg [7:0]x_bullet;
	output reg [6:0]y_bullet;
	output reg writeEn, done;
	output collision;
	
	bullets_data (address,clk,dataIn,wren,dataOut);
	
	wire [19:0]dataOut;
	reg [19:0]dataIn;
	reg wren;
	reg [6:0]address;
	reg [6:0]write_add;
	
	reg [19:0]temp; 
	reg activation;
	reg [31:0]clockTick;
	
	initial begin
		write_add = 0;
		clockTick = 32'd0;
		activation = 1;
	end
	
	parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011,
				 E = 4'b0100, F = 4'b0101, G = 4'b0110, H = 4'b0111,
				 I = 4'b1000, J = 4'b1001, K = 4'b1010, L = 4'b1011;
				 
	reg [3:0]state, n_state;
	
	
	///////////////////////////////////////////
	always @(*)
	begin
		case(state)
		A: begin // idel state
			//wren = 0;
			if(start) begin
				if(activation)
					n_state = I;
				else
					n_state = D; /////should be D....
			end
			else
				n_state = A;
		end
		I: 
			n_state = B;
			
		B: begin
			n_state = J;
			//wren = 1;
			end
			
		J: begin
			n_state = C;
			//wren = 0;
			end
			
		C: 
			if(address < (write_add + 7))
				n_state = I;
			else
				n_state = D; ///should be D
		D:	//initializing print
				n_state = L;
		//M: n_state = E;	
		E:	begin//check status 
			if(dataOut[4])
				n_state = F;
			else begin
				if(address == 7'd127)
					n_state = H;
				else
					n_state = L;
			end
		end
		F: 
			n_state = K;
		K: begin
			n_state = G;
			//wren = 1;
			end
		G:begin
			//wren = 0;
			if (address == 7'd127)
				n_state = H;
			else 
				n_state = L;
	end
		L:
			n_state = E;
		H:
			if(!start)
				n_state = A;
			else
				n_state = H;

		default: n_state = A;
		endcase
	end	

	
	//datapath
	always@(posedge clk) begin
	state <= n_state;
	
	if(state == A) begin //initializing write
		clockTick <= clockTick + 1;
		if(clockTick == 32'd19000000)
		begin
			activation <= 1'b1;
			clockTick <=32'd0;
		end
		done <= 0;
		if(start) begin
			if(activation) begin 
				address <= write_add;
				wren <= 0;
				end
		end
	end 

	else if (state == I) begin

		wren <= 0; 

	end
	
	else if (state == B) begin
		dataIn[4] <= 1'b1;
		dataIn[12:5] <= x_boss;
		dataIn[19:13] <= y_boss;
		dataIn[3:0] <= dataOut[3:0];
		wren <= 1; //should be one
	end
	
	else if (state == J) 
		wren <= 0;
	else if (state == L) 
		done <= 0;

	else if (state == C) begin
		if(address < (write_add + 7)) begin
			address <= address + 1;
			wren <= 0;
			end
		else begin
			write_add <= address + 1;
			activation <= 0;
		end
	end
	
	else if (state == D) begin
		wren <= 0;
		address <= 0;
	end
	
	else if (state == E)begin
		if(dataOut[4]) begin
			x_bullet <= dataOut[12:5];
			y_bullet <= dataOut[19:13];
			writeEn <= 1;
		end
		else begin
			writeEn <= 0;
			address <= address + 1;
		end
	end
		
	else if (state == F) begin
		writeEn <= 0;
		wren <= 1;

		dataIn[12:5] <= dataOut[12:5] + dataOut[3] - dataOut[2];
		dataIn[19:13] <= dataOut[19:13] + dataOut[1] - dataOut[0];
		dataIn[3:0] <= dataOut[3:0];
			if (dataOut[4]) begin
		if ((dataOut[12:5] < 0) | (dataOut[12:5] > 8'd159) | (dataOut[19:13] < 0 )| (dataOut[19:13] > 7'd119))
			dataIn[4] <= 0;
		else
			dataIn[4] <= 1;
		end
		else dataIn[4] <= 0;
	
	end
	
	else if (state == K) begin
		writeEn <= 0;
		wren <= 0;
	end
		
	else if (state == G) begin 
		wren <= 0;
		address <= address + 1;
	end
	
	else begin
		if(!start) begin
			done <= 0;
			address<= 8'd120;
		end
		else
			done <= 1;
	end
end

	check_collision(clk, x_bullet, y_bullet, x_player, y_player, collision);
	endmodule 