module t_ff(out,t,clk);
    output reg out;
    input t,clk;

    initial out=1'b1;
    always @ (posedge clk)
    begin
		if (t==1'b0)
			out=out;
      else
			out=~out; 
    end
endmodule
 
module t_ff1(out,t,clk);
    output reg out;
    input t,clk;

    initial out=1'b0;
    always @ (posedge clk)
    begin
		if (t==1'b0)
			out=out;
      else
			out=~out; 
    end
endmodule
 

module random(o,clk);
    output [3:0]o;
	 input clk;
    xor (t0,o[3],o[2]);
    assign t1=o[0];
    assign t2=o[1];
    assign t3=o[2];
    t_ff u1(o[0],t0,clk);
    t_ff1 u2(o[1],t1,clk);
    t_ff u3(o[2],t2,clk);
    t_ff1 u4(o[3],t3,clk);
endmodule