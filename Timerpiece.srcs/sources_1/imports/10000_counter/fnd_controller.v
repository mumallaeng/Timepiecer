`timescale 1ns / 1ps

module fnd_controller #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer SCAN_HZ = 1000,
    parameter integer MSEC_WIDTH = 7,
    parameter integer SEC_WIDTH = 6,
    parameter integer MIN_WIDTH = 6,
    parameter integer HOUR_WIDTH = 5,
    parameter integer DISPLAY_DIGIT_COUNT = 4,
    parameter integer SCAN_SLOT_COUNT = 8,
    parameter integer MSEC_TOGGLE_COUNT = 100
) (
    input clk,
    input rst,
    input sw,
    input [MSEC_WIDTH-1:0] msec,
    input [SEC_WIDTH-1:0] sec,
    input [MIN_WIDTH-1:0] min,
    input [HOUR_WIDTH-1:0] hour,
    output [DISPLAY_DIGIT_COUNT-1:0] fnd_com,
    output [7:0] fnd_data
);

    localparam integer DIGIT_SEL_WIDTH = (SCAN_SLOT_COUNT <= 1) ? 1 : $clog2(
        SCAN_SLOT_COUNT
    );
    localparam integer DISPLAY_SEL_WIDTH = (DISPLAY_DIGIT_COUNT <= 1) ? 1 : $clog2(
        DISPLAY_DIGIT_COUNT
    );
    localparam [3:0] UNUSED_SLOT_CODE = 4'hf;
    localparam [2:0] DOT_SLOT_PREFIX = 3'b111;

    wire [3:0] w_out_mux;
    wire [3:0] w_out_mux_msec_sec;
    wire [3:0] w_out_mux_min_hour;

    wire [3:0] w_msec_digit_1;
    wire [3:0] w_msec_digit_10;
    wire [3:0] w_sec_digit_1, w_sec_digit_10;
    wire [3:0] w_min_digit_1, w_min_digit_10;
    wire [3:0] w_hour_digit_1, w_hour_digit_10;
    wire [DIGIT_SEL_WIDTH-1:0] w_digit_sel;
    wire w_1khz;
    wire w_dot_onff;
    wire [3:0] w_dot_slot_code;

    assign w_dot_slot_code = {DOT_SLOT_PREFIX, w_dot_onff};

    digit_splitter #(
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_DS (
        .digit_in(msec),
        .digit_1 (w_msec_digit_1),
        .digit_10(w_msec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_DS (
        .digit_in(sec),
        .digit_1 (w_sec_digit_1),
        .digit_10(w_sec_digit_10)
    );

    comparator #(
        .BIT_WIDTH(MSEC_WIDTH),
        .THRESHOLD(MSEC_TOGGLE_COUNT / 2)
    ) U_COMP_DOTONOFF (
        .comp_in(msec),
        .dot_onoff(w_dot_onff)
    );

    digit_splitter #(
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_DS (
        .digit_in(min),
        .digit_1 (w_min_digit_1),
        .digit_10(w_min_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_DS (
        .digit_in(hour),
        .digit_1 (w_hour_digit_1),
        .digit_10(w_hour_digit_10)
    );

    mux_8x1 U_MUX_MSEC_SEC (
        .in0(w_msec_digit_1),
        .in1(w_msec_digit_10),
        .in2(w_sec_digit_1),
        .in3(w_sec_digit_10),
        .in4(UNUSED_SLOT_CODE),
        .in5(UNUSED_SLOT_CODE),
        .in6(w_dot_slot_code),
        .in7(UNUSED_SLOT_CODE),
        .sel(w_digit_sel),
        .out_mux(w_out_mux_msec_sec)
    );

    mux_8x1 U_MUX_MIN_HOUR (
        .in0(w_min_digit_1),
        .in1(w_min_digit_10),
        .in2(w_hour_digit_1),
        .in3(w_hour_digit_10),
        .in4(UNUSED_SLOT_CODE),
        .in5(UNUSED_SLOT_CODE),
        .in6(w_dot_slot_code),
        .in7(UNUSED_SLOT_CODE),
        .sel(w_digit_sel),
        .out_mux(w_out_mux_min_hour)
    );

    mux_2x1 U_MUX_2X1 (
        .in0(w_out_mux_msec_sec),
        .in1(w_out_mux_min_hour),
        .sel(sw),
        .out_mux(w_out_mux)
    );

    bcd U_BCD (
        .bin(w_out_mux),
        .bcd_data(fnd_data)
    );

    clk_div_1khz #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .SCAN_HZ(SCAN_HZ)
    ) U_CLK_DIV_1KHZ (
        .clk(clk),
        .rst(rst),
        .o_1khz(w_1khz)
    );

    counter_8 #(
        .SLOT_COUNT(SCAN_SLOT_COUNT)
    ) U_COUNTER_8 (
        .clk(w_1khz),
        .rst(rst),
        .digit_sel(w_digit_sel)
    );

    decoder_2x4 #(
        .DIGIT_COUNT(DISPLAY_DIGIT_COUNT)
    ) U_DECODER_2x4 (
        .decoder_in(w_digit_sel[DISPLAY_SEL_WIDTH-1:0]),
        .fnd_com(fnd_com)
    );
endmodule

module comparator #(
    parameter integer BIT_WIDTH = 7,
    parameter integer THRESHOLD = 50
) (
    input [BIT_WIDTH-1:0] comp_in,
    output dot_onoff
);
    assign dot_onoff = (comp_in >= THRESHOLD);
endmodule

module mux_2x1 (
    input [3:0] in0,
    input [3:0] in1,
    input sel,
    output [3:0] out_mux
);

    assign out_mux = sel ? in1 : in0;

endmodule

module clk_div_1khz #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer SCAN_HZ = 1000
) (
    input  clk,
    input  rst,
    output o_1khz
);

    localparam integer HALF_PERIOD_COUNT = CLK_FREQ_HZ / (SCAN_HZ * 2);
    localparam integer COUNTER_WIDTH = (HALF_PERIOD_COUNT <= 1) ? 1 : $clog2(
        HALF_PERIOD_COUNT
    );

    reg [COUNTER_WIDTH-1:0] counter_reg;
    reg o_1khz_reg;

    assign o_1khz = o_1khz_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= {COUNTER_WIDTH{1'b0}};
            o_1khz_reg  <= 1'b0;
        end else begin
            if (counter_reg == HALF_PERIOD_COUNT - 1) begin
                counter_reg <= {COUNTER_WIDTH{1'b0}};
                o_1khz_reg  <= ~o_1khz_reg;
            end else begin
                counter_reg <= counter_reg + 1'b1;
            end
        end
    end

endmodule

module counter_8 #(
    parameter integer SLOT_COUNT = 8,
    parameter integer SEL_WIDTH = (SLOT_COUNT <= 1) ? 1 : $clog2(SLOT_COUNT)
) (
    input clk,
    input rst,
    output [SEL_WIDTH-1:0] digit_sel
);
    reg [SEL_WIDTH-1:0] counter_reg;

    assign digit_sel = counter_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= {SEL_WIDTH{1'b0}};
        end else begin
            if (counter_reg == SLOT_COUNT - 1) begin
                counter_reg <= {SEL_WIDTH{1'b0}};
            end else begin
                counter_reg <= counter_reg + 1'b1;
            end
        end
    end

endmodule

module decoder_2x4 #(
    parameter integer DIGIT_COUNT = 4,
    parameter integer SEL_WIDTH = (DIGIT_COUNT <= 1) ? 1 : $clog2(DIGIT_COUNT)
) (
    input [SEL_WIDTH-1:0] decoder_in,
    output [DIGIT_COUNT-1:0] fnd_com
);
    wire [DIGIT_COUNT-1:0] one_hot_sel;

    assign one_hot_sel = {{(DIGIT_COUNT - 1){1'b0}}, 1'b1} << decoder_in;
    assign fnd_com = ~one_hot_sel;
endmodule

module digit_splitter #(
    parameter integer BIT_WIDTH = 7
) (
    input [BIT_WIDTH-1:0] digit_in,
    output [3:0] digit_1,
    output [3:0] digit_10
);

    assign digit_1  = digit_in % 10;
    assign digit_10 = (digit_in / 10) % 10;

endmodule

module mux_8x1 (
    input  [3:0] in0,
    input  [3:0] in1,
    input  [3:0] in2,
    input  [3:0] in3,
    input  [3:0] in4,
    input  [3:0] in5,
    input  [3:0] in6,
    input  [3:0] in7,
    input  [2:0] sel,
    output [3:0] out_mux
);
    reg [3:0] out_reg;

    assign out_mux = out_reg;

    always @(*) begin
        case (sel)
            3'b000:  out_reg = in0;
            3'b001:  out_reg = in1;
            3'b010:  out_reg = in2;
            3'b011:  out_reg = in3;
            3'b100:  out_reg = in4;
            3'b101:  out_reg = in5;
            3'b110:  out_reg = in6;
            3'b111:  out_reg = in7;
            default: out_reg = 4'b0000;
        endcase
    end

endmodule

module bcd (
    input [3:0] bin,
    output reg [7:0] bcd_data
);

    always @(*) begin
        case (bin)
            4'b0000: bcd_data = 8'hC0;
            4'b0001: bcd_data = 8'hF9;
            4'b0010: bcd_data = 8'hA4;
            4'b0011: bcd_data = 8'hB0;
            4'b0100: bcd_data = 8'h99;
            4'b0101: bcd_data = 8'h92;
            4'b0110: bcd_data = 8'h82;
            4'b0111: bcd_data = 8'hF8;
            4'b1000: bcd_data = 8'h80;
            4'b1001: bcd_data = 8'h90;
            4'b1010: bcd_data = 8'h88;
            4'b1011: bcd_data = 8'h83;
            4'b1100: bcd_data = 8'hC6;
            4'b1101: bcd_data = 8'hA1;
            4'b1110: bcd_data = 8'h86;
            4'b1111: bcd_data = 8'h8E;
            default: bcd_data = 8'hFF;
        endcase
    end

endmodule
