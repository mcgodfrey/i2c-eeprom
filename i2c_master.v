`default_nettype none
/*

References:
https://eewiki.net/pages/viewpage.action?pageId=10125324
http://faculty.lasierra.edu/~ehwang/digitaldesign/public/projects/DE2/I2C/I2C.pdf

*/

module i2c_master(
		input wire clk,
		input wire reset,
		input wire start,
		
		input wire [7:0] nbytes_in,
		input wire [6:0] addr_in,
		input wire rw_in,
		input wire [7:0] write_data,
		output reg [7:0] read_data,
		output reg tx_data_req, 
		output reg rx_data_ready, 
		
		inout wire sda_w,
		output wire scl,
		
		output wire ready,
		output wire busy
	);
	
	localparam STATE_IDLE = 0;
	localparam STATE_START = 1;
	localparam STATE_ADDR = 2;
	localparam STATE_RW = 3;
	localparam STATE_ACK = 4;
	localparam STATE_READ_ACK = 5;
	localparam STATE_TX_DATA = 6;
	localparam STATE_RX_DATA = 7;
	localparam STATE_STOP = 8;
	
	localparam READ = 1;
	localparam WRITE = 0;
	localparam ACK = 0;
	
	reg [7:0] state;
	reg [7:0] bit_count;	//bit counter
	//local buffers
	reg [6:0] addr;
	reg [7:0] data;
	reg [7:0] nbytes;
	reg rw;
	reg scl_en = 0;
	reg sda;
	
	assign sda_w = ((sda)==0) ? 0 : 1'bz;
	
	assign ready = ((reset == 0) && (state == STATE_IDLE)) ? 1 : 0;
	assign busy = ~ready;
	

	//clock
	//scl is enabled whenever we are sending or receiving data.
	//otherwise it is held at 1
	assign scl = (scl_en == 0) ? 1 : ~clk;
	
	always @(negedge clk) begin
		if (reset == 1) begin
			scl_en <= 0;
			
		end else begin
			if ((state == STATE_IDLE) || (state == STATE_START) || (state == STATE_STOP)) begin
				scl_en <= 0;
			end
			else begin
				scl_en <= 1;
			end
			
			//I need to check the ack on the rising scl edge (which is the neg edge of clk)
			if (state == STATE_ACK) begin
				if (0) begin
					state <= STATE_IDLE;
				end
			end
		end
		
	end
	
	

	//FSM
	always @(posedge clk) begin
		if (reset == 1) begin
			state <= STATE_IDLE;
			sda <= 1;
			bit_count <= 8'd0;
			addr <= 0;
			data <= 0;
			nbytes <= 0;
			rw <= 0;
			tx_data_req <= 0;
			rx_data_ready <= 0;
		end	//if reset
		
		else begin
			case(state)
			
				STATE_IDLE: begin	//idle
					sda <= 1;
					if (start) begin
						state <= STATE_START;
					end else begin
						state <= STATE_IDLE;
					end //if start
				end
				
				
				STATE_START: begin //start
					state <= STATE_ADDR;
					sda <= 0;	//send start condition
					//latch in all the values
					addr <= addr_in;
					nbytes <= nbytes_in;
					rw <= rw_in;
					if (rw_in == WRITE) begin
						tx_data_req <= 1;  //request the first byte of data
					end
					bit_count <= 6;	//addr is only 7 bits long, not 8
				end	//state_start
				
				
				STATE_ADDR: begin //address
					sda <= addr[bit_count];
					if (bit_count == 0) begin
						state <= STATE_RW;
					end
					else begin
						bit_count <= bit_count - 1;
					end
				end	//state_addr
				
				
				STATE_RW: begin
					sda <= rw;
					state <= STATE_ACK;
				end	//state_rw
				
				
				STATE_ACK: begin
					//release the sda line and await ack
					sda <= 1;
					//Ack is checked on the rising edge of scl (neg edge of clk)
					//So I just assume that it is all ok and set the next state here
					//if there is no ack then the state will be overwritten
					
					tx_data_req <= 0; 
					//now we have to decide what to do next.
					if (nbytes == 0) begin
						//there is no data left to read/write
						if (start == 1) begin
							//repeat start condition
							sda <= 1;
							state <= STATE_START;
						end else begin
							//we are done
							sda <= 0;
							state <= STATE_STOP;
						end	//if start == 1
						
					end else begin
						//we have more data to read/write
						if (rw == WRITE) begin
							data <= write_data;  //latch in the new data byte
							bit_count <= 7;  //8 data bits
							state <= STATE_TX_DATA;
						end else begin
							// Read data
							bit_count <= 7;	//8 data bits
							state <= STATE_RX_DATA;
						end //if rw_buf == WRITE
					end //if nbytes_buf == 0
						

				end //state_ack
				
				
				STATE_READ_ACK: begin
					//check that i receive ack
					//if (sda_w == ACK) begin
					if (1) begin
					
						//now we have to decide what to do next.
						if (nbytes == 0) begin
							//there is no data left to read/write
							if (start == 1) begin
								//repeat start condition
								sda <= 1;
								state <= STATE_START;
							end else begin
								//we are done
								sda <= 0;
								state <= STATE_STOP;
							end	//if start == 1
							
						end else begin
							//we have more data to read/write
							if (rw == WRITE) begin
								data <= write_data;	//latch in the new data byte
								tx_data_req <= 1;
								bit_count <= 7;	//8 data bits
								state <= STATE_TX_DATA;
							end else begin
								// Read data
								bit_count <= 7;	//8 data bits
								state <= STATE_RX_DATA;
							end //if rw_buf == WRITE
						end //if nbytes_buf == 0
						
					end else begin
						//ERROR - no ack received. return to idle
						state <= STATE_IDLE;
					end //if sda == ACK
					
				end //state_read_ack
				
				STATE_TX_DATA: begin
					sda <= data[bit_count];
					if (nbytes > 0) begin
						tx_data_req <= 1;  //if there are more bytes to write, then request the next one
					end
					if (bit_count == 0) begin
						//byte transfer complete
						state <= STATE_ACK;
						nbytes <= nbytes-1;
					end
					else begin
						bit_count <= bit_count -1;
					end
				end	//state_tx_data
				
				STATE_RX_DATA: begin
					data[bit_count] <= sda_w;
					if (bit_count == 0) begin
						//byte transfer complete
						state <= STATE_ACK;
						read_data[7:1] <= data[7:1];
						read_data[0] <= sda_w;
						rx_data_ready <= 1;
						nbytes <= nbytes-1;
					end
					else begin
						bit_count <= bit_count - 1;
					end
				end	//state_rx_data
				
				STATE_STOP: begin
					sda <= 1;
					state <= STATE_IDLE;
				end	//state_stop
				
			endcase
		end	//if reset (else)
	end	//always

endmodule
