`timescale 1ns / 1ps

module display_select #(
    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH  = 6,
    parameter MIN_WIDTH  = 6,
    parameter HOUR_WIDTH = 5
) (
    input [MSEC_WIDTH-1:0] i_timer_msec,
    input [SEC_WIDTH-1:0] i_timer_sec,
    input [MIN_WIDTH-1:0] i_timer_min,
    input [HOUR_WIDTH-1:0] i_timer_hour,
    input [MSEC_WIDTH-1:0] i_timepiece_msec,
    input [SEC_WIDTH-1:0] i_timepiece_sec,
    input [MIN_WIDTH-1:0] i_timepiece_min,
    input [HOUR_WIDTH-1:0] i_timepiece_hour,
    input i_sw0,
    input i_sw15,
    output reg [MSEC_WIDTH-1:0] o_display_msec,
    output reg [SEC_WIDTH-1:0] o_display_sec,
    output reg [MIN_WIDTH-1:0] o_display_min,
    output reg [HOUR_WIDTH-1:0] o_display_hour,
    output reg o_led_12_hour,
    output reg o_led_timer
);

    always @(*) begin
        if (!i_sw0) begin  // sw0=0이면 Timepiece 선택
            o_display_msec = i_timepiece_msec;
            o_display_sec  = i_timepiece_sec;
            o_display_min  = i_timepiece_min;
            o_display_hour = i_timepiece_hour;
            o_led_timer    = 1'b0;
            o_led_12_hour  = i_sw15;
        end else begin  // sw0=1이면 Timer 선택
            o_display_msec = i_timer_msec;
            o_display_sec  = i_timer_sec;
            o_display_min  = i_timer_min;
            o_display_hour = i_timer_hour;
            o_led_timer    = 1'b1;
            o_led_12_hour  = 1'b0;
        end
    end

endmodule
