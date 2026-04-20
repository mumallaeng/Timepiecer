`timescale 1ns / 1ps

module display_select #(
    parameter MAIN_CLK_100MHZ = 100_000_000,
    parameter MSEC_WIDTH      = 7,
    parameter SEC_WIDTH       = 6,
    parameter MIN_WIDTH       = 6,
    parameter HOUR_WIDTH      = 5
) (
    input      [MSEC_WIDTH  -1:0] i_timer_msec,
    input      [SEC_WIDTH   -1:0] i_timer_sec,
    input      [MIN_WIDTH   -1:0] i_timer_min,
    input      [HOUR_WIDTH  -1:0] i_timer_hour,
    input      [MSEC_WIDTH  -1:0] i_timepiece_msec,
    input      [SEC_WIDTH   -1:0] i_timepiece_sec,
    input      [MIN_WIDTH   -1:0] i_timepiece_min,
    input      [HOUR_WIDTH  -1:0] i_timepiece_hour,
    input                         i_sw0,
    input                         i_sw15,
    output reg [MSEC_WIDTH  -1:0] o_display_msec,
    output reg [SEC_WIDTH   -1:0] o_display_sec,
    output reg [MIN_WIDTH   -1:0] o_display_min,
    output reg [HOUR_WIDTH  -1:0] o_display_hour,
    output reg                    o_led_12_hour,
    output reg                    o_led_timer

);

    reg [MSEC_WIDTH  -1:0] w_display_msec;
    reg [SEC_WIDTH   -1:0] w_display_sec;
    reg [MIN_WIDTH   -1:0] w_display_min;
    reg [HOUR_WIDTH  -1:0] w_display_hour;

    always @(*) begin
        if (!i_sw0) begin
            w_display_msec = i_timepiece_msec;
            w_display_sec  = i_timepiece_sec;
            w_display_min  = i_timepiece_min;
            w_display_hour = i_timepiece_hour;
            o_led_timer    = 0;
        end else begin
            w_display_msec = i_timer_msec;
            w_display_sec  = i_timer_sec;
            w_display_min  = i_timer_min;
            w_display_hour = i_timer_hour;
            o_led_timer    = 1;
        end
    end

    always @(*) begin
        if (!i_sw15) begin
            o_display_msec = w_display_msec;
            o_display_sec  = w_display_sec;
            o_display_min  = w_display_min;
            o_display_hour = w_display_hour;
            o_led_12_hour  = 0;
        end else begin
            o_display_msec = w_display_msec - 12;
            o_display_sec  = w_display_sec;
            o_display_min  = w_display_min;
            o_display_hour = w_display_hour;
            o_led_12_hour  = 1;

        end
    end


endmodule
