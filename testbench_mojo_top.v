`timescale 10ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:54:18 03/09/2016
// Design Name:   mojo_top
// Module Name:   C:/Users/matt/Documents/projects/mojo/i2c-eeprom/testbench_mojo_top.v
// Project Name:  Mojo-Base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mojo_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testbench_mojo_top;

	// Inputs
	reg clk;
	reg rst_n;
	reg cclk;
	reg spi_ss;
	reg spi_mosi;
	reg spi_sck;
	reg avr_tx;
	reg avr_rx_busy;

	// Outputs
	wire [7:0] led;
	wire spi_miso;
	wire [3:0] spi_channel;
	wire avr_rx;
	wire i2c_scl;
	wire i2c_clk_in;

	// Bidirs
	wire i2c_sda;

	// Instantiate the Unit Under Test (UUT)
	mojo_top uut (
		.clk(clk), 
		.rst_n(rst_n), 
		.cclk(cclk), 
		.led(led), 
		.spi_miso(spi_miso), 
		.spi_ss(spi_ss), 
		.spi_mosi(spi_mosi), 
		.spi_sck(spi_sck), 
		.spi_channel(spi_channel), 
		.avr_tx(avr_tx), 
		.avr_rx(avr_rx), 
		.avr_rx_busy(avr_rx_busy), 
		.i2c_scl(i2c_scl), 
		.i2c_sda(i2c_sda), 
		.i2c_clk_in(i2c_clk_in)
	);


	wire A0 = 0;
wire A1 = 0;
wire A2 = 0;
wire WP = 0;
wire reset = ~rst_n;

M24FC512 eeprom (
	.A0(A0),
	.A1(A1),
	.A2(A2),
	.WP(WP),
	.SDA(i2c_sda),
	.SCL(i2c_scl),
	.RESET(reset)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		forever begin 
			clk = #1 ~clk;
		end
	end

	initial begin
		// Initialize Inputs
		rst_n = 0;
		cclk = 0;
		spi_ss = 0;
		spi_mosi = 0;
		spi_sck = 0;
		avr_tx = 0;
		avr_rx_busy = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		cclk = 1;
		rst_n = 1;

	end
      
endmodule

