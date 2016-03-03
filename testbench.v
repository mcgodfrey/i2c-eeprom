`timescale 10ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:28:21 02/28/2016
// Design Name:   i2c_master_v4
// Module Name:   C:/Users/matt/Documents/mojo/i2c_master/test_i2c_master_v4.v
// Project Name:  i2c_master
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: i2c_master_v4
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testbench;

	// Inputs
	reg clk;
	reg reset;
	reg i2c_reset;
	reg [15:0] mem_addr;
	reg [6:0] slave_addr;
	reg [7:0] read_nbytes;
	reg data_ready;

	reg start;


	// Outputs
	wire scl;
	wire ready;
	wire busy;
	wire [7:0] data_out;


	// Bidirs
	wire sda_w;


	wire i2c_clk;
	wire [7:0] i2c_nbytes;
	wire [6:0] i2c_slave_addr;
	wire i2c_rw;
	wire [7:0] i2c_write_data;
	wire [7:0] i2c_read_data;
	wire i2c_tx_data_req;
	wire i2c_rx_data_ready;
	wire i2c_start;
	
	wire byte_ready;



	// Instantiate the Unit Under Test (UUT)
	i2c_master i2c (
		.clk(i2c_clk), 
		.reset(i2c_reset), 
		.start(i2c_start), 
		.nbytes_in(i2c_nbytes), 
		.addr_in(i2c_slave_addr), 
		.rw_in(i2c_rw), 
		.write_data(i2c_write_data), 
		.read_data(i2c_read_data), 
		.tx_data_req(i2c_tx_data_req), 
		.rx_data_ready(i2c_rx_data_ready), 
		.sda_w(sda_w), 
		.scl(scl), 
		.ready(ready), 
		.busy(busy)
	);


	clk_divider #(.DIVIDER(500)) i2c_clk_divider (
		.reset(reset), 
		.clk_in(clk), 
		.clk_out(i2c_clk)
	);
	
	read_eeprom uut (
    .clk(clk), 
    .reset(reset), 
    .slave_addr_w(slave_addr), 
    .mem_addr_w(mem_addr), 
    .read_nbytes_w(read_nbytes), 
    .start(start), 
    .i2c_slave_addr(i2c_slave_addr), 
    .i2c_rw(i2c_rw), 
    .i2c_write_data(i2c_write_data), 
    .i2c_nbytes(i2c_nbytes), 
    .i2c_read_data(i2c_read_data), 
    .i2c_tx_data_req(i2c_tx_data_req), 
    .i2c_rx_data_ready(i2c_rx_data_ready), 
    .i2c_start(i2c_start), 
    .data_out(data_out), 
    .byte_ready(byte_ready)
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
		reset = 1;
		i2c_reset = 1;

		// Wait 100 ns for global reset to finish
		#5000;
		//start up the clocks
		reset = 0;
		#5000;
        
		// Add stimulus here
		i2c_reset = 0;
		slave_addr = 8'haa;
		mem_addr = 16'hF0F0;
		read_nbytes = 2;
		
		#10000;
		
		//set the start bit
		start = 1;
		
		
		#10000
		start = 0;
		#100000;
		
		
		$finish;
		
	end
      
endmodule

