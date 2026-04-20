`timescale 1ns / 1ps

module top_stopwatch_watch (
    input clk,
    input rst,
    input btnR,
    input btnL,
    input btnU,
    input btnD,
    input sw0,
    input sw15,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [1:0] led
);

    parameter MSEC_WIDTH = 7;
    parameter SEC_WIDTH = 6;
    parameter MIN_WIDTH = 6;
    parameter HOUR_WIDTH = 5;

    wire [MSEC_WIDTH-1:0] w_msec;
    wire [SEC_WIDTH-1:0] w_sec;
    wire [MIN_WIDTH-1:0] w_min;
    wire [HOUR_WIDTH-1:0] w_hour;

    wire w_run_stop;
    wire w_clear;
    wire w_down_mode;
    wire w_display_sel;
    wire [1:0] w_state_dbg;

    wire w_btnR;
    wire w_btnL;
    wire w_btnU;
    wire w_btnD;
    wire w_btnR_hold;
    wire w_btnL_hold;
    wire w_btnU_hold;
    wire w_btnD_hold;
    wire w_sw0;
    wire w_sw15;


    input_conditioning #(
        .CLK_FREQ_HZ(100_000_000),  // 100MHz
        .BD_HZ      (100_000),      // 100kHz
        .HOLD_TIME  (100_000_000)   // 1초
    ) U_BUTTON_EVENT_DECODER (
        .clk(clk),
        .rst(rst),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .sw0(w_sw0),
        .sw15(w_sw15),
        .o_btn_U(w_btnR),
        .o_btn_D(w_btnL),
        .o_btn_L(w_btnU),
        .o_btn_R(w_btnD),
        .o_btn_U_hold(w_btnR_hold),
        .o_btn_D_hold(w_btnL_hold),
        .o_btn_L_hold(w_btnU_hold),
        .o_btn_R_hold(w_btnD_hold),
        .o_sw0(w_sw0),
        .o_sw15(w_sw15)
    );

    /*
    button_debounce U_BTN_R (
        .clk(clk),
        .rst(rst),
        .i_btn(btnR),
        .o_btn_sync(),
        .o_btn_level(),
        .o_btn_tick(w_btnR)
    );

    button_debounce U_BTN_L (
        .clk(clk),
        .rst(rst),
        .i_btn(btnL),
        .o_btn_sync(),
        .o_btn_level(),
        .o_btn_tick(w_btnL)
    );

    button_debounce U_BTN_U (
        .clk(clk),
        .rst(rst),
        .i_btn(btnU),
        .o_btn_sync(),
        .o_btn_level(),
        .o_btn_tick(w_btnU)
    );

    button_debounce U_BTN_D (
        .clk(clk),
        .rst(rst),
        .i_btn(btnD),
        .o_btn_sync(),
        .o_btn_level(),
        .o_btn_tick(w_btnD)
    );
    */

    control_unit U_CONTROL_UNIT (
        .clk(clk),
        .rst(rst),
        .i_run_stop(w_btnR),
        .i_clear(w_btnL),
        .i_btnu(w_btnU),
        .i_btnd(w_btnD),
        .i_sw(sw),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear),
        .o_down_mode(w_down_mode),
        .o_display_sel(w_display_sel),
        .o_led(led),
        .o_state_dbg(w_state_dbg)
    );

    stopwatch_datapath U_STOPWATCH_DATAPATH (
        .clk(clk),
        .rst(rst),
        .i_run_stop(w_run_stop),
        .i_clear(w_clear),
        .i_down_mode(w_down_mode),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );

    fnd_controller #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) U_FND_CONTROLLER (
        .clk(clk),
        .rst(rst),
        .sw(w_display_sel),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

endmodule
