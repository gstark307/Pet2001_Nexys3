`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////
//
// Engineer:	Thomas Skibo
// 
// Create Date: Aug 25, 2011
//
// Module Name: dispmux
//
// Description: Simplify display multiplexing for Nexys3 seven segment
//              displays.
//
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2011, Thomas Skibo.  All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
// * The names of contributors may not be used to endorse or promote products
//   derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL Thomas Skibo OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//
//////////////////////////////////////////////////////////////////////////////

module dispmux(output reg [7:0]	SevenSeg,
	       output reg [3:0]	SevenAnode,

	       input [7:0] 	dispA,		// leftmost display
	       input [7:0] 	dispB,
	       input [7:0] 	dispC,
	       input [7:0] 	dispD,		// rightmost display

	       input		reset,
	       input		clk
       );


    // Create a roughly 750 hz pulse by dividing the clock by 65,536.
    //
    reg [15:0]	clkdiv;
    reg 	pulse;
   
    always @(posedge clk)
	if (reset) begin
            clkdiv <= 16'd0;
            pulse <= 1'b0;
	end
	else begin
            clkdiv <= clkdiv + 1'b1;
            pulse <= (clkdiv == 16'hffff);
	end

    // Rotate through the four displays.
    //
    reg [1:0]	dispnum;
   
    always @(posedge clk)
	if (reset)
            dispnum <= 2'b00;
	else if (pulse)
            dispnum <= dispnum + 1'b1;

    // Demux the anode control.
    //
    always @(posedge clk)
	SevenAnode <= ~(4'b0001 << dispnum);

    // Mux the display control
    //
    always @(posedge clk)
	case (dispnum)
            2'b00: SevenSeg <= dispD;
            2'b01: SevenSeg <= dispC;
            2'b10: SevenSeg <= dispB;
            2'b11: SevenSeg <= dispA;
	endcase 
   
endmodule // dispmux
