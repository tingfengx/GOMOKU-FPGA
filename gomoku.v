module gomoku(CLOCK_50, 
	PS2_CLK, PS2_DAT, KEY, LEDR, 
	HEX0, HEX1, HEX2, HEX3, HEX4, 
	HEX5, VGA_CLK, VGA_HS, VGA_VS, 
	VGA_BLANK_N, VGA_SYNC_N, VGA_R,
	VGA_G, VGA_B);
	
	 input CLOCK_50;
	 inout PS2_CLK, PS2_DAT;
	 input [3:0] KEY;
	 output [9:0] LEDR;
	 output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	 output [9:0] VGA_R, VGA_G, VGA_B;
	 reg [7:0] step;
	 wire white_win;
	 wire black_win;
	 wire has_win;
	 assign has_win = white_win || black_win; // 1 means has winner, // 0 means no winner yet.
	 wire go;
	 wire resetn;
	 reg has_begin;
	 wire w, a, s, d, enter, space;
	 reg writeEn;
	 reg [2:0] vga_colour;
	
    reg [6:0] black [6:0];
    reg [6:0] white [6:0];
    integer j;
    initial begin
        for (j = 0; j<= 6; j = j + 1) begin
            black[j] <= 7'b0;
            white[j] <= 7'b0;
        end
		  step <= 7'b0;
		  has_begin <= 0;
		  writeEn <= 0;
    end
	
	 reg [2:0] in_x = 3'd3;
	 reg [2:0] in_y = 3'd3;
    // black go first
	 reg in_color = 1'b0;
	 reg [7:0] vga_x;
	 reg [6:0] vga_y;
	 assign resetn = KEY[0];
	
	 // winner of the game text
	 reg [119:0] winner_txt [159:0];	 
	 
    // empty board to be drawn each time
    reg [119:0] empty_board [159:0];
	 
	 // masking positions, each position should have one dot to represent input,
	 // valid positions are (16 x + 33, 13 + 16 y)
	 reg [119:0] black_mask [159:0];
	 reg [119:0] white_mask [159:0];
	 
	 // canvas, corresponding to what we have above, should have complete squares
	 // at respective positions. 
	 reg [119:0] black_canvas [159:0];
	 reg [119:0] white_canvas [159:0];
    integer xcoord, ycoord;
    initial begin
        for (xcoord = 0; xcoord <= 159; xcoord = xcoord + 1) begin
            for (ycoord = 0; ycoord <= 119; ycoord = ycoord + 1) begin
                if ((xcoord >= 33 && xcoord <= 129) && (ycoord == 13 || ycoord == 29 || ycoord == 45 || ycoord == 61 || ycoord == 77 || ycoord == 93 || ycoord == 109))
                    empty_board[xcoord][ycoord] <= 1;
					 else if ((ycoord <= 109 && ycoord >= 13) && (xcoord == 33 || xcoord == 49 || xcoord == 65 || xcoord == 81 || xcoord == 97 || xcoord == 113 || xcoord == 129))
						  empty_board[xcoord][ycoord] <= 1;
					 else begin
							empty_board[xcoord][ycoord] <= 0;
					 end
					 black_mask[xcoord][ycoord] <= 0;
					 white_mask[xcoord][ycoord] <= 0;
					 black_canvas[xcoord][ycoord] <= 0;
					 white_canvas[xcoord][ycoord] <= 0;
					 if (xcoord >= 2 && xcoord <= 8 && ycoord >= 3 && ycoord <= 9)
						  winner_txt[xcoord][ycoord] <= 1;
					 else
						  winner_txt[xcoord][ycoord] <= 0;
            end
        end
    end
	 
	 
	 keyboard_tracker #(.PULSE_OR_HOLD(0)) keyboard(.clock(CLOCK_50), .reset(resetn),
																  .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT),
																  .w(w), .a(a), .s(s), .d(d), .enter(enter), 
																  .space(space));


    vga_adapter VGA(.resetn(resetn), .clock(CLOCK_50),
						 .colour(vga_colour), .x(vga_x), .y(vga_y), .plot(writeEn), 
						 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
    defparam VGA.RESOLUTION = "160x120";
	 defparam VGA.MONOCHROME = "FALSE";
	 defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	 defparam VGA.BACKGROUND_IMAGE = "img/image.colour.mif";
    always@(negedge space)
	 begin
		  if (~has_begin)
		      has_begin <= 1'b1;
	 end
	 
    always@(posedge CLOCK_50)
	 begin
		  if (has_begin) begin
		      writeEn <= 0;
				if (~resetn) begin
					vga_x <= 8'b0;
					vga_y <= 7'b0;
				end
				else begin
					writeEn <= 1;
					if (vga_x != 159 || vga_y != 119) begin
						if (vga_x == 159) begin
							vga_x <= 8'b0;
							vga_y <= vga_y + 1;
						end
						else begin
							vga_x <= vga_x + 1;
						end
					end
					else begin
						vga_x <= 8'b0;
						vga_y <= 7'b0;
					end
				end
		  end
		  
    end
	
	// go is the signal for placing the token
	// embedded logic for checking if the position has been occupied or not.
	assign go = (enter && ~white[in_x][in_y] && ~black[in_x][in_y] && ~has_win);
		
	integer xc, yc; // x-coord and y-coord
	always@(posedge CLOCK_50)
	begin
		//  ! RECALL DEFINITIONS
		//	 reg [119:0] black_canvas [159:0];
		//  reg [119:0] white_canvas [159:0];
		//  these numbers are set to prevent overflow
		for (xc = 5; xc <= 154; xc = xc + 1) begin
			for (yc = 5; yc <= 114; yc = yc + 1) begin
				if (black_mask[xc-1][yc-1] == 1 || black_mask[xc-1][yc] == 1 || black_mask[xc-1][yc+1] == 1 || black_mask[xc][yc-1] == 1 || black_mask[xc][yc] == 1 || black_mask[xc][yc+1] == 1 || black_mask[xc+1][yc-1] == 1 || black_mask[xc+1][yc] == 1 || black_mask[xc+1][yc+1] == 1)
					black_canvas[xc][yc] <= 1;
				else if (white_mask[xc-1][yc-1] == 1 || white_mask[xc-1][yc] == 1 || white_mask[xc-1][yc+1] == 1 || white_mask[xc][yc-1] == 1 || white_mask[xc][yc] == 1 || white_mask[xc][yc+1] == 1 || white_mask[xc+1][yc-1] == 1 || white_mask[xc+1][yc] == 1 || white_mask[xc+1][yc+1] == 1)
					white_canvas[xc][yc] <= 1;
			end
		end
		if (empty_board[vga_x][vga_y] == 1'b0)
			vga_colour <= 3'b110;
		else
			vga_colour <= 3'b000;
		if (white_canvas[vga_x][vga_y] == 1'b1)
			vga_colour <= 3'b111;
		else if (black_canvas[vga_x][vga_y] == 1'b1)
			vga_colour <= 3'b000;
		if (winner_txt[vga_x][vga_y] == 1'b1 && has_win) begin
			if (white_win)
				vga_colour <= 3'b111;
			if (black_win)
				vga_colour <= 3'b000;
		end
		// red pointer this should be done last
		if (vga_x == 33 + 16 * in_x && vga_y == 13 + 16 * in_y)
			vga_colour <= 3'b100;
	end
	
	always@(negedge go)
	begin
		if (in_color == 1'b1) begin
			white[in_x][in_y] <= 1'b1;
			white_mask[in_x * 16 + 33][in_y * 16 + 13] <= 1'b1;
		end
		else begin
			step <= step + 8'b1;
			black[in_x][in_y] <= 1'b1;
			black_mask[in_x * 16 + 33][in_y * 16 + 13] <= 1'b1;
		end
		in_color <= !in_color;
	end
	
	hex_decoder hex4(step[3:0], HEX4);
	hex_decoder hex5(step[7:4], HEX5);
	
	
   // keyboard control
	reg left_lock, right_lock, up_lock, down_lock; // simulate pulses
	wire left_key, right_key, up_key, down_key;
	assign left_key  = a && ~left_lock;
	assign right_key = d && ~right_lock;
	assign up_key    = w && ~up_lock;
	assign down_key  = s && ~down_lock;
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
			left_lock <= a;
			right_lock <= d;
			up_lock <= w;
			down_lock <= s;
			
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
	
    hex_decoder hex0(in_y, HEX0);
    hex_decoder hex1(in_x, HEX1);
	 // ignore this
	 
	 wire neglect = empty_board[33][13];
	 wire neglect1 = winner_txt[2][2];
	 
	wire [59:0] black_out_res;
	
	// first 21 (0 up to 20) for row wise win
	assign black_out_res[0]  = black[0][0] && black[1][0] && black[2][0] && black[3][0] && black[4][0];
	assign black_out_res[1]  = black[0][1] && black[1][1] && black[2][1] && black[3][1] && black[4][1];
	assign black_out_res[2]  = black[0][2] && black[1][2] && black[2][2] && black[3][2] && black[4][2];
	assign black_out_res[3]  = black[0][3] && black[1][3] && black[2][3] && black[3][3] && black[4][3];
	assign black_out_res[4]  = black[0][4] && black[1][4] && black[2][4] && black[3][4] && black[4][4];
	assign black_out_res[5]  = black[0][5] && black[1][5] && black[2][5] && black[3][5] && black[4][5];
	assign black_out_res[6]  = black[0][6] && black[1][6] && black[2][6] && black[3][6] && black[4][6];
	assign black_out_res[7]  = black[1][0] && black[2][0] && black[3][0] && black[4][0] && black[5][0];
	assign black_out_res[8]  = black[1][1] && black[2][1] && black[3][1] && black[4][1] && black[5][1];
	assign black_out_res[9]  = black[1][2] && black[2][2] && black[3][2] && black[4][2] && black[5][2];
	assign black_out_res[10] = black[1][3] && black[2][3] && black[3][3] && black[4][3] && black[5][3];
	assign black_out_res[11] = black[1][4] && black[2][4] && black[3][4] && black[4][4] && black[5][4];
	assign black_out_res[12] = black[1][5] && black[2][5] && black[3][5] && black[4][5] && black[5][5];
	assign black_out_res[13] = black[1][6] && black[2][6] && black[3][6] && black[4][6] && black[5][6];
	assign black_out_res[14] = black[2][0] && black[3][0] && black[4][0] && black[5][0] && black[6][0];
	assign black_out_res[15] = black[2][1] && black[3][1] && black[4][1] && black[5][1] && black[6][1];
	assign black_out_res[16] = black[2][2] && black[3][2] && black[4][2] && black[5][2] && black[6][2];
	assign black_out_res[17] = black[2][3] && black[3][3] && black[4][3] && black[5][3] && black[6][3];
	assign black_out_res[18] = black[2][4] && black[3][4] && black[4][4] && black[5][4] && black[6][4];
	assign black_out_res[19] = black[2][5] && black[3][5] && black[4][5] && black[5][5] && black[6][5];
	assign black_out_res[20] = black[2][6] && black[3][6] && black[4][6] && black[5][6] && black[6][6];
	
	// second 21 (21 up to 41) for column wise win
	assign black_out_res[21] = black[0][0] && black[0][1] && black[0][2] && black[0][3] && black[0][4];
	assign black_out_res[22] = black[1][0] && black[1][1] && black[1][2] && black[1][3] && black[1][4];
	assign black_out_res[23] = black[2][0] && black[2][1] && black[2][2] && black[2][3] && black[2][4];
	assign black_out_res[24] = black[3][0] && black[3][1] && black[3][2] && black[3][3] && black[3][4];
	assign black_out_res[25] = black[4][0] && black[4][1] && black[4][2] && black[4][3] && black[4][4];
	assign black_out_res[26] = black[5][0] && black[5][1] && black[5][2] && black[5][3] && black[5][4];
	assign black_out_res[27] = black[6][0] && black[6][1] && black[6][2] && black[6][3] && black[6][4];
	assign black_out_res[28] = black[0][1] && black[0][2] && black[0][3] && black[0][4] && black[0][5];
	assign black_out_res[29] = black[1][1] && black[1][2] && black[1][3] && black[1][4] && black[1][5];
	assign black_out_res[30] = black[2][1] && black[2][2] && black[2][3] && black[2][4] && black[2][5];
	assign black_out_res[31] = black[3][1] && black[3][2] && black[3][3] && black[3][4] && black[3][5];
	assign black_out_res[32] = black[4][1] && black[4][2] && black[4][3] && black[4][4] && black[4][5];
	assign black_out_res[33] = black[5][1] && black[5][2] && black[5][3] && black[5][4] && black[5][5];
	assign black_out_res[34] = black[6][1] && black[6][2] && black[6][3] && black[6][4] && black[6][5];
	assign black_out_res[35] = black[0][2] && black[0][3] && black[0][4] && black[0][5] && black[0][6];
	assign black_out_res[36] = black[1][2] && black[1][3] && black[1][4] && black[1][5] && black[1][6];
	assign black_out_res[37] = black[2][2] && black[2][3] && black[2][4] && black[2][5] && black[2][6];
	assign black_out_res[38] = black[3][2] && black[3][3] && black[3][4] && black[3][5] && black[3][6];
	assign black_out_res[39] = black[4][2] && black[4][3] && black[4][4] && black[4][5] && black[4][6];
	assign black_out_res[40] = black[5][2] && black[5][3] && black[5][4] && black[5][5] && black[5][6];
	assign black_out_res[41] = black[6][2] && black[6][3] && black[6][4] && black[6][5] && black[6][6];
	
	// slanted; top toward left and bottom toward right
	// group one, first five col
	assign black_out_res[42] = black[0][0] && black[1][1] && black[2][2] && black[3][3] && black[4][4];
	assign black_out_res[43] = black[0][1] && black[1][2] && black[2][3] && black[3][4] && black[4][5];
	assign black_out_res[44] = black[0][2] && black[1][3] && black[2][4] && black[3][5] && black[4][6];
	// group two, second five col
	assign black_out_res[45] = black[1][0] && black[2][1] && black[3][2] && black[4][3] && black[5][4];
	assign black_out_res[46] = black[1][1] && black[2][2] && black[3][3] && black[4][4] && black[5][5];
	assign black_out_res[47] = black[1][2] && black[2][3] && black[3][4] && black[4][5] && black[5][6];
	// group three, third five col
	assign black_out_res[48] = black[2][0] && black[3][1] && black[4][2] && black[5][3] && black[6][4];
	assign black_out_res[49] = black[2][1] && black[3][2] && black[4][3] && black[5][4] && black[6][5];
	assign black_out_res[50] = black[2][2] && black[3][3] && black[4][4] && black[5][5] && black[6][6];
	
	// slanted; top toward right and bottom toward left
	// group one, first five col
	assign black_out_res[51] = black[0][4] && black[1][3] && black[2][2] && black[3][1] && black[4][0];
	assign black_out_res[52] = black[0][5] && black[1][4] && black[2][3] && black[3][2] && black[4][1];
	assign black_out_res[53] = black[0][6] && black[1][5] && black[2][4] && black[3][3] && black[4][2];
	// group two, second five col
	assign black_out_res[54] = black[1][4] && black[2][3] && black[3][2] && black[4][1] && black[5][0];
	assign black_out_res[55] = black[1][5] && black[2][4] && black[3][3] && black[4][2] && black[5][1];
	assign black_out_res[56] = black[1][6] && black[2][5] && black[3][4] && black[4][3] && black[5][2];
	// group three, third five col
	assign black_out_res[57] = black[2][4] && black[3][3] && black[4][2] && black[5][1] && black[6][0];
	assign black_out_res[58] = black[2][5] && black[3][4] && black[4][3] && black[5][2] && black[6][1];
	assign black_out_res[59] = black[2][6] && black[3][5] && black[4][4] && black[5][3] && black[6][2];

	assign black_win = |black_out_res;
	
	wire [59:0] white_out_res;
	
	// first 21 (0 up to 20) for row wise win
	assign white_out_res[0]  = white[0][0] && white[1][0] && white[2][0] && white[3][0] && white[4][0];
	assign white_out_res[1]  = white[0][1] && white[1][1] && white[2][1] && white[3][1] && white[4][1];
	assign white_out_res[2]  = white[0][2] && white[1][2] && white[2][2] && white[3][2] && white[4][2];
	assign white_out_res[3]  = white[0][3] && white[1][3] && white[2][3] && white[3][3] && white[4][3];
	assign white_out_res[4]  = white[0][4] && white[1][4] && white[2][4] && white[3][4] && white[4][4];
	assign white_out_res[5]  = white[0][5] && white[1][5] && white[2][5] && white[3][5] && white[4][5];
	assign white_out_res[6]  = white[0][6] && white[1][6] && white[2][6] && white[3][6] && white[4][6];
	assign white_out_res[7]  = white[1][0] && white[2][0] && white[3][0] && white[4][0] && white[5][0];
	assign white_out_res[8]  = white[1][1] && white[2][1] && white[3][1] && white[4][1] && white[5][1];
	assign white_out_res[9]  = white[1][2] && white[2][2] && white[3][2] && white[4][2] && white[5][2];
	assign white_out_res[10] = white[1][3] && white[2][3] && white[3][3] && white[4][3] && white[5][3];
	assign white_out_res[11] = white[1][4] && white[2][4] && white[3][4] && white[4][4] && white[5][4];
	assign white_out_res[12] = white[1][5] && white[2][5] && white[3][5] && white[4][5] && white[5][5];
	assign white_out_res[13] = white[1][6] && white[2][6] && white[3][6] && white[4][6] && white[5][6];
	assign white_out_res[14] = white[2][0] && white[3][0] && white[4][0] && white[5][0] && white[6][0];
	assign white_out_res[15] = white[2][1] && white[3][1] && white[4][1] && white[5][1] && white[6][1];
	assign white_out_res[16] = white[2][2] && white[3][2] && white[4][2] && white[5][2] && white[6][2];
	assign white_out_res[17] = white[2][3] && white[3][3] && white[4][3] && white[5][3] && white[6][3];
	assign white_out_res[18] = white[2][4] && white[3][4] && white[4][4] && white[5][4] && white[6][4];
	assign white_out_res[19] = white[2][5] && white[3][5] && white[4][5] && white[5][5] && white[6][5];
	assign white_out_res[20] = white[2][6] && white[3][6] && white[4][6] && white[5][6] && white[6][6];
	
	// second 21 (21 up to 41) for column wise win
	assign white_out_res[21] = white[0][0] && white[0][1] && white[0][2] && white[0][3] && white[0][4];
	assign white_out_res[22] = white[1][0] && white[1][1] && white[1][2] && white[1][3] && white[1][4];
	assign white_out_res[23] = white[2][0] && white[2][1] && white[2][2] && white[2][3] && white[2][4];
	assign white_out_res[24] = white[3][0] && white[3][1] && white[3][2] && white[3][3] && white[3][4];
	assign white_out_res[25] = white[4][0] && white[4][1] && white[4][2] && white[4][3] && white[4][4];
	assign white_out_res[26] = white[5][0] && white[5][1] && white[5][2] && white[5][3] && white[5][4];
	assign white_out_res[27] = white[6][0] && white[6][1] && white[6][2] && white[6][3] && white[6][4];
	assign white_out_res[28] = white[0][1] && white[0][2] && white[0][3] && white[0][4] && white[0][5];
	assign white_out_res[29] = white[1][1] && white[1][2] && white[1][3] && white[1][4] && white[1][5];
	assign white_out_res[30] = white[2][1] && white[2][2] && white[2][3] && white[2][4] && white[2][5];
	assign white_out_res[31] = white[3][1] && white[3][2] && white[3][3] && white[3][4] && white[3][5];
	assign white_out_res[32] = white[4][1] && white[4][2] && white[4][3] && white[4][4] && white[4][5];
	assign white_out_res[33] = white[5][1] && white[5][2] && white[5][3] && white[5][4] && white[5][5];
	assign white_out_res[34] = white[6][1] && white[6][2] && white[6][3] && white[6][4] && white[6][5];
	assign white_out_res[35] = white[0][2] && white[0][3] && white[0][4] && white[0][5] && white[0][6];
	assign white_out_res[36] = white[1][2] && white[1][3] && white[1][4] && white[1][5] && white[1][6];
	assign white_out_res[37] = white[2][2] && white[2][3] && white[2][4] && white[2][5] && white[2][6];
	assign white_out_res[38] = white[3][2] && white[3][3] && white[3][4] && white[3][5] && white[3][6];
	assign white_out_res[39] = white[4][2] && white[4][3] && white[4][4] && white[4][5] && white[4][6];
	assign white_out_res[40] = white[5][2] && white[5][3] && white[5][4] && white[5][5] && white[5][6];
	assign white_out_res[41] = white[6][2] && white[6][3] && white[6][4] && white[6][5] && white[6][6];
	
	// slanted; top toward left and bottom toward right
	// group one, first five col
	assign white_out_res[42] = white[0][0] && white[1][1] && white[2][2] && white[3][3] && white[4][4];
	assign white_out_res[43] = white[0][1] && white[1][2] && white[2][3] && white[3][4] && white[4][5];
	assign white_out_res[44] = white[0][2] && white[1][3] && white[2][4] && white[3][5] && white[4][6];
	// group two, second five col
	assign white_out_res[45] = white[1][0] && white[2][1] && white[3][2] && white[4][3] && white[5][4];
	assign white_out_res[46] = white[1][1] && white[2][2] && white[3][3] && white[4][4] && white[5][5];
	assign white_out_res[47] = white[1][2] && white[2][3] && white[3][4] && white[4][5] && white[5][6];
	// group three, third five col
	assign white_out_res[48] = white[2][0] && white[3][1] && white[4][2] && white[5][3] && white[6][4];
	assign white_out_res[49] = white[2][1] && white[3][2] && white[4][3] && white[5][4] && white[6][5];
	assign white_out_res[50] = white[2][2] && white[3][3] && white[4][4] && white[5][5] && white[6][6];
	
	// slanted; top toward right and bottom toward left
	// group one, first five col
	assign white_out_res[51] = white[0][4] && white[1][3] && white[2][2] && white[3][1] && white[4][0];
	assign white_out_res[52] = white[0][5] && white[1][4] && white[2][3] && white[3][2] && white[4][1];
	assign white_out_res[53] = white[0][6] && white[1][5] && white[2][4] && white[3][3] && white[4][2];
	// group two, second five col
	assign white_out_res[54] = white[1][4] && white[2][3] && white[3][2] && white[4][1] && white[5][0];
	assign white_out_res[55] = white[1][5] && white[2][4] && white[3][3] && white[4][2] && white[5][1];
	assign white_out_res[56] = white[1][6] && white[2][5] && white[3][4] && white[4][3] && white[5][2];
	// group three, third five col
	assign white_out_res[57] = white[2][4] && white[3][3] && white[4][2] && white[5][1] && white[6][0];
	assign white_out_res[58] = white[2][5] && white[3][4] && white[4][3] && white[5][2] && white[6][1];
	assign white_out_res[59] = white[2][6] && white[3][5] && white[4][4] && white[5][3] && white[6][2];

	assign white_win = |white_out_res;
	
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