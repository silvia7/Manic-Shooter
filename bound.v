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
	

module player_direction(movement, direction);

parameter right = 4'b1000, left = 4'b0100, down = 4'b0010, up = 4'b0001,
			 up_right = 4'b1001, up_left = 4'b0101, down_right = 4'b1010,
			 down_left = 4'b0110;
		
input [3:0]movement;
output reg [3:0]direction;

initial direction = up;

always@(*) begin

case(movement)
right: direction = movement;

left: direction = movement;

down: direction = movement;

up: direction = movement;

up_right: direction = movement;

up_left: direction = movement;

down_right: direction = movement;

down_left: direction = movement;

default: direction = up;
endcase
end
endmodule
