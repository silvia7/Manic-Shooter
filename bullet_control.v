module bullet_control(start, clk, pb_activate, player_x, player_y, direction, boss_x, boss_y, vga_x, vga_y, vga_color, vga_draw, done);
	input start, clk;
	input [7:0]player_x, boss_x;
	input [6:0]player_y, boss_y;
	input [3:0]direction;
	
	output  [7:0]vga_x;
	output  [6:0]vga_y;
	output [2:0]vga_color;
	output vga_draw;
	output reg done;

	
	reg [7:0]address, WriteData;
	reg RamWrite;
	reg [3:0]state, n_state;
	
	input pb_activate; //create a bullet for player
	
	reg drawb_begin, boss_activate;
	wire [7:0]pb_add, bb_add, drawb_add, pb_data, bb_data, drawb_data;
	wire pb_done, pb_coldtime, bb_RamEn, pb_RamEn, drawb_RamEn, drawb_done, bb_done;
	
	bullets b1(address, clk, WriteData, RamWrite, DataOut); //ram for storing bullets info
	
	player_bullets(clk, pb_activate, pb_add, player_x, player_y, direction, pb_data, pb_RamEn, pb_done, pb_coldtime); 
	draw_bullets(DataOut, drawb_begin, drawb_data, clk, vga_color, vga_x, vga_y, vga_draw, drawb_done, drawb_add, drawb_RamEn);

	
	reg [31:0] hold;////////////////
	
	parameter Idel = 4'b0000, Bullets_Player = 4'b0001, Bullets_Boss = 4'b0010, Draw_Bullets = 4'b0011, 
				 Check_Collision = 4'b0111, Done = 4'b1111;	

	always @(*)
	begin
		case(state)
		Idel:
			if(start)
				n_state = Bullets_Player;
			else
				n_state = Idel;
				
		Bullets_Player:
			if(pb_coldtime | !pb_activate)
				n_state = Bullets_Boss;
			else 
				n_state = Bullets_Player;
				
		Bullets_Boss:
			//if(done_bg)
				//n_state = Draw_Player;
			//else 
				n_state = Draw_Bullets; 
				
		Draw_Bullets:	
			if(drawb_done)
				n_state = Idel; 
			else 
				n_state = Draw_Bullets;

		default: n_state = Idel;
		endcase
	end	


always@(posedge clk) begin
	state <= n_state;
	
	if(state == Idel) begin //initializing write
		RamWrite <= 0;
		//if(start)
		//pb_activate <= 1;
	end 
	
	else if (state == Bullets_Player)begin
		if (pb_coldtime & pb_activate)
			boss_activate <= 1;
		else begin
			WriteData <= pb_data;
			address <= pb_add;
			RamWrite <= pb_RamEn;
		end
	end
	
	else if (state == Bullets_Boss)begin
		/*if(!bb_done) begin
			WriteData <= bb_data;
			address <= bb_add;
			RamWrite <= bb_RamEn;
			end
		else*/
			boss_activate <= 0;
			drawb_begin <= 1;
	end

	else if (state == Draw_Bullets)begin
		if(!drawb_done) begin
			RamWrite <= drawb_RamEn;
			address <= drawb_add;
			WriteData <= drawb_data;
		end
		else begin
			drawb_begin <= 0;
		end
	end
	

		/*
	else if (state == Draw_Bullets)begin

		end
	else if (state == Check_Collision)	begin
	
	end
	else if (state == Update_HP) begin

		end
		*/
	else// (state == Hold)
		hold <= hold + 1;


end

endmodule

