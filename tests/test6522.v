`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:04:05 10/12/2011
// Design Name:   via6522
// Module Name:   test6522
// Project Name:  Pet2001
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: via6522
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test6522;

    // Inputs
    reg [7:0] data_in;
    reg [3:0] addr;
    reg       strobe;
    reg       we;
    reg [7:0] porta_in;
    reg [7:0] portb_in;
    reg       ca1_in;
    reg       ca2_in;
    reg       cb1_in;
    reg       cb2_in;
    reg       slow_clock;
    reg       clk;
    reg       reset;

    // Outputs
    wire [7:0] data_out;
    wire       irq;
    wire [7:0] porta_out;
    wire [7:0] portb_out;
    wire       ca2_out;
    wire       cb1_out;
    wire       cb2_out;

    // Instantiate the Unit Under Test (UUT)
    via6522 uut (
		 .data_out(data_out), 
		 .data_in(data_in), 
		 .addr(addr), 
		 .strobe(strobe), 
		 .we(we), 
		 .irq(irq), 
		 .porta_out(porta_out), 
		 .porta_in(porta_in), 
		 .portb_out(portb_out), 
		 .portb_in(portb_in), 
		 .ca1_in(ca1_in), 
		 .ca2_out(ca2_out), 
		 .ca2_in(ca2_in), 
		 .cb1_out(cb1_out), 
		 .cb1_in(cb1_in), 
		 .cb2_out(cb2_out), 
		 .cb2_in(cb2_in), 
		 .slow_clock(slow_clock), 
		 .clk(clk), 
		 .reset(reset)
	 );

    task write_reg(input [3:0] a, input [7:0] d);
	begin
	    data_in <= d;
	    addr <= a;
	    @(posedge clk);
	    strobe <= 1;
	    we <= 1;
	    @(posedge clk);
	    strobe <= 0;
	    we <= 0;
	    data_in <= 8'hXX;
	    addr <= 4'bxxxx;
	    @(posedge clk);
	end
    endtask // write_reg

    task read_reg(input [3:0] a, output [7:0] d);
	begin
	    addr <= a;
	    @(posedge clk);
	    strobe <= 1;
	    we <= 0;
	    d = data_out;
	    @(posedge clk);
	    strobe <= 0;
	    addr <= 4'bxxxx;
	    @(posedge clk);
	end
    endtask // read_reg
    

    reg [7:0] temp8;

    initial begin
	// Initialize Inputs
	data_in = 8'hXX;
	addr = 4'bxxxx;
	strobe = 0;
	we = 0;
	porta_in = 0;
	portb_in = 0;
	ca1_in = 0;
	ca2_in = 0;
	cb1_in = 0;
	cb2_in = 0;
	slow_clock = 0;
	clk = 0;
	reset = 1;

	// Wait 100 ns for global reset to finish
	#100;
        
	// Add stimulus here
	repeat (8) @(posedge clk);
	reset <= 0;

	repeat (8) @(posedge clk);
	write_reg(4'hB, 8'h10);
	write_reg(4'hA, 8'h0f);
	write_reg(4'h8, 8'd238);

	repeat (10) @(posedge clk);
	read_reg(4'hA, temp8);
	$display("Just for fun: SR=", temp8);

    end // initial begin

    always #5.0 clk = ~clk;
    
    always @(posedge clk) begin
	slow_clock <= 1'b1;
	@(posedge clk);
	slow_clock <= 1'b0;
	repeat (98) @(posedge clk);
    end
    
endmodule

