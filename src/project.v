/*
 * Copyright (c) 2026 Frome Road
 * SPDX-License-Identifier: Apache-2.0
 *
 * Placeholder Tiny Tapeout top. Proves the CMOS5L sim + GDS flow end to end.
 * Replace with the hardwired UART TX (issue #10), then the programmable core.
 */

`default_nettype none

module tt_um_omnichip (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Placeholder: sum of the two input buses. Enough to exercise cocotb + GDS.
  assign uo_out  = ui_in + uio_in;
  assign uio_out = 8'd0;
  assign uio_oe  = 8'd0;

  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
