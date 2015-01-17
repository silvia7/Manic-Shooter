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
	