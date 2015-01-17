// Background image display

module proj
	(
		CLOCK_50,						//	On Board 50 MHz
		SW,							//	Push Button[0:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,	  						//	VGA Blue[9:0]
		KEY,
		LEDR,
		LEDG,
		PS2_CLK,
		PS2_DAT
		//,color, x, y
	);

	input	CLOCK_50;				//	50 MHz
	input	[4:0] KEY;				//	Button[0:0]
	input	[4:0] SW;				//	Button[0:0]
	output	VGA_CLK;   				//	VGA Clock
	output	VGA_HS;					//	VGA H_SYNC
	output	VGA_VS;					//	VGA V_SYNC
	output	VGA_BLANK;				//	VGA BLANK
	output	VGA_SYNC;				//	VGA SYNC
	output	[9:0] VGA_R;   			//	VGA Red[9:0]
	output	[9:0] VGA_G;	 		//	VGA Green[9:0]
	output	[9:0] VGA_B;   			//	VGA Blue[9:0]
	output [17:0]LEDR;
	output  [7:0] LEDG;
	inout PS2_CLK;
 	inout PS2_DAT;
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(color),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "start_page.mif";
		

	//parameters for vga
	reg [2:0] color;
	reg [7:0] x;
	reg [6:0] y;
	reg writeEn;
	wire resetn;
	assign resetn = KEY[0];
	reg [4:0]boss_HP, player_HP;
	
	//random generator for boss movement
	wire [3:0]boss_move;
	wire random_enable;
	random(boss_move, random_enable);
	rateDivider(28'd25000000, CLOCK_50, random_enable); //make random enable activate every second
	
	
	reg [31:0]hold;
	initial begin
	hold = 31'b0;
	begin_player = 0;
	begin_boss = 0;
	begin_bg = 0;
	boss_HP = 5'd18;
	player_HP = 5'd18;
	end

	assign LEDG[4:0] = player_HP;
	//modules for drawing various elements on screen
	wire [2:0] color_player, color_boss, color_bg, color_bb, color_bullets, b_color_bullets, color_over, color_win;
	wire [7:0] x_player, x_boss, x_bg, x_bb ,x_bullets, b_x_bullets, x_boss_bullet, x_HP, x_pHP, x_over,x_win;
	wire [6:0] y_player, y_boss, y_bg, y_bb, y_bullets, b_y_bullets, y_boss_bullet, y_HP, y_pHP, y_over, y_win;
	reg begin_player, begin_boss, begin_bg, begin_bb , begin_bullets, b_begin_bullets, begin_boss_bullet, begin_HP, begin_pHP, begin_over ,begin_win;
	wire drawEn_player, drawEn_boss, drawEn_bg, drawEn_bb, drawEn_bullets, b_drawEn_bullets, drawEn_boss_bullets, drawEn_HP,drawEn_pHP, drawEn_over, drawEn_win;
	wire done_player, done_boss, done_bg, done_bb, done_bullets, b_done_bullets, done_boss_bullet, done_HP, done_pHP, done_over, done_win;
	wire player_collision, boss_collision;
	wire [3:0]direction;
	
	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50			(CLOCK_50),
	.reset				(~KEY[3]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
	);
	
	wire	[7:0]	ps2_key_data;
	wire	ps2_key_pressed;
	wire [3:0] movement;
	wire shoot_signal;
	assign LEDG[7] = boss_collision;
	PS2_Keyboard(CLOCK_50,movement, shoot_signal,LEDR,ps2_key_data ,ps2_key_pressed);
	check_collision bcol(CLOCK_50, x_bullets, y_bullets, x_boss, y_boss, boss_collision);
	
	draw_player dp(begin_player, movement, CLOCK_50, x_player, y_player, color_player, drawEn_player, done_player);
	draw_boss db(begin_boss, boss_move, CLOCK_50, x_boss, y_boss, color_boss, drawEn_boss, done_boss);
	draw_bg dbg(begin_bg, CLOCK_50, x_bg, y_bg, color_bg, drawEn_bg, done_bg);
	draw_gameover dgo(begin_over, CLOCK_50, x_over, y_over, color_over, drawEn_over, done_over);
	draw_win dw(begin_win, CLOCK_50, x_win, y_win, color_win, drawEn_win, done_win);
	
	//bullets
	one_bullets ob(CLOCK_50, begin_bullets, direction, shoot_signal, x_bullets, y_bullets, color_bullets, drawEn_bullets, done_bullets, x_player, y_player);
	boss_one_bullets bob(CLOCK_50, b_begin_bullets, b_x_bullets, b_y_bullets, b_color_bullets, b_drawEn_bullets, b_done_bullets, x_boss, y_boss);
	boss_bullets bbl(begin_boss_bullet, CLOCK_50, x_boss_bullet, y_boss_bullet, x_boss, y_boss, x_player, y_player, drawEn_boss_bullets, player_collision, done_boss_bullet);
	
	drawHP(CLOCK_50, begin_HP, boss_HP, done_HP, drawEn_HP, x_HP, y_HP);
	p_drawHP(CLOCK_50, begin_pHP, player_HP, done_pHP, drawEn_pHP, x_pHP, y_pHP);
	
	player_direction palyerd(movement, direction);

	parameter Idel = 4'b0000, BackGround = 4'b0001, Draw_Player = 4'b0010, Draw_Boss = 4'b0011, 
				 Draw_Bullets = 4'b0100, Draw_B_Bullet = 4'b0101, Hold = 4'b0110, Update_HP = 4'b0111,
				 Boss_bullets = 4'b1001, Update_pHP = 4'b1010, Begin_Drawing = 4'b1111, Over = 4'b1110,
				 Win = 4'b1011;
				 
				 
	reg [3:0]state, n_state;
	always @(*)
	begin
		case(state)
		Idel:
			if(~KEY[1] | (ps2_key_data == 8'h5A))
				n_state = Begin_Drawing;
			else
				n_state = Idel;
				
		Begin_Drawing:
			n_state = BackGround;
			
		BackGround:
			if(done_bg)
				n_state = Draw_Player;
			else 
				n_state = BackGround; 
				
		Draw_Player:	
			if(done_player)
				n_state = Draw_Boss; 
			else 
				n_state = Draw_Player;
				
		Draw_Boss:	
			if(done_boss)
				n_state = Draw_Bullets; /////need change after
			else  
				n_state = Draw_Boss;
				
		Draw_Bullets: 
			if(done_bullets)
				n_state = Draw_B_Bullet;
			else
				n_state = Draw_Bullets;
				
		Draw_B_Bullet:
			if(b_done_bullets)
				n_state = Boss_bullets;
			else
				n_state = Draw_B_Bullet;	
				
		Boss_bullets:	
			if(done_boss_bullet)
				n_state = Update_HP;
			else
				n_state = Boss_bullets;	

		Update_HP:
			if(done_HP)
				n_state = Update_pHP;
			else
				n_state = Update_HP;
				
				
		Update_pHP:
			if(player_HP == 0)
					n_state = Over;
			else if(boss_HP == 0)
					n_state = Win;
			else begin
				if(done_pHP) 
					n_state = Hold;
				else 
					n_state = Update_pHP;

			end
				
		Hold:
			if(hold < 32'd933333)
				n_state = Hold;
			else
				n_state = Begin_Drawing;
		
		Over:
			if(done_over)
			n_state = Idel;
			else 
			n_state = Over;

		Win:
			if(done_win)
			n_state = Win;
			else 
			n_state = Win;
		
		default: n_state = Idel;
		endcase
	end	


always@(posedge CLOCK_50) begin

		state <= n_state;

	if(state == Idel) begin //initializing write
		resetHP <= 1;
		if(~KEY[1] | (ps2_key_data == 8'h5A)) begin
		begin_bg <= 1;
		end
	end 
	
	else if (state == Begin_Drawing)begin
		resetHP <= 0;
		hold <= 0;
		begin_bg <= 1;
	end
	
	else if (state == BackGround)begin 
		if(!done_bg) begin
			x <= x_bg;
			y <= y_bg;
			color <= color_bg;
			writeEn = drawEn_bg;
		end
		else begin
			begin_bg <= 0;
			begin_player <= 1;
		end
	end

	else if (state == Draw_Player)begin
		if(!done_player) begin
			x <= x_player;
			y <= y_player;
			color <= color_player;
			writeEn = drawEn_player;
		end
		else begin
			begin_player <= 0;
			begin_boss <= 1;
		end
	end
	
	else if (state == Draw_Boss)begin
		if(!done_boss) begin
			x <= x_boss;
			y <= y_boss;
			color <= color_boss;
			writeEn = drawEn_boss;
		end
		else begin
			begin_boss <= 0;
			begin_bullets <= 1;
			//draw bullet activation needed
		end
	end
	
	else if (state == Draw_Bullets)begin
		if(!done_bullets) begin
			x <= x_bullets;
			y <= y_bullets;
			color <= color_bullets;
			writeEn <= drawEn_bullets;
		end
		else begin
			begin_bullets <= 0;
			b_begin_bullets <= 1;
			end
		end
		
	else if (state == Draw_B_Bullet)	begin
		if(!b_done_bullets) begin
			x <= b_x_bullets;
			y <= b_y_bullets;
			color <= b_color_bullets;
			writeEn <= b_drawEn_bullets;
		end
		else begin
			b_begin_bullets <= 0;
			begin_boss_bullet <= 1;
		end
	
	end
	
	else if (state == Boss_bullets)	begin
	if(!done_boss_bullet) begin
		x <= x_boss_bullet;
		y <= y_boss_bullet;
		color <= 3'b011;
		writeEn <= drawEn_boss_bullets;
	end
	else begin
		begin_boss_bullet <= 0;
		begin_HP <= 1;
		end
	end
	
	else if (state == Update_HP) begin
	if(!done_HP) begin
		x <= x_HP;
		y <= y_HP;
		color <= 3'b100;
		writeEn <= drawEn_HP;
	end
	else begin
		begin_pHP <= 1;
		begin_HP <= 0;
		end
	end
	
	else if (state == Update_pHP) begin
		if(player_HP == 0)begin
		begin_over <= 1;
		end
		else if(boss_HP == 0)
		begin_win <= 1;
		
	else if(!done_pHP) begin
		x <= x_pHP;
		y <= y_pHP;
		color <= 3'b100;
		writeEn <= drawEn_pHP;
	end
	else begin
		begin_pHP <= 0;
		//begin_HP <= 0;
		end
	end
	
	else if(state == Over) begin 
		if(!done_over)begin
			x <= x_over;
			y <= y_over;
			color <= color_over;
			writeEn <= drawEn_over;
		end 
		else begin
			begin_over <= 0;
		end
	end

	else if(state == Win) begin 
	if(!done_win)begin
		x <= x_win;
		y <= y_win;
		color <= color_win;
		writeEn <= drawEn_win;
	end 
	else begin
		begin_win <= 0;
	end
end
	
	else begin// (state == Hold)
		hold <= hold + 1;
	end
end
	
reg resetHP;
always @ (posedge player_collision, posedge resetHP) begin
	if(resetHP)
		player_HP <= 5'd18;
	else	begin
		player_HP <= player_HP - 1;
	end	
	
end

always @ (posedge boss_collision) begin
	if(state != Idel)
		boss_HP <= boss_HP - 1;
end
endmodule
