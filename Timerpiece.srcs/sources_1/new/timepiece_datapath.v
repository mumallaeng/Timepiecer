`timescale 1ns / 1ps

module timepiece_datapath #(
    parameter integer MSEC_TIMES = 100,
    parameter integer SEC_TIMES  = 60,
    parameter integer MIN_TIMES  = 60,
    parameter integer HOUR_TIMES = 24,
    parameter integer MSEC_WIDTH = 7,
    parameter integer SEC_WIDTH  = 6,
    parameter integer MIN_WIDTH  = 6,
    parameter integer HOUR_WIDTH = 5
) (
    input clk,
    input rst,
    input i_set_mode,
    input [1:0] i_set_index,
    input i_index_shift,
    input i_increment,
    input i_decrement,
    input [1:0] i_time_24,
    output [23:0] o_set_time,
    output [23:0] o_timepiece_vault,
    output o_sec_tick,
    output o_min_tick,
    output o_hour_tick,
    output [MSEC_WIDTH-1:0] msec,
    output [SEC_WIDTH-1:0] sec,
    output [MIN_WIDTH-1:0] min,
    output [HOUR_WIDTH-1:0] hour
);

    localparam MSEC_LSB = 0;
    localparam MSEC_MSB = 6;
    localparam SEC_LSB  = 7;
    localparam SEC_MSB  = 12;
    localparam MIN_LSB  = 13;
    localparam MIN_MSB  = 18;
    localparam HOUR_LSB = 19;
    localparam HOUR_MSB = 23;

    wire w_tick_100hz;
    wire w_sec_tick;
    wire w_min_tick;
    wire w_hour_tick;
    wire [23:0] w_live_time;

    assign o_sec_tick  = w_sec_tick;
    assign o_min_tick  = w_min_tick;
    assign o_hour_tick = w_hour_tick;

    // 실시간 시계값을 외부로 내보내는 24비트 버스
    // [6:0]=msec, [12:7]=sec, [18:13]=min, [23:19]=hour 순서로 묶음.
    assign w_live_time       = {hour, min, sec, msec};
    assign o_timepiece_vault = w_live_time;

    // time_set_module 붙이기 전 단계에서는 설정 버스를 현재 시간값과 동일하게 둠.
    // 이후 time_set_module을 연결하면 이 자리에 편집 결과 버스가 들어오게 됨.
    assign o_set_time = o_timepiece_vault;

    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .rst(rst),
        .o_tick_100hz(w_tick_100hz)
    );

    tick_counter #(
        .TIMES(MSEC_TIMES),
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .i_set_mode(i_set_mode),
        .i_time(o_set_time[MSEC_MSB:MSEC_LSB]),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );

    tick_counter #(
        .TIMES(SEC_TIMES),
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_sec_tick),
        .i_set_mode(i_set_mode),
        .i_time(o_set_time[SEC_MSB:SEC_LSB]),
        .o_time(sec),
        .o_tick(w_min_tick)
    );

    tick_counter #(
        .TIMES(MIN_TIMES),
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_min_tick),
        .i_set_mode(i_set_mode),
        .i_time(o_set_time[MIN_MSB:MIN_LSB]),
        .o_time(min),
        .o_tick(w_hour_tick)
    );

    tick_counter #(
        .TIMES(HOUR_TIMES),
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_hour_tick),
        .i_set_mode(i_set_mode),
        .i_time(o_set_time[HOUR_MSB:HOUR_LSB]),
        .o_time(hour),
        .o_tick()
    );
endmodule

module tick_counter #(
    parameter integer TIMES = 100,
    parameter integer BIT_WIDTH = 7
) (
    input clk,
    input rst,
    input i_tick,
    input i_set_mode,
    input [BIT_WIDTH-1:0] i_time,
    output [BIT_WIDTH-1:0] o_time,
    output reg o_tick
);

    reg [BIT_WIDTH-1:0] time_reg;
    reg [BIT_WIDTH-1:0] time_next;

    assign o_time = time_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin  // reset이면 시간 초기화
            time_reg <= 0;
        end else begin  // 평소에는 시간 업데이트
            time_reg <= time_next;
        end
    end

    always @(*) begin
        time_next = time_reg;
        o_tick = 1'b0;

        if (i_set_mode) begin  // set 모드이면 입력된 시간으로 설정
            time_next = i_time;
        end else if (i_tick) begin  // set 모드 아닐 때는 시간 카운트
            if (time_reg == TIMES - 1) begin  // 최대 시간에 도달하면 시간 초기화하고 tick 발생
                time_next = 0;
                o_tick = 1'b1;
            end else begin  // 최대 시간에 도달하지 않으면 시간 증가
                time_next = time_reg + 1'b1;
            end
        end
    end

endmodule

module tick_gen_100hz #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer TICK_HZ     = 100
) (
    input clk,
    input rst,
    output reg o_tick_100hz
);

    // 입력 클럭에서 몇 번 세면 100Hz tick 1번이 나와야 하는지 계산
    localparam integer TICK_COUNT = CLK_FREQ_HZ / TICK_HZ;

    // TICK_COUNT까지 세기 위한 카운터 레지스터
    reg [$clog2(TICK_COUNT)-1:0] count_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin  // reset이면 카운터와 tick 출력 초기화
            count_reg <= 0;
            o_tick_100hz <= 1'b0;
        end else if (count_reg == TICK_COUNT - 1) begin  // 목표 count에 도달하면
            count_reg <= 0;  // 카운터를 다시 0부터 세기 시작하고
            o_tick_100hz <= 1'b1;  // 이 클럭에서만 tick 1번 발생시키기
        end else begin  // 아직 목표 count에 도달하지 않았으면
            count_reg <= count_reg + 1'b1;  // 카운터 1 증가
            o_tick_100hz <= 1'b0;  // tick은 평소에 0 유지
        end
    end

endmodule
