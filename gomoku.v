module gomoku(CLOCK_50, PS2_CLK, PS2_DAT, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B);
	input CLOCK_50;
	inout PS2_CLK, PS2_DAT;
	input [3:0] KEY;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B;
	
	wire resetn;
	assign resetn = KEY[0];
	
	wire w, a, s, d, left, right, up, down, space, enter;
	wire game_state, game_win_color;
	
	reg [2:0] in_x = 3'd3, in_y = 3'd3;
	reg in_color = 1'b0;
	
	hex_decoder hex0(.hex_digit(in_y), .segments(HEX0)), // y coord
					hex1(.hex_digit(in_x), .segments(HEX1)), // x coord
					hex2(.hex_digit(in_color), .segments(HEX2)), // input color
					hex3(.hex_digit(game_state), .segments(HEX3)), // game state
					hex4(.hex_digit(game_win_color), .segments(HEX4)); //, // win color
//					hex5(.hex_digit(board[7*in_x + in_y]), .segments(HEX5)); // stone at game logic board coordinate
	
	// keyboard stuff
	reg left_lock, right_lock, up_lock, down_lock; // lock so it doesnt activate every clock tick
	wire left_key, right_key, up_key, down_key;
	assign left_key = left && ~left_lock;
	assign right_key = right && ~right_lock;
	assign up_key = up && ~up_lock;
	assign down_key = down && ~down_lock;
	
	always@(posedge CLOCK_50)
	begin
		if (~resetn)
		begin
			left_lock <= 1'b0;
			right_lock <= 1'b0;
			up_lock <= 1'b0;
			down_lock <= 1'b0;
			in_x <= 3'd3;
			in_y <= 3'd3;
		end
		else begin
			left_lock <= left;
			right_lock <= right;
			up_lock <= up;
			down_lock <= down;
			
			if (left_key)
				in_x <= in_x == 3'd0 ? 3'd0 : in_x - 3'd1;
			if (right_key)
				in_x <= in_x == 3'd6 ? 3'd6 : in_x + 3'd1;
			if (up_key)
				in_y <= in_y == 3'd0 ? 3'd0 : in_y - 3'd1;
			if (down_key)
				in_y <= in_y == 3'd6 ? 3'd6 : in_y + 3'd1;
		end
	end
	
//	reg display_board [7*7-1:0];
//	integer j;
//	initial begin
//		for (j = 0; j < 7*7; j = j + 1)
//			display_board[j] <= 1'b0;
//	end
//	
//	wire [7*7*2-1:0] board_flat;
//	wire [1:0] board [7*7-1:0];
//	genvar i;
//	generate for (i = 0; i < 7*7; i = i + 1) begin:unflatten
//		assign board[i] = board_flat[2*i+1:2*i];
//	end endgenerate
	
	wire [2:0] vga_colour;
	reg [7:0] vga_x;
	reg [6:0] vga_y;
	wire writeEn;
	
	
	keyboard_tracker #(.PULSE_OR_HOLD(0)) keyboard(.clock(CLOCK_50), .reset(resetn),
																  .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT),
																  .w(w), .a(a), .s(s), .d(d),
																  .left(left), .right(right), .up(up), .down(down),
																  .space(space), .enter(enter));
																  
	vga_adapter VGA(.resetn(resetn), .clock(CLOCK_50),
						 .colour(vga_colour), .x(vga_x), .y(vga_y), .plot(writeEn), 
						 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "img/board.colour.mif";
//	
//	wire load_x, load_y, load_colour;
//	wire go;
	
endmodule


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule

