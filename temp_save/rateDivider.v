module rateDivider(triggerPoint, clk, enable);
	input [27:0]triggerPoint;
	input clk;
	reg [27:0]clockTick;
	initial clockTick = 28'd0;
	output reg enable;
	
	always@(posedge clk)begin
		if(clockTick == triggerPoint)
			begin
				enable <= 1'b1;
				clockTick <=28'd0;
			end
		else
			begin
			enable <= 1'b0;
			clockTick <= clockTick+1;
			end
		end	
		
		endmodule
	/*
	wire [27:0]triggerPoint;
	reg [27:0]clockTick;
	assign triggerPoint = 28'd5000;
	initial clockTick = 28'd0;
	reg move_clk;
	
	always@(posedge CLOCK_50)begin
		if(clockTick == triggerPoint)
			begin
				move_clk <= 1'b1;
				clockTick <=28'd0;
			end
		else
			begin
			move_clk <= 1'b0;
			clockTick <= clockTick+1;
			end
		end	*/