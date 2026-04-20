`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/17 23:59:23
// Design Name: 
// Module Name: tb_debouncer
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


module tb_debouncer ();

    reg clk, rst, i_btn;
    wire o_btn, o_btn_hold;

    debouncer U0 (
        .clk(clk),
        .rst(rst),
        .i_btn(i_btn),
        .o_btn(o_btn),
        .o_btn_hold(o_btn_hold)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst   = 1;
        i_btn = 0;

        repeat (3) @(negedge clk);
        rst = 0;
        #10;

        i_btn = 1;
        #(5 * 100000000);

        i_btn = 0;

        #20;
        $stop;
    end



endmodule
