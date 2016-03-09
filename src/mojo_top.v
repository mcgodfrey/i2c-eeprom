module mojo_top(
    // 50MHz clock input
    input wire clk,
    // Input from reset button (active low)
    input wire rst_n,
    // cclk input from AVR, high when AVR is ready
    input wire cclk,
    // Outputs to the 8 onboard LEDs
    output wire [7:0]led,
    // AVR SPI connections
    output wire spi_miso,
    input wire spi_ss,
    input wire spi_mosi,
    input wire spi_sck,
    // AVR ADC channel select
    output wire [3:0] spi_channel,
    // Serial connections
    input wire avr_tx, // AVR Tx => FPGA Rx
    output wire avr_rx, // AVR Rx => FPGA Tx
    input wire avr_rx_busy, // AVR Rx buffer full
	 
	 output wire i2c_scl,
	 inout wire i2c_sda,
	 
	 output wire i2c_clk_in
    );

wire reset = ~rst_n; // make reset active high

// these signals should be high-z when not used
assign spi_miso = 1'bz;
assign avr_rx = 1'bz;
assign spi_channel = 4'bzzzz;

assign led[5:0] = led_buffer;
assign led[7] = tick_1s;
assign led[6] = i2c_clk_in;

wire tick_1s;

//Generate a 1s timer
//timer #(.CTR_LEN(26)) second_timer (
timer #(.CTR_LEN(16)) second_timer (
    .clk(clk), 
    .reset(reset), 
    .tick(tick_1s)
    );


clk_divider #(.DIVIDER(500)) i2c_clk_divider (
    .reset(reset), 
    .clk_in(clk), 
    .clk_out(i2c_clk_in)
    );
	 
wire i2c_start;
reg i2c_reset = 1'b1;
wire [7:0] i2c_nbytes;
wire [6:0] i2c_slave_addr;
wire i2c_rw;
wire [7:0] i2c_write_data;
wire [7:0] i2c_read_data;
wire i2c_tx_data_req;
wire i2c_rx_data_ready;
wire ready;
wire busy;

i2c_master i2c (
	.clk(i2c_clk_in), 
	.reset(i2c_reset), 
	.start(i2c_start), 
	.nbytes_in(i2c_nbytes), 
	.addr_in(i2c_slave_addr), 
	.rw_in(i2c_rw), 
	.write_data(i2c_write_data), 
	.read_data(i2c_read_data), 
	.tx_data_req(i2c_tx_data_req), 
	.rx_data_ready(i2c_rx_data_ready), 
	.sda_w(i2c_sda), 
	.scl(i2c_scl)
);

wire [6:0] slave_addr = 7'b1010000;
reg [15:0] mem_addr;
wire [7:0] read_n_bytes = 8'd1;

wire [7:0] read_nbytes = 1;
reg start = 0;
wire [7:0] data_out;
wire byte_ready;
wire eeprom_busy;

read_eeprom instance_name (
	.clk(clk), 
	.reset(reset), 
	.slave_addr_w(slave_addr), 
	.mem_addr_w(mem_addr), 
	.read_nbytes_w(read_nbytes), 
	.start(start), 
	.data_out(data_out), 
	.byte_ready(byte_ready), 
	.i2c_slave_addr(i2c_slave_addr), 
	.i2c_rw(i2c_rw), 
	.i2c_write_data(i2c_write_data), 
	.i2c_nbytes(i2c_nbytes), 
	.i2c_read_data(i2c_read_data), 
	.i2c_tx_data_req(i2c_tx_data_req), 
	.i2c_rx_data_ready(i2c_rx_data_ready), 
	.i2c_start(i2c_start),
	.busy(eeprom_busy)
);

reg [5:0] led_buffer;

//every time a new byte is ready, write it to the LEDs
always @(posedge byte_ready) begin
	led_buffer <= data_out[5:0];
end


reg measured_this_pulse;

always @(posedge clk) begin
	if (reset == 1) begin
		mem_addr <= 16'h0000;
		measured_this_pulse <= 0;
		
	end else begin
	
	if ((tick_1s == 1) && (measured_this_pulse == 0)) begin
		measured_this_pulse <= 1;
		mem_addr <= mem_addr + 1'b1;
		if (mem_addr > 8) begin
			mem_addr <= 0;
		end
		start <= 1;
	end //tick_1s==1
	
	if ((start == 1) && (eeprom_busy == 1)) begin
		start <= 0;
	end //eeprom_busy and start
	
	if (tick_1s == 0) begin
		measured_this_pulse <= 0;
	end //tick_1s==0
	
	end //reset
end


//we need to make sure the i2c module is reset *after*
//it's clock has begun
always @(negedge i2c_clk_in) begin
	
	if (reset == 1) begin
		i2c_reset <= 1;
	end else begin
		i2c_reset <= 0;
	end
end //posedge clk_i2c_in

	



endmodule