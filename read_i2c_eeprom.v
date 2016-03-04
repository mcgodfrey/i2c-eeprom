module read_i2c_eeprom(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy // AVR Rx buffer full
	 
    //i2c User Interface
	 //output i2c_scl,
	 //inout i2c_sda
    );

wire reset = ~rst_n; // make reset active high

// these signals should be high-z when not used
assign spi_miso = 1'bz;
assign avr_rx = 1'bz;
assign spi_channel = 4'bzzzz;

assign led[5:0] = 6'b000000;
assign led[7] = tick_1s;
assign led[6] = clk_i2c_in;

wire tick_1s;
wire i2c_clk_in;

//wire i2c_scl = 1'b1;
//wire i2c_sda = 1'b1;

//Generate a 1s timer
timer #(.CTR_LEN(26)) second_timer (
//timer second_timer (
    .clk(clk), 
    .reset(reset), 
    .tick(tick_1s)
    );
	 

wire i2c_clk_divider_reset = reset;


clk_divider i2c_clk_divider (
    .reset(i2c_clk_divider_reset), 
    .clk_in(clk), 
    .clk_out(i2c_clk_in)
    );


wire i2c_start;
wire i2c_reset;
wire [7:0] i2c_nbytes;
wire [6:0] i2c_slave_addr;
wire i2c_rw;
wire [7:0] i2c_write_data;
wire [7:0] i2c_read_data;
wire i2c_tx_data_req;
wire i2c_rx_data_ready;
wire i2c_sda;
wire i2c_scl;
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
		.sda_w(sda_w), 
		.scl(scl), 
		.ready(ready), 
		.busy(busy)
	);

wire [6:0] slave_addr = 7'b1010000;
wire [15:0] mem_addr = 16'h0000;
wire [7:0] read_n_bytes = 8'd1;
wire read_eeprom_reset = 1;

wire [7:0] read_nbytes = 0;
wire start = 0;
wire [7:0] data_out;
wire byte_ready;


read_eeprom instance_name (
    .clk(clk), 
    .reset(read_eeprom_reset), 
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
    .i2c_start(i2c_start)
    );
	 
	 
always @(posedge tick_1s) begin
	 if (reset == 1) begin
	 
	 end else begin
	 
	 end // reset
end //always

	 
/*
//constants
wire [6:0] slave_addr = 7'b1010000;
wire [7:0] mem_addr = 8'b00000000;
wire [7:0] read_n_bytes = 8'd1;

reg [7:0] data_out;

//hookup wires
wire [6:0] i2c_slave_addr;
wire i2c_rw;
wire [7:0] i2c_nbytes;
wire [7:0] i2c_write_data;
wire [7:0] i2c_read_data;
wire i2c_tx_data_req;
wire i2c_rx_data_ready;
wire i2c_start;


	 
	 
/we need to make sure the i2c module is reset *after*
//it's clock has begun
always @(posedge clk_i2c_in) begin
	
	if (reset == 1) begin
		
	end else begin
		i2c_reset <= 0;
	end
end //posedge clk_i2c_in
	
	
//Every 1s I read a new value from EEPROM
always @(posedge tick_1s) begin
	

end //posedge tick_1s



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
    .i2c_start(i2c_start)
    );


wire ready;
wire busy;
wire i2c_reset;




clk_divider i2c_clk_divider (
    .reset(reset), 
    .clk_in(clk), 
    .clk_out(clk_i2c_in)
    );
	 
	 
i2c_master instance_name (
    .clk(clk_i2c_in), 
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
    .scl(i2c_scl), 
    .ready(ready), 
    .busy(busy)
    );

*/




endmodule