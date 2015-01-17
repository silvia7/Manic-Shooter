module motion (leftright, horizontal);

	input [1:0]leftright; //1 is inc. and 0 is dec.
	output reg[1:0]horizontal;
	
	always@(*)begin
	case(leftright)
	2'b10:
		horizontal = 2'b11; //increment
	2'b01:
		horizontal = 2'b00; //decrement in coordinate
	default:
		horizontal = 2'b01; //still
	endcase
	end
endmodule
		