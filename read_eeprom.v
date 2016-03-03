/*
read_eeprom.v

High Level module to read data from an i2c eeprom device.

inputs are:
 - eeprom chip i2c slave address [7 bit]
 - memory address to read from [16 bit]
 - number of bytes to read [8 bit]
 - start flag to begin the read operation [1-bit]

outputs are:
 - data_out [8-bits]
 - byte-ready [1-bit]
 
 The new byte is placed in data_out as it is read and the byte-ready
   flag is set
	
There are then a number of lines which communicate with the i1c_master
  module which handles the actual communication with the eeprom chip.

This module handles the sending and receiving of bytes through the i2c module
This includes sending the slave address and memory address, the repeated start
  signal and then reading the requested number of bytes.
  
The i2c_master module handles the lower level sending/receiving bytes with the actual chip.


IDLE
 |
 |					start signal high
 |    			Latch in slave addr, mem addr and nbytes
 V
 START
 |
 |					set i2c control lines (addr, rw, etc) ready for address write
 |					set nbytes=2 (16bit address)
 V
 WRITE_ADDR
 |
 |					For both memory address bytes:
 |						Wait for tx_data_req to go high (i1c requesting data) and then set it to the mem addr
 V
 READ_ADDR 
 |
 |					Send repeat start
 |					While nbytes>0, wait for rx_data_ready, set data_out and byte ready
 V
 IDLE
 
*/


module read_eeprom(
	//inputs
	input wire clk,
	input wire reset,
	input wire [6:0] slave_addr_w,
	input wire [15:0] mem_addr_w,
	input wire [7:0] read_nbytes_w,
	input wire start,
	
	//outputs
	output reg [7:0] data_out,
	output reg byte_ready,
	 
	//i2c master comms lines
	output reg [6:0] i2c_slave_addr,
	output reg i2c_rw,
	output reg [7:0] i2c_write_data,
	output reg [7:0] i2c_nbytes,
	input wire [7:0] i2c_read_data,
	input wire i2c_tx_data_req,
	input wire i2c_rx_data_ready,
	output reg i2c_start
	);


	//state params
	localparam STATE_IDLE = 0;
	localparam STATE_START = 1;
	localparam STATE_WRITE_ADDR = 2;
	localparam STATE_REP_START = 3;
	localparam STATE_READ_DATA = 4;
	
	localparam READ = 1;
	localparam WRITE = 0;
	
	//local buffers to save the transfer information (device slave addr, 
	//  memory addr, etc) when the transfer is started
	reg [3:0] state;
	reg [6:0] slave_addr;
	reg [15:0] mem_addr;
	reg [7:0] read_nbytes; 
	//output register definitions
	reg waiting_for_tx;
	reg read_prev_data;
	reg [7:0] byte_count;
	
	
	always @(posedge clk) begin
	
		if (reset == 1) begin
			i2c_slave_addr <= 0;
			i2c_rw <= 0;
			i2c_write_data <= 0;
			i2c_start <= 0;
			i2c_nbytes <= 0;
			
			data_out <= 0;
			byte_ready <= 0;
			
			mem_addr <= 0;
			slave_addr <= 0;
			read_nbytes <= 0;
			byte_count <= 0;
			waiting_for_tx <= 0;
			
			state <= STATE_IDLE;
			
		end else begin
		
			case(state)
			
				STATE_IDLE: begin	//idle
					if (start) begin
						state <= STATE_START;
						
						//buffer all the control data
						slave_addr <= slave_addr_w;
						mem_addr <= mem_addr_w;
						read_nbytes <= read_nbytes_w;
					end
				end //state_idle
				
				
				STATE_START: begin 
					state <= STATE_WRITE_ADDR;
					
					//set all the i2c control lines
					i2c_slave_addr <= slave_addr;
					i2c_rw <= WRITE;
					i2c_nbytes <= 2;  //2 memory addr bytes
					byte_count <= 2;
					waiting_for_tx <= 0;

					i2c_start <= 1;
				end //state_start
				
				
				
				STATE_WRITE_ADDR: begin
					
					if (waiting_for_tx == 0) begin
						if (i2c_tx_data_req == 1) begin
							waiting_for_tx <= 1;
							case (byte_count)
								2: begin
									i2c_write_data <= mem_addr[15:8];
									byte_count <= byte_count - 1;
								end //case 2
								
								1: begin
									i2c_write_data <= mem_addr[7:0];
									byte_count <= byte_count - 1;
									state <= STATE_REP_START;
								end //case 1
							endcase
						end//if i2x_tx_data_req
					end else begin
						if (i2c_tx_data_req == 0) begin
							waiting_for_tx <= 0;
						end //if i2x_tx_data_req
					end //if waiting_for_tx
					
				end //state WRITE_ADDR
					

					
				STATE_REP_START: begin
					state <= STATE_READ_DATA;
					//set conditions for repeated start and change to read mode
					i2c_start <= 1;
					i2c_rw <= READ;
					i2c_nbytes <= read_nbytes;
					read_prev_data <= 0;
					byte_count <= 0;
					
				end //state_rep_start

				
				
				STATE_READ_DATA: begin
				
					if (read_prev_data == 0) begin
						if (i2c_rx_data_ready) begin
							data_out <= i2c_read_data;
							byte_ready <= 1;
							if (byte_count < (read_nbytes-1)) begin
								byte_count <= byte_count +1;
								read_prev_data <= 1;
							end else begin
								//we are done
								i2c_start <= 0;
								state <= STATE_IDLE;
							end // if byte_count < read_nbytes
						end //if i2c_rx_data_ready
						
					end else begin
						if (i2c_rx_data_ready == 0) begin
							read_prev_data <= 0;
							byte_ready <= 0;
						end //if i2c_rx_data_ready
					end // if read_prev_data
					
				end //state_read_data
			
			endcase
			
		end
	
	end

endmodule
