`timescale 1ns / 1ps

module time_set_module #(
    parameter integer MSEC_WIDTH = 7,
    parameter integer SEC_WIDTH  = 6,
    parameter integer MIN_WIDTH  = 6,
    parameter integer HOUR_WIDTH = 5,
    parameter integer MSEC_TIMES = 100,
    parameter integer SEC_TIMES  = 60,
    parameter integer MIN_TIMES  = 60,
    parameter integer HOUR_TIMES = 24
) (
    input clk,
    input rst,
    input i_set_mode,
    input [1:0] i_set_index,
    input i_index_shift,
    input i_increment,
    input i_decrement,
    input [23:0] i_live_time,
    output [23:0] o_set_time
);

    localparam MSEC_LSB = 0;
    localparam MSEC_MSB = 6;
    localparam SEC_LSB  = 7;
    localparam SEC_MSB  = 12;
    localparam MIN_LSB  = 13;
    localparam MIN_MSB  = 18;
    localparam HOUR_LSB = 19;
    localparam HOUR_MSB = 23;

    localparam UNIT_MSEC = 2'd0;
    localparam UNIT_SEC  = 2'd1;
    localparam UNIT_MIN  = 2'd2;
    localparam UNIT_HOUR = 2'd3;

    localparam [MSEC_WIDTH-1:0] MSEC_MAX = MSEC_TIMES - 1;
    localparam [SEC_WIDTH-1:0]  SEC_MAX  = SEC_TIMES  - 1;
    localparam [MIN_WIDTH-1:0]  MIN_MAX  = MIN_TIMES  - 1;
    localparam [HOUR_WIDTH-1:0] HOUR_MAX = HOUR_TIMES - 1;

    reg [1:0] set_index_reg;
    reg [1:0] set_index_next;
    reg set_mode_d_reg;

    reg [MSEC_WIDTH-1:0] set_msec_reg;
    reg [SEC_WIDTH-1:0] set_sec_reg;
    reg [MIN_WIDTH-1:0] set_min_reg;
    reg [HOUR_WIDTH-1:0] set_hour_reg;

    reg [MSEC_WIDTH-1:0] set_msec_next;
    reg [SEC_WIDTH-1:0] set_sec_next;
    reg [MIN_WIDTH-1:0] set_min_next;
    reg [HOUR_WIDTH-1:0] set_hour_next;

    wire [MSEC_WIDTH-1:0] live_msec;
    wire [SEC_WIDTH-1:0] live_sec;
    wire [MIN_WIDTH-1:0] live_min;
    wire [HOUR_WIDTH-1:0] live_hour;

    assign live_msec = i_live_time[MSEC_MSB:MSEC_LSB];
    assign live_sec  = i_live_time[SEC_MSB:SEC_LSB];
    assign live_min  = i_live_time[MIN_MSB:MIN_LSB];
    assign live_hour = i_live_time[HOUR_MSB:HOUR_LSB];

    assign o_set_time = {set_hour_reg, set_min_reg, set_sec_reg, set_msec_reg};

    always @(posedge clk or posedge rst) begin
        if (rst) begin  // reset이면 설정 버스와 set index 초기화
            set_index_reg  <= UNIT_MSEC;
            set_mode_d_reg <= 1'b0;
            set_msec_reg   <= 0;
            set_sec_reg    <= 0;
            set_min_reg    <= 0;
            set_hour_reg   <= 0;
        end else begin  // 평소에는 설정 버스와 set index 업데이트
            set_index_reg  <= set_index_next;
            set_mode_d_reg <= i_set_mode;
            set_msec_reg   <= set_msec_next;
            set_sec_reg    <= set_sec_next;
            set_min_reg    <= set_min_next;
            set_hour_reg   <= set_hour_next;
        end
    end

    always @(*) begin
        set_index_next = set_index_reg;

        set_msec_next = set_msec_reg;
        set_sec_next  = set_sec_reg;
        set_min_next  = set_min_reg;
        set_hour_next = set_hour_reg;

        if (!i_set_mode) begin
            // set 모드가 아니면 설정 버스가 현재 실시간 시계값을 따라가게 함.
            set_msec_next = live_msec;
            set_sec_next  = live_sec;
            set_min_next  = live_min;
            set_hour_next = live_hour;
        end else if (!set_mode_d_reg) begin
            // set 모드로 처음 진입한 순간에는 현재 시계를 기준으로 편집 시작함.
            set_index_next = i_set_index;
            set_msec_next  = live_msec;
            set_sec_next   = live_sec;
            set_min_next   = live_min;
            set_hour_next  = live_hour;
        end else if (i_index_shift) begin
            // INDEX_SHIFT 상태에서 현재 편집 단위를 다음 단위로 이동함.
            set_index_next = set_index_reg + 1'b1;
        end else if (i_increment) begin
            // increment 펄스가 들어오면 현재 선택 단위만 1 증가시킴.
            case (set_index_reg)
                UNIT_MSEC: begin
                    if (set_msec_reg == MSEC_MAX) set_msec_next = 0;
                    else set_msec_next = set_msec_reg + 1'b1;
                end
                UNIT_SEC: begin
                    if (set_sec_reg == SEC_MAX) set_sec_next = 0;
                    else set_sec_next = set_sec_reg + 1'b1;
                end
                UNIT_MIN: begin
                    if (set_min_reg == MIN_MAX) set_min_next = 0;
                    else set_min_next = set_min_reg + 1'b1;
                end
                UNIT_HOUR: begin
                    if (set_hour_reg == HOUR_MAX) set_hour_next = 0;
                    else set_hour_next = set_hour_reg + 1'b1;
                end
                default: begin
                    set_msec_next = set_msec_reg;
                end
            endcase
        end else if (i_decrement) begin
            // decrement 펄스가 들어오면 현재 선택 단위만 1 감소시킴.
            case (set_index_reg)
                UNIT_MSEC: begin
                    if (set_msec_reg == 0) set_msec_next = MSEC_MAX;
                    else set_msec_next = set_msec_reg - 1'b1;
                end
                UNIT_SEC: begin
                    if (set_sec_reg == 0) set_sec_next = SEC_MAX;
                    else set_sec_next = set_sec_reg - 1'b1;
                end
                UNIT_MIN: begin
                    if (set_min_reg == 0) set_min_next = MIN_MAX;
                    else set_min_next = set_min_reg - 1'b1;
                end
                UNIT_HOUR: begin
                    if (set_hour_reg == 0) set_hour_next = HOUR_MAX;
                    else set_hour_next = set_hour_reg - 1'b1;
                end
                default: begin
                    set_msec_next = set_msec_reg;
                end
            endcase
        end
    end

endmodule
