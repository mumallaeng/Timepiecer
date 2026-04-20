`timescale 1ns / 1ps





module debouncer #(
    parameter CLK_FREQ_HZ = 100_000_000,  // 100MHz
    parameter BD_HZ = 100_000,
    parameter HOLD_TIME = 100_000_000  // 1.5초
) (
    input clk,
    input rst,
    input i_btn,

    output     o_btn,      // 최초 1회 펄스
    output reg o_btn_hold  // 1.5초마다 반복 펄스
);

    parameter COUNT = CLK_FREQ_HZ / BD_HZ;
    reg [$clog2(COUNT)-1:0] count_reg;
    reg clk_100khz;


    //100kHz 주파수 생성
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= 0;
            clk_100khz <= 0;
        end else begin
            count_reg <= count_reg + 1;
            if (count_reg == COUNT - 1) begin
                count_reg  <= 0;
                clk_100khz <= 1;
            end else begin
                clk_100khz <= 0;
            end

        end
    end

    // 디바운싱
    reg [7:0] sync_reg, sync_next;

    always @(posedge clk_100khz, posedge rst) begin
        if (rst) begin
            sync_reg <= 0;
        end else begin
            sync_reg <= sync_next;
        end
    end


    always @(*) begin
        sync_next <= {sync_reg[6:0], i_btn};
    end

    wire btn_db;

    assign btn_db = &sync_reg;


    // 2. edge detect (최초 1회)

    reg btn_db_d;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_db_d <= 0;
        end else begin
            btn_db_d <= btn_db;  // rising edge
        end
    end

    assign o_btn = btn_db & (~btn_db_d);

    // hold counter 
    // 1.5초

    reg [31:0] cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            o_btn_hold <= 0;
        end else begin
            if (btn_db) begin
                if (cnt == HOLD_TIME - 1) begin
                    cnt <= 0;
                    o_btn_hold <= 1;  // 1클럭 펄스
                end else begin
                    cnt <= cnt + 1;
                    o_btn_hold <= 0;
                end
            end else begin
                cnt        <= 0;  // 버튼 떼면 리셋
                o_btn_hold <= 0;
            end
        end
    end

endmodule

