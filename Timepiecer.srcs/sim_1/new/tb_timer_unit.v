`timescale 1ns / 1ps

module tb_timer_unit ();

    reg clk;
    reg rst;
    reg i_btnD;
    reg i_btnL;
    reg i_btnU;
    reg i_sw0;
    wire [6:0] msec;
    wire [5:0] sec;
    wire [5:0] min;
    wire [4:0] hour;

    wire w_btnD, w_btnL, w_btnU, w_sw0;

    parameter PUSH = 100_000;
    parameter DELAY = 1_000_000_00;
    parameter WAIT = 1_000_00;

    input_conditioning #(
        .CLK_FREQ_HZ(100_000_000),  // 100MHz
        .BD_HZ(100_000),
        .HOLD_TIME(100_000)  // 1.5초
    ) U_INPUT_CON (
        .clk(clk),
        .rst(rst),
        .btnU(i_btnU),
        .btnD(i_btnD),
        .btnL(i_btnL),
        .sw0(i_sw0),
        .o_btnU(w_btnU),
        .o_btnD(w_btnD),
        .o_btnL(w_btnL),
        .o_sw0(w_sw0)
    );

    timer_unit #(
        .MAIN_CLK_100MHZ(100_000_000),
        .BASIC_TIME     (100_000_000),
        .MSEC_WIDTH     (7),
        .SEC_WIDTH      (6),
        .MIN_WIDTH      (6),
        .HOUR_WIDTH     (5),
        .MSEC_TIMES     (100),
        .SEC_TIMES      (60),
        .MIN_TIMES      (60),
        .HOUR_TIMES     (24)
    ) U_TIMER (
        .clk(clk),
        .rst(rst),
        .i_btnD(w_btnD),
        .i_btnL(w_btnL),
        .i_btnU(w_btnU),
        .i_sw0(i_sw0),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        i_btnU = 0;
        i_btnD = 0;
        i_btnL = 0;
        i_sw0 = 0;
        repeat (3) @(negedge clk);
        rst = 0;
        i_sw0 = 1;

        //RUN
        i_btnD = 1;
        #PUSH;
        i_btnD = 0;
        #DELAY;

        //STOP
        i_btnD = 1;
        #PUSH;
        i_btnD = 0;
        #WAIT;

        //DOWN MODE ON
        i_btnU = 1;
        #PUSH;
        i_btnU = 0;

        //DOWN RUN
        i_btnD = 1;
        #PUSH;
        i_btnD = 0;
        #DELAY;

        //STOP
        i_btnD = 1;
        #PUSH;
        i_btnD = 0;
        #WAIT;

        //CLEAR
        i_btnL = 1;
        #PUSH;
        i_btnL = 0;
        #WAIT;

        //UP MODE ON
        i_btnU = 1;
        #PUSH;
        i_btnU = 0;

        //RUN
        i_btnD = 1;
        #PUSH;
        i_btnD = 0;
        #(DELAY / 2);

        //RUN 도중 클리어 (RUN 유지 확인)
        i_btnL = 1;
        #PUSH;
        i_btnL = 0;
        #(DELAY / 2);

        //UP MODE ON (RUN 유지 확인)
        i_btnU = 1;
        #PUSH;
        i_btnU = 0;
        #(DELAY / 2);


        $finish;
        $stop;



    end





endmodule
