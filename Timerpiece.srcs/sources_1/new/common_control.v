`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/18 16:19:04
// Design Name: 
// Module Name: common_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module common_control (
    input clk,
    input rst,
    input i_btnR_hold,
    output reg o_display_mode

);
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            o_display_mode <= 0;
        end else if (i_btnR_hold) begin
            o_display_mode <= ~o_display_mode;
        end else begin
            o_display_mode <= o_display_mode;
        end
    end

endmodule
