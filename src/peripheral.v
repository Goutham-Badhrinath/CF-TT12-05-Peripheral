/*
 * Copyright (c) 2025 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Change the name of this module to something that reflects its functionality and includes your name for uniqueness
// For example tqvp_yourname_spi for an SPI peripheral.
// Then edit tt_wrapper.v line 38 and change tqvp_example to your chosen module name.
module tqvp_example (
    input         clk,          // Clock - the TinyQV project clock is normally set to 64MHz.
    input         rst_n,        // Reset_n - low to reset.

    input  [7:0]  ui_in,        // The input PMOD, always available.  Note that ui_in[7] is normally used for UART RX.
                                // The inputs are synchronized to the clock, note this will introduce 2 cycles of delay on the inputs.

    output [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected.
                                // Note that uo_out[0] is normally used for UART TX.

    input [3:0]   address,      // Address within this peripheral's address space

    input         data_write,   // Data write request from the TinyQV core.
    input [7:0]   data_in,      // Data in to the peripheral, valid when data_write is high.
    
    output [7:0]  data_out      // Data out from the peripheral, set this in accordance with the supplied address
);

   // Example: Implement an 8-bit read/write register at address 0
    reg [7:0] instr_mem[0:15];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdy_clr <= 0;
            wr_en <= 0;
            data_out1 <= 0;
            din <= 0;
        end else begin
            rdy_clr <= 0;
            if (data_write && rdy && !tx_busy) begin instr_mem[address] <= dout; rdy_clr <= 1; end
            else if(!data_write)  begin data_out1 <= instr_mem[address]; end
        end
    end
    reg [7:0] data_out1;
    assign data_out = data_out1;
    reg [7:0] din;
    wire [7:0] dout;
    wire uart_rx = ui_in[7];  // properly connect to input bit
    wire uart_tx;
    reg wr_en;

    //assign uo_out[0]   = uart_tx;
    //assign uo_out[7:1] = 7'b0000000;
    assign uo_out = data_out1;
    reg rdy_clr;

    wire rdy;
    wire tx_busy;

    // UART instantiation
    uart my_uart (
        .din(din),
        .wr_en(wr_en),
        .clk_50m(clk),
        .rst(rst_n),
        .tx(uart_tx),
        .tx_busy(tx_busy),
        .rx(uart_rx),
        .rdy(rdy),
        .rdy_clr(rdy_clr),
        .dout(dout)
    );
    // Prevent unused warnings (like in example)
    wire _unused = &{ui_in[6:0]};
    wire _unused_1 = &{data_in};

endmodule
