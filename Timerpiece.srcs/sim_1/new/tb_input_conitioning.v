`timescale 1ns / 1ps

module tb_input_conitioning ();

    reg  clk;
    reg  rst;
    reg  btnU;
    reg  btnD;
    reg  btnL;
    reg  btnR;
    reg  sw0;
    reg  sw15;
    wire o_btn_U;
    wire o_btn_D;
    wire o_btn_L;
    wire o_btn_R;
    wire o_btn_U_hold;
    wire o_btn_D_hold;
    wire o_btn_L_hold;
    wire o_btn_R_hold;
    wire o_sw0;
    wire o_sw15;

    input_conditioning #(
        .CLK_FREQ_HZ(100_000_000),  // 100MHz
        .BD_HZ      (100_000),      // 100k
        .HOLD_TIME  (100_000)       //00)   // 1.5초
    ) U0 (
        .clk(clk),
        .rst(rst),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .sw0(sw0),
        .sw15(sw15),
        .o_btn_U(o_btn_U),
        .o_btn_D(o_btn_D),
        .o_btn_L(o_btn_L),
        .o_btn_R(o_btn_R),
        .o_btn_U_hold(o_btn_U_hold),
        .o_btn_D_hold(o_btn_D_hold),
        .o_btn_L_hold(o_btn_L_hold),
        .o_btn_R_hold(o_btn_R_hold),
        .o_sw0(o_sw0),
        .o_sw15(o_sw15)
    );

    always #5 clk = ~clk;

    initial begin
        clk  = 0;
        rst  = 1;
        btnU = 0;
        btnD = 0;
        btnL = 0;
        btnR = 0;
        sw0  = 0;
        sw15 = 0;
        repeat (3) @(negedge clk);
        rst = 0;
        #10;
        btnU = 1;
        btnD = 1;
        btnL = 1;
        btnR = 1;

        #(5 * 1000000);
        btnU = 0;
        btnD = 0;
        btnL = 0;
        btnR = 0;

        repeat (3) @(negedge clk);

        sw0  = 1;
        sw15 = 1;
        repeat (1000) @(negedge clk);
        sw0  = 0;
        sw15 = 0;
        #20;
        $stop;
    end





endmodule
