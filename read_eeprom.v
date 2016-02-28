
module read_eeprom(
	//inputs
	input wire clk,
	input wire reset,
	input wire [6:0] slave_addr_w,
	input wire [15:0] mem_addr_w,
	input wire [7:0] read_nbytes_w,
	input wire start,
	 
	//i2c master comms lines
	output reg [6:0] i2c_slave_addr,
	output reg i2c_rw,
	output reg [7:0] i2c_write_data,
	output reg [7:0] i2c_nbytes,
	input wire [7:0] i2c_read_data,
	input wire i2c_tx_data_req,
	input wire i2c_rx_data_ready,
	output reg i2c_start,
	
	//outputs
	output reg [7:0] data_out,
	output reg byte_ready
	);


	localparam STATE_IDLE = 0;
	localparam STATE_START = 1;
	localparam STATE_WRITE_ADDR = 2;
	localparam STATE_READ_DATA = 3;
	
	localparam READ = 1;
	localparam WRITE = 0;
	
	reg [3:0] state;
	reg [6:0] slave_addr;
	reg [15:0]mem_addr;
	reg [7:0] read_nbytes; 
	reg data_sent;
	reg bytes_to_send;
	
	
	always @(posedge clk) begin
		if (reset == 1) begin
			i2c_slave_addr <= 0;
			i2c_rw <= 0;
			i2c_write_data <= 0;
			i2c_start <= 0;
			i2c_nbytes <= 0;
			
			data_out <= 0;
			byte_ready <= 0;
			
			data_sent <= 0;
			mem_addr <= 0;
			slave_addr <= 0;
			read_nbytes <= 0;
			bytes_to_send <= 0;
			
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
					
					i2c_slave_addr <= slave_addr;
					i2c_rw <= WRITE;
					i2c_nbytes <= 2;  //2 memory addr bytes
					bytes_to_send <= 2;
					data_sent <= 0;

					i2c_start <= 1;
				end //state_start
				
				
				STATE_WRITE_ADDR: begin
					
					if (data_sent == 0) begin
						if (i2c_tx_data_req == 1) begin
							data_sent <= 1;
							if (bytes_to_send == 2) begin
								i2c_write_data <= mem_addr[15:8];
								bytes_to_send <= bytes_to_send - 1;
							end else begin
								i2c_write_data <= mem_addr[7:0];
								state <= STATE_READ_DATA;
							end  //if bytes_to_send == 2
						end  //if tx_data_req
						
					end else begin
						if (i2c_tx_data_req == 0) begin
							data_sent <= 0;
						end  //if tx_data_req
					end  //if data_sent
						
				end //state_write_addr
				
				
				STATE_READ_DATA: begin
					
				end //state_read_data
			
			endcase
			
		end
	
	end

endmodule
