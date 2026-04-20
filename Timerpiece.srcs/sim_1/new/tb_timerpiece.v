`timescale 1ns / 1ps

module tb_timerpiece ();

    // top 입력 자극용 신호
    reg clk;
    reg rst;
    reg btnR;
    reg btnL;
    reg btnU;
    reg btnD;
    reg sw0;
    reg sw15;

    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [1:0] led;

    // DUT: Timer + Timepiece + Display 경로를 최종 연결한 상위 모듈
    timerpiece #(
        .CLK_FREQ_HZ(1000),
        .BD_HZ(100),
        .HOLD_TIME_BTN_R(200),
        .HOLD_TIME_BTN_UD(150),
        .HOLD_TIME_BTN_L(150),
        .BASIC_TIME(100),
        .SCAN_HZ(100)
    ) UUT (
        .clk(clk),
        .rst(rst),
        .btnR(btnR),
        .btnL(btnL),
        .btnU(btnU),
        .btnD(btnD),
        .sw0(sw0),
        .sw15(sw15),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led)
    );

    always #5 clk = ~clk;

    // 단순 clock 지연용 task
    task wait_cycles;
        input integer cycles;
        integer idx;
    begin
        for (idx = 0; idx < cycles; idx = idx + 1) begin
            @(negedge clk);
        end
    end
    endtask

    // Timepiece 내부 100Hz tick 기준으로 기다리기
    task wait_timepiece_ticks;
        input integer steps;
        integer idx;
    begin
        for (idx = 0; idx < steps; idx = idx + 1) begin
            @(posedge UUT.U_TIMEPIECE_DATAPATH.w_tick_100hz);
        end
        @(negedge clk);
    end
    endtask

    // Timer 내부 100Hz tick 기준으로 기다리기
    task wait_timer_ticks;
        input integer steps;
        integer idx;
    begin
        for (idx = 0; idx < steps; idx = idx + 1) begin
            @(posedge UUT.U_TIMER.U_TIMER_DATAPATH.w_tick_100hz);
        end
        @(negedge clk);
    end
    endtask

    // btnR short 입력: debounce를 통과할 만큼 눌렀다가 release 후 short pulse 발생 대기
    task press_btnR_short;
    begin
        btnR = 1'b1;
        wait_cycles(120);
        btnR = 1'b0;
        wait_cycles(120);
    end
    endtask

    // btnR hold 입력: 2초 hold pulse가 발생할 만큼 길게 누름
    task press_btnR_hold;
    begin
        btnR = 1'b1;
        wait_cycles(320);
        btnR = 1'b0;
        wait_cycles(120);
    end
    endtask

    // btnU short 입력
    task press_btnU_short;
    begin
        btnU = 1'b1;
        wait_cycles(120);
        btnU = 1'b0;
        wait_cycles(120);
    end
    endtask

    // btnU hold 입력: +10 동작용
    task press_btnU_hold;
    begin
        btnU = 1'b1;
        wait_cycles(260);
        btnU = 1'b0;
        wait_cycles(120);
    end
    endtask

    // btnD short 입력
    task press_btnD_short;
    begin
        btnD = 1'b1;
        wait_cycles(120);
        btnD = 1'b0;
        wait_cycles(120);
    end
    endtask

    // btnL short 입력
    task press_btnL_short;
    begin
        btnL = 1'b1;
        wait_cycles(120);
        btnL = 1'b0;
        wait_cycles(120);
    end
    endtask

    // 현재 display 경로가 기대값과 같은지 확인
    task expect_display;
        input [4:0] exp_hour;
        input [5:0] exp_min;
        input [5:0] exp_sec;
        input [6:0] exp_msec;
    begin
        @(negedge clk);
        if ({UUT.w_display_hour, UUT.w_display_min, UUT.w_display_sec, UUT.w_display_msec}
            !== {exp_hour, exp_min, exp_sec, exp_msec}) begin
            $display("FAIL tb_timerpiece: display expected %0d:%0d:%0d:%0d, got %0d:%0d:%0d:%0d",
                     exp_hour, exp_min, exp_sec, exp_msec,
                     UUT.w_display_hour, UUT.w_display_min, UUT.w_display_sec, UUT.w_display_msec);
            $fatal;
        end
    end
    endtask

    initial begin
        // 초기값: reset asserted, Timepiece 선택, 24시간제
        clk  = 1'b0;
        rst  = 1'b1;
        btnR = 1'b0;
        btnL = 1'b0;
        btnU = 1'b0;
        btnD = 1'b0;
        sw0  = 1'b0;
        sw15 = 1'b0;

        wait_cycles(5);
        rst = 1'b0;

        // 1) reset 직후 기본 화면은 Timepiece, HH:MM, 24시간제 기준 12:00이어야 함
        expect_display(5'd12, 6'd0, 6'd0, 7'd0);
        if (led !== 2'b00) begin
            $display("FAIL tb_timerpiece: LED reset state mismatch");
            $fatal;
        end

        // 2) Timepiece는 기본적으로 계속 흐르며 display가 이를 따라가야 함
        wait_timepiece_ticks(15);
        expect_display(UUT.w_timepiece_hour, UUT.w_timepiece_min, UUT.w_timepiece_sec, UUT.w_timepiece_msec);

        // 3) Timepiece에서도 set 모드가 아닐 때는 btnR short로 display mode를 토글할 수 있어야 함
        if (UUT.w_display_mode !== 1'b1) begin
            $display("FAIL tb_timerpiece: initial timepiece display mode mismatch");
            $fatal;
        end
        press_btnR_short;
        @(negedge clk);
        if (UUT.w_display_mode !== 1'b0) begin
            $display("FAIL tb_timerpiece: timepiece display mode did not toggle");
            $fatal;
        end
        press_btnR_short;
        @(negedge clk);
        if (UUT.w_display_mode !== 1'b1) begin
            $display("FAIL tb_timerpiece: timepiece display mode restore mismatch");
            $fatal;
        end

        // 4) btnR hold로 set 모드에 진입하고, set 중에도 btnR short로 display mode 토글 가능해야 함
        press_btnR_hold;
        if (!UUT.w_timepiece_set_mode) begin
            $display("FAIL tb_timerpiece: failed to enter timepiece set mode");
            $fatal;
        end

        press_btnR_short;
        @(negedge clk);
        if (UUT.w_display_mode !== 1'b0 || UUT.w_fnd_display_mode !== 1'b0) begin
            $display("FAIL tb_timerpiece: set-mode display mode toggle mismatch");
            $fatal;
        end
        press_btnR_short;
        @(negedge clk);
        if (UUT.w_display_mode !== 1'b1 || UUT.w_fnd_display_mode !== 1'b1) begin
            $display("FAIL tb_timerpiece: set-mode display mode restore mismatch");
            $fatal;
        end

        // 5) set 상태에서 btnU short로 hour를 13까지 편집
        press_btnU_short;  // 12 -> 13 hour

        if (UUT.w_timepiece_set_time[23:19] !== 5'd13) begin
            $display("FAIL tb_timerpiece: set hour edit mismatch");
            $fatal;
        end

        // 6) 12시간제를 켜면 편집 버스와 display hour가 즉시 1로 보여야 함
        sw15 = 1'b1;
        @(negedge clk);
        if (UUT.w_timepiece_set_time[23:19] !== 5'd1) begin
            $display("FAIL tb_timerpiece: 12-hour set display mismatch");
            $fatal;
        end
        expect_display(5'd1, UUT.w_timepiece_set_time[18:13], UUT.w_timepiece_set_time[12:7], UUT.w_timepiece_set_time[6:0]);
        if (led[1] !== 1'b1) begin
            $display("FAIL tb_timerpiece: 12-hour LED mismatch");
            $fatal;
        end

        // 7) btnR hold로 set 종료하면 편집값이 live time에 1회 반영되어야 함
        press_btnR_hold;
        if (UUT.w_timepiece_set_mode) begin
            $display("FAIL tb_timerpiece: failed to leave timepiece set mode");
            $fatal;
        end

        @(negedge clk);
        if (UUT.w_timepiece_hour !== 5'd13) begin
            $display("FAIL tb_timerpiece: live hour was not updated after set exit");
            $fatal;
        end
        expect_display(5'd1, UUT.w_timepiece_set_time[18:13], UUT.w_timepiece_set_time[12:7], UUT.w_timepiece_set_time[6:0]);

        // 8) Timer 모드로 전환하면 display가 timer 값을 따라가야 함
        sw0 = 1'b1;
        @(negedge clk);
        if (led[0] !== 1'b1) begin
            $display("FAIL tb_timerpiece: timer LED mismatch");
            $fatal;
        end
        expect_display(5'd0, 6'd0, 6'd0, 7'd0);

        // 9) btnD short로 timer run 시작 후 display가 timer msec을 따라감
        press_btnD_short;
        wait_timer_ticks(12);
        @(negedge clk);
        if (UUT.w_timer_msec < 7'd10) begin
            $display("FAIL tb_timerpiece: timer did not start");
            $fatal;
        end
        expect_display(5'd0, 6'd0, 6'd0, UUT.w_timer_msec);

        // 10) Timer 모드에서 btnR short는 display mode를 토글해야 함
        if (UUT.w_display_mode !== 1'b1) begin
            $display("FAIL tb_timerpiece: initial display mode mismatch");
            $fatal;
        end
        press_btnR_short;
        @(negedge clk);
        if (UUT.w_display_mode !== 1'b0) begin
            $display("FAIL tb_timerpiece: display mode did not toggle");
            $fatal;
        end

        // 11) btnL short는 timer clear로 연결되어 값을 0으로 초기화한 뒤 RUN 상태면 다시 카운트함
        press_btnL_short;
        @(negedge clk);
        if (UUT.w_timer_hour !== 5'd0 || UUT.w_timer_min !== 6'd0 || UUT.w_timer_sec !== 6'd0
            || UUT.w_timer_msec > 7'd20) begin
            $display("FAIL tb_timerpiece: timer clear mismatch");
            $fatal;
        end
        expect_display(5'd0, 6'd0, 6'd0, UUT.w_timer_msec);

        // 12) 다시 Timepiece 모드로 돌아오면 기존 시계값과 12시간 표시가 유지되어야 함
        sw0 = 1'b0;
        @(negedge clk);
        expect_display(UUT.w_timepiece_set_time[23:19],
                       UUT.w_timepiece_set_time[18:13],
                       UUT.w_timepiece_set_time[12:7],
                       UUT.w_timepiece_set_time[6:0]);

        // FND 출력도 X 없이 생성되어야 함
        if (^fnd_com === 1'bx || ^fnd_data === 1'bx) begin
            $display("FAIL tb_timerpiece: FND output contains X");
            $fatal;
        end

        $display("PASS tb_timerpiece");
        $finish;
    end

endmodule
