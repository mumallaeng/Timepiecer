`timescale 1ns / 1ps

module timepiece_fsm (
    input clk,
    input rst,
    input i_btnL,
    input i_btnU,
    input i_btnD,
    input i_btnU_hold,
    input i_btnD_hold,
    input i_btnR_hold,
    input i_sw0,
    output reg o_set_mode,
    output reg [1:0] o_set_index,
    output reg o_index_shift,
    output reg o_increment,
    output reg o_increment_tens,
    output reg o_decrement,
    output reg o_decrement_tens
);

    localparam [2:0] VIEW            = 3'b000;
    localparam [2:0] SET             = 3'b001;
    localparam [2:0] INDEX_SHIFT     = 3'b010;
    localparam [2:0] INCREMENT_ONES  = 3'b011;
    localparam [2:0] INCREMENT_TENS  = 3'b100;
    localparam [2:0] DECREMENT_ONES  = 3'b101;
    localparam [2:0] DECREMENT_TENS  = 3'b110;

    localparam [1:0] UNIT_HOUR = 2'd0;
    localparam [1:0] UNIT_MIN  = 2'd1;
    localparam [1:0] UNIT_SEC  = 2'd2;
    localparam [1:0] UNIT_MSEC = 2'd3;

    reg [2:0] current_state;
    reg [2:0] next_state;
    reg [1:0] set_index_reg;
    reg [1:0] set_index_next;

    function [1:0] next_unit;
        input [1:0] current_unit;
    begin
        case (current_unit)
            UNIT_HOUR: next_unit = UNIT_MIN;
            UNIT_MIN:  next_unit = UNIT_SEC;
            UNIT_SEC:  next_unit = UNIT_MSEC;
            default:   next_unit = UNIT_HOUR;
        endcase
    end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin  // reset이면 기본 표시 상태로 초기화
            current_state <= VIEW;
            set_index_reg <= UNIT_HOUR;
        end else begin  // 평소에는 다음 상태로 전이
            current_state <= next_state;
            set_index_reg <= set_index_next;
        end
    end

    always @(*) begin
        next_state = current_state;
        set_index_next = set_index_reg;

        // sw0가 Timer를 선택하면 Timepiece 설정 상태는 유지하지 않고 VIEW로 복귀
        if (i_sw0) begin
            next_state = VIEW;
            set_index_next = UNIT_HOUR;
        end else begin
            case (current_state)
                VIEW: begin
                    if (i_btnR_hold) begin
                        next_state = SET;                                   // Timepiece가 선택된 상태에서 BtnR hold가 들어오면 설정 모드 진입
                        set_index_next = UNIT_HOUR;                         // 설정 시작은 hour부터 시작
                    end
                end

                SET: begin
                    if (i_btnR_hold) begin
                        next_state = VIEW;                                  // 설정 상태에서 BtnR hold가 들어오면 설정 종료
                        set_index_next = UNIT_HOUR;
                    end else if (i_btnL) begin
                        next_state = INDEX_SHIFT;                           // BtnL은 편집 단위를 다음 단위로 이동
                        set_index_next = next_unit(set_index_reg);
                    end
                    else if (i_btnU) next_state = INCREMENT_ONES;           // BtnU short는 +1
                    else if (i_btnU_hold) next_state = INCREMENT_TENS;      //      hold는 +10 상태로 진입
                    else if (i_btnD) next_state = DECREMENT_ONES;           // BtnD short는 -1
                    else if (i_btnD_hold) next_state = DECREMENT_TENS;      //      hold는 -10 상태로 진입
                end

                // 아래 처리 상태들은 1클럭 동안만 제어 펄스를 내고 다시 SET으로 복귀
                INDEX_SHIFT: next_state = SET;
                INCREMENT_ONES: next_state = SET;
                INCREMENT_TENS: next_state = SET;
                DECREMENT_ONES: next_state = SET;
                DECREMENT_TENS: next_state = SET;

                default: next_state = VIEW;
            endcase
        end
    end

    always @(*) begin
        // 기본값: Timepiece는 VIEW에서 set mode off, 나머지 제어신호는 0
        o_set_mode = 1'b0;
        // 현재 편집 중인 단위를 외부에 그대로 내보냄
        o_set_index = set_index_reg;
        o_index_shift = 1'b0;
        o_increment = 1'b0;
        o_increment_tens = 1'b0;
        o_decrement = 1'b0;
        o_decrement_tens = 1'b0;

        case (current_state)
            VIEW: begin
                o_set_mode = 1'b0;
            end

            SET: begin
                o_set_mode = 1'b1;
            end

            INDEX_SHIFT: begin
                o_set_mode = 1'b1;
                o_index_shift = 1'b1;
            end

            INCREMENT_ONES: begin
                o_set_mode = 1'b1;
                o_increment = 1'b1;
            end

            INCREMENT_TENS: begin
                o_set_mode = 1'b1;
                o_increment_tens = 1'b1;
            end

            DECREMENT_ONES: begin
                o_set_mode = 1'b1;
                o_decrement = 1'b1;
            end

            DECREMENT_TENS: begin
                o_set_mode = 1'b1;
                o_decrement_tens = 1'b1;
            end
        endcase
    end

endmodule
