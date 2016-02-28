module clk_divider(
    input wire reset,
    input wire clk_in,
    output reg clk_out
    );

	// ref clock = 50MHz
	//i2c_clk = 100kHz
	//divider = 500
	
	parameter DIVIDER = 500;
	
	reg [9:0] count = 0;
	
	always @(posedge clk_in) begin
	
		if (reset == 1) begin
			clk_out = 0;
			count = 0;
		end	//if reset
		else begin
			if (count == ((DIVIDER/2)-1)) begin
				clk_out = ~clk_out;
				count = 0;
			end
			else begin
				count = count + 1;
			end
		end	// if reset (else)
	end	//always
	
endmodule
