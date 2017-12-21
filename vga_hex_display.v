module vga_hex_display(clk, enable, resetn, num, x, y, colour, writeEn);
	input clk;
	input enable;
	input resetn;
	input [31:0] num;
	output reg [7:0] x;
	output reg [6:0] y;
	output reg [2:0] colour;
	output reg writeEn;
	
	localparam width = 20;// Width of image file
	localparam height = 30;// Height of image file
	localparam num_length = 32;// Length of the input
	localparam num_width = 4;// Number of bits per number, 4 for hexadecimal
	
	reg [7:0] x_start;
	reg [7:0] y_start;
	reg [9:0] curr_pixel;
	reg [3:0] curr_num;
	reg [6:0] curr_index;
	
	reg [3:0] image [0 : width*height*16]; // Registers to store pixel data for images
	
	always @(posedge clk) begin
		if (~resetn) begin
			x_start <= 0;
			y_start <= 0;
			curr_pixel <= 0;
			curr_index <= 0;
			x <= 0;
			y <= 0;
			writeEn <= 0;
			// Load the pixel data into the registers
			$readmemh ("images/0.list", image, 0, width*height-1);
			$readmemh ("images/1.list", image, width*height, (width*height*2)-1);
			$readmemh ("images/2.list", image, width*height*2, (width*height*3)-1);
			$readmemh ("images/3.list", image, width*height*3, (width*height*4)-1);
			$readmemh ("images/4.list", image, width*height*4, (width*height*5)-1);
			$readmemh ("images/5.list", image, width*height*5, (width*height*6)-1);
			$readmemh ("images/6.list", image, width*height*6, (width*height*7)-1);
			$readmemh ("images/7.list", image, width*height*7, (width*height*8)-1);
			$readmemh ("images/8.list", image, width*height*8, (width*height*9)-1);
			$readmemh ("images/9.list", image, width*height*9, (width*height*10)-1);
			$readmemh ("images/A.list", image, width*height*10, (width*height*11)-1);
			$readmemh ("images/B.list", image, width*height*11, (width*height*12)-1);
			$readmemh ("images/C.list", image, width*height*12, (width*height*13)-1);
			$readmemh ("images/D.list", image, width*height*13, (width*height*14)-1);
			$readmemh ("images/E.list", image, width*height*14, (width*height*15)-1);
			$readmemh ("images/F.list", image, width*height*15, (width*height*16)-1);
		end
		else if (enable) begin
			writeEn <= 1;
			if (x < x_start+width-1'b1) begin // Process the current number
				x <= x + 1'b1;
				curr_pixel <= curr_pixel + 1'b1;
			end
			else if (y < y_start+height-1'b1) begin
				x <= x_start;
				y <= y + 1'b1;
				curr_pixel <= curr_pixel + 1'b1;
			end
			else if (curr_index < (num_length-num_width)) begin // Process the next number if there is one
				x <= x_start + width;
				y <= y_start;
				x_start <= x_start + width;
				curr_pixel <= 1'b0;
				curr_index <= curr_index + num_width;
			end
			else begin// If all numbers have been displayed fully, reset everything
				curr_pixel <= 1'b0;
				curr_index <= 1'b0;
				x_start <= 1'b0;
				x <= 1'b0;
				y <= 1'b0;
			end
		end
	end
		
	always @(*)
		begin // Needs to be modified if num_width != 4
			curr_num[3] = num[(num_length-curr_index)-1];//Loads the current number as a cut of the input number
			curr_num[2] = num[(num_length-curr_index)-2];
			curr_num[1] = num[(num_length-curr_index)-3];
			curr_num[0] = num[(num_length-curr_index)-4];
			// The colour to display, reads pixel data using the current number as an offset
			colour = image[curr_pixel+(curr_num*width*height)];
			// colour = image[curr_pixel];
		end
endmodule
