`timescale 1ns / 1ps

module input_conditioning #(
    parameter CLK_FREQ_HZ = 100_000_000,  // 100MHz
    parameter BD_HZ = 100_000,
    parameter HOLD_TIME = 100_000_000  // 1.5초
) (
    input  clk,
    input  rst,
    input  btnU,
    input  btnD,
    input  btnL,
    input  btnR,
    input  sw0,
    input  sw15,
    output o_btnU,
    output o_btnD,
    output o_btnL,
    output o_btnR,
    output o_btnU_hold,
    output o_btnD_hold,
    output o_btnL_hold,
    output o_btnR_hold,
    output o_sw0,
    output o_sw15
);

    assign o_sw0  = sw0;
    assign o_sw15 = sw15;

    debouncer #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),  // 100MHz
        .BD_HZ      (BD_HZ),
        .HOLD_TIME  (HOLD_TIME)     // 1.5초
    ) U_BTN_U (
        .clk       (clk),
        .rst       (rst),
        .i_btn     (btnU),
        .o_btn     (o_btnU),
        .o_btn_hold(o_btnU_hold)
    );

    debouncer #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),  // 100MHz
        .BD_HZ      (BD_HZ),
        .HOLD_TIME  (HOLD_TIME)     // 1.5초
    ) U_BTN_D (
        .clk       (clk),
        .rst       (rst),
        .i_btn     (btnD),
        .o_btn     (o_btnD),
        .o_btn_hold(o_btnD_hold)
    );

    debouncer #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),  // 100MHz
        .BD_HZ      (BD_HZ),
        .HOLD_TIME  (HOLD_TIME)     // 1.5초
    ) U_BTN_L (
        .clk       (clk),
        .rst       (rst),
        .i_btn     (btnL),
        .o_btn     (o_btnL),
        .o_btn_hold(o_btnL_hold)
    );

    debouncer #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),  // 100MHz
        .BD_HZ      (BD_HZ),
        .HOLD_TIME  (HOLD_TIME)     // 1.5초
    ) U_BTN_R (
        .clk       (clk),
        .rst       (rst),
        .i_btn     (btnR),
        .o_btn     (o_btnR),
        .o_btn_hold(o_btnR_hold)
    );



endmodule


