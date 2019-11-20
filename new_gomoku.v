module new_gomoku(CLOCK_50, PS2_CLK, PS2_DAT, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B);
	input CLOCK_50;
	inout PS2_CLK, PS2_DAT;
	input [3:0] KEY;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4;
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B;
	

	wire go;
	wire resetn;
	wire w, a, s, d, enter;
	wire writeEn;
	wire [2:0] vga_colour;
	
    reg [6:0] black [6:0];
    reg [6:0] white [6:0];
    integer j;
    initial begin
        for (j = 0; j<= 6; j = j + 1) begin
            black[j] = 7'b0;
            white[j] = 7'b0;
        end
    end
	
	reg [2:0] in_x = 3'd3;
	reg [2:0] in_y = 3'd3;
    // black go first
	reg in_color = 1'b0;
	reg [7:0] vga_x;
	reg [6:0] vga_y;
	assign resetn = KEY[0];

    // empty board to be drawn each time
    reg [119:0] empty_board [159:0];
    integer xcoord, ycoord;
    initial begin
        for (xcoord = 0; xcoord <= 159; xcoord = xcoord + 1) begin
            for (ycoord = 0; ycoord <= 119; ycoord = ycoord + 1) begin
                if (((xcoord >= 33 && xcoord <= 129) && (ycoord == 13 || ycoord == 13 + 16 || ycoord == 13 + 2 * 16 || ycoord == 13 + 3 * 16 || ycoord == 13 + 4 * 16 || ycoord == 13 + 5 * 16 || ycoord == 13 + 6 * 16)) || ((ycoord <= 129 && ycoord >= 33) && (xcoord == 33 || xcoord == 33 + 16 || xcoord == 33 + 16 * 2 || xcoord == 33 + 16 * 3 || xcoord == 33 + 16 * 4 || xcoord == 33 + 16 * 5 || xcoord == 33 + 16 * 6)))
                    empty_board[xcoord][ycoord] = 1;
                else
                    empty_board[xcoord][ycoord] = 0;
            end
        end
    end

    vga_adapter VGA(.resetn(resetn), .clock(CLOCK_50),
						 .colour(vga_colour), .x(vga_x), .y(vga_y), .plot(writeEn), 
						 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
    defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "img/board.colour.mif";


    wire writeEn = 1'b1;
    assign vga_colour = empty_board[vga_x][vga_y] == 0 ? 3'b010 : 3'b000;
    always@(posedge CLOCK_50)
    begin
        if (~resetn) begin
            vga_x <= 8'b0;
            vga_y <= 7'b0;
        else begin
            if (vga_x == 159 && vga_y == 119) begin
                vga_x <= 8'b0;
                vga_y <= 7'b0;
            else begin
                vga_x <= vga_x + 1;
                vga_y <= vga_y + 1;
            end
        end
    end



    // keyboard control
	reg left_lock, right_lock, up_lock, down_lock; // simulate pulses
	wire left_key, right_key, up_key, down_key;
	assign left_key = a && ~left_lock;
	assign right_key = d && ~right_lock;
	assign up_key = w && ~up_lock;
	assign down_key = s && ~down_lock;
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