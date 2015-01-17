	
module draw_boss(begin_draw, movement, clk, x, y, color, drawEn, done);	
	input begin_draw, clk;
	input [3:0]movement; //input controlling character's next move
	output reg drawEn; //drawEnable of vga
	output reg done;//done signal for drawing image
	
	//output to vga drawing elements
	output reg [2:0] color;
	output reg [7:0] x;
	output reg [6:0] y;
	
	reg [7:0] x_in;
	reg [6:0] y_in;
	//coding here
	parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011,
				 E = 3'b100, F = 3'b101, G = 3'b110;
				 
	boss b1(address, clk, 3'b000, 1'b0, color_in);	
	
	motion hm(movement[1:0], vertical);
	motion vm(movement[3:2], horizontal);
		
	reg [7:0] address; 
	//reg writeEn;
	wire [2:0] color_in;

	
	initial begin 
	address = 8'b0;
	x_in = 8'd76; //center (unit bitmap has 8 pixel in width)
	y_in = 7'd29; //1/4 to the bottom
	done = 0;
	end
reg [2:0]state, n_state;
wire [2:0]horizontal, vertical; //11 = increment in coordinates, 00 = decrement and stays still otherwise 


	//state table	
	always @(*)
	begin
		case(state)
		A://initializing write elements
				if(begin_draw)
				n_state = C;
				else
				n_state = A;
				
		C://write only: increase address by 1
				n_state = D;
		D:	//write only: reading colour
				n_state = E; 
		E:	//x increment
			if(x < (x_in + 4'd7)) 
				n_state = C;
			else
				n_state = F;
		F: //y increment
			if(y < (y_in + 4'd7))
				n_state = C;

			else 
				n_state = G;

		G://done
			if (!begin_draw)
				n_state = A;
			else 
				n_state = G;
		default: n_state = A;
		endcase
	end	

	
	//datapath
	always@(posedge clk) begin
	state <= n_state;
	
	if(state == A) begin //initializing write
		//done <= 1'b0;
		if(begin_draw) begin
		drawEn <= 1'b1;
		address <= 7'b0;
		
		if(((horizontal == 2'b11) &( x_in < 8'd152)) |((horizontal == 2'b00) & (x_in > 8'd0)))
		begin
		x_in <= x_in - movement[2] + movement[3];
		x <= x_in - movement[2] + movement[3];
		end
		else 
		x <= x_in;
		
		if(((vertical == 2'b11) & (y_in < 7'd112)) |((vertical == 2'b00) & (y_in > 7'd0)))
		begin
		y_in <= y_in - movement[0]  + movement[1];
		y <= y_in - movement[0] + movement[1];
		end
		else 
		y <= y_in;
		end
	end 

	else if (state == C)
		address <= address + 1;
	
	else if (state == D)
		color <= color_in;
		
	else if (state == E)begin
		x <= x + 1'b1;
		if(x == (x_in + 4'd7))
		drawEn <= 1'b0;
		end
	else if (state == F) begin
		y <= y + 1'b1;
		x <= x_in;
		if (y == (y_in + 3'd7)) begin
			drawEn <= 1'b0;
			done <= 1'b1;
		end
		else
			drawEn <= 1'b1;
		end
		
	else
		if (!begin_draw)
		done <= 1'b0;


end

	endmodule
	