`include "csa.v"

module wallace_33 (
    input  [131:0] in  [32:0],
    output [127:0] out [1 :0]
);
    // level 1
    // 33p split by (444444 333) -> 18p
    // totle: 9
    wire [132:0] s_row1  [8:0];
    wire [132:0] c_row1  [8:0];
    wire [132:0] co_row1 [8:0];
        // 1.0
        assign c_row1[0][0] = 1'b0;
        half_adder      comp1_0_0 (.a(in[0][0]), .b(in[1][0]),                                              .s(s_row1[0][0]), .cout(c_row1[0][1]));
        assign s_row1[0][1] = in[0][1];     assign c_row1[0][2] = 1'b0;
        compressor_3to2 comp1_0_2 (.a(in[0][2]), .b(in[1][2]), .cin(in[2][2]),                              .s(s_row1[0][2]), .cout(c_row1[0][3]));
        half_adder      comp1_0_3 (.a(in[0][3]), .b(in[1][3]),                                              .s(s_row1[0][3]), .cout(c_row1[0][4]));
        compressor_4to2 comp1_0_4 (.a(in[0][4]), .b(in[1][4]), .c(in[2][4]), .d(in[3][4]),      .cin(1'b0), .s(s_row1[0][4]),   .co(c_row1[0][5]), .cout(co_row1[0][5]));
        compressor_4to2 comp1_0_5 (.a(in[0][5]), .b(in[1][5]), .c(in[2][5]), .d(1'b0), .cin(co_row1[0][5]), .s(s_row1[0][5]),   .co(c_row1[0][6]), .cout(co_row1[0][6]));
        for(genvar i = 6; i < 132; i++) begin   // booth 有扩展符号
            compressor_4to2 comp1_0_ (.a(in[0][i]), .b(in[1][i]), .c(in[2][i]), .d(in[3][i]), .cin(co_row1[0][i]), .s(s_row1[0][i]), .co(c_row1[0][i+1]), .cout(co_row1[0][i+1]));
        end
        // 1.1 - 1.5
        for (genvar i = 1; i < 6; i++) begin
            localparam start    = 8*i-2   ;
            localparam index0   = 4*i;
            localparam index1   = 4*i+1;
            localparam index2   = 4*i+2;
            localparam index3   = 4*i+3;

            assign c_row1[i][start] = 1'b0;
            assign s_row1[i][start] = in[index0][start];        assign c_row1[i][start+1] = 1'b0;
            assign s_row1[i][start+1] = 1'b0;                   assign c_row1[i][start+2] = 1'b0;
            half_adder      comp1_i_2 (.a(in[index0][start+2]), .b(in[index1][start+2]), .s(s_row1[i][start+2]), .cout(c_row1[i][start+3]));
            assign s_row1[i][start+3] = in[index0][start+3];    assign c_row1[i][start+4] = 1'b0;
            compressor_3to2 comp1_i_4 (.a(in[index0][start+4]), .b(in[index1][start+4]), .cin(in[index2][start+4]), .s(s_row1[i][start+4]), .cout(c_row1[i][start+5]));
            half_adder      comp1_i_5 (.a(in[index0][start+5]), .b(in[index1][start+5]), .s(s_row1[i][start+5]), .cout(c_row1[i][start+6]));
            for (genvar j = start+6; j < 132; j++) begin
                compressor_4to2 comp1_i_ (.a(in[index0][j]), .b(in[index1][j]), .c(in[index2][j]), .d(in[index3][j]), .cin(co_row1[i][j]), .s(s_row1[i][j]), .co(c_row1[i][j+1]), .cout(co_row1[i][j+1]));
            end
        end
        // 1.6 - 1.8
        for (genvar i = 0; i < 3; i++) begin
            localparam start    = 46+6*i;
            localparam index0   = 24+3*i;
            localparam index1   = index0+1;
            localparam index2   = index0+2;

            assign c_row1[i+6][start] = 1'b0;
            assign s_row1[i+6][start] = in[index0][start];        assign c_row1[i+6][start+1] = 1'b0;
            assign s_row1[i+6][start+1] = 1'b0;                   assign c_row1[i+6][start+2] = 1'b0;
            half_adder      comp1_i3_2 (.a(in[index0][start+2]), .b(in[index1][start+2]), .s(s_row1[i+6][start+2]), .cout(c_row1[i+6][start+3]));
            assign s_row1[i+6][start+3] = in[index0][start+3];    assign c_row1[i+6][start+4] = 1'b0;
            compressor_3to2 comp1_i3_4 (.a(in[index0][start+4]), .b(in[index1][start+4]), .cin(in[index2][start+4]), .s(s_row1[i+6][start+4]), .cout(c_row1[i+6][start+5]));
            half_adder      comp1_i3_5 (.a(in[index0][start+5]), .b(in[index1][start+5]), .s(s_row1[i+6][start+5]), .cout(c_row1[i+6][start+6]));
            for (genvar j = start+6; j < 132; j++) begin
                compressor_3to2 comp1_i3_ (.a(in[index0][j]), .b(in[index1][j]), .cin(in[index2][j]), .s(s_row1[i+6][j]), .cout(c_row1[i+6][j+1]));
            end
        end

    // level 2
    // 18p split by (333333) -> 12p
    // totle: 6
    wire [132:0] s_row2  [5:0];
    wire [132:0] c_row2  [5:0];
        // 2.0
        for (genvar i = 0; i < 6; i++) begin
            half_adder      comp2_0_ (.a(s_row1[0][i]), .b(c_row1[0][i]), .s(s_row2[0][i]), .cout(c_row2[0][i+1]));
        end
        for (genvar i = 6; i < 132; i++) begin
            compressor_3to2 comp2_0_ (.a(s_row1[0][i]), .b(c_row1[0][i]), .cin(s_row1[1][i]), .s(s_row2[0][i]), .cout(c_row2[0][i+1]));
        end
        // 2.1
        for (genvar i = 6; i < 14; i++) begin
            assign s_row2[1][i] = c_row1[1][i];
        end
        for (genvar i = 14; i < 132; i++) begin
            compressor_3to2 comp2_1_ (.a(c_row1[1][i]), .b(s_row1[2][i]), .cin(c_row1[2][i]), .s(s_row2[1][i]), .cout(c_row2[1][i+1]));
        end
        // 2.2
        for (genvar i = 22; i < 30; i++) begin
            half_adder      comp2_2_ (.a(s_row1[3][i]), .b(c_row1[3][i]), .s(s_row2[2][i]), .cout(c_row2[2][i+1]));
        end
        for (genvar i = 30; i < 132; i++) begin
            compressor_3to2 comp2_2_ (.a(s_row1[3][i]), .b(c_row1[3][i]), .cin(s_row1[4][i]), .s(s_row2[2][i]), .cout(c_row2[2][i+1]));
        end
        // 2.3
        for (genvar i = 30; i < 38; i++) begin
            assign s_row2[3][i] = c_row1[4][i];
        end
        for (genvar i = 38; i < 132; i++) begin
            compressor_3to2 comp2_3_ (.a(c_row1[4][i]), .b(s_row1[5][i]), .cin(c_row1[5][i]), .s(s_row2[3][i]), .cout(c_row2[3][i+1]));
        end
        // 2.4
        for (genvar i = 46; i < 52; i++) begin
            half_adder      comp2_4_ (.a(s_row1[6][i]), .b(c_row1[6][i]), .s(s_row2[4][i]), .cout(c_row2[4][i+1]));
        end
        for (genvar i = 52; i < 132; i++) begin
            compressor_3to2 comp2_4_ (.a(s_row1[6][i]), .b(c_row1[6][i]), .cin(s_row1[7][i]), .s(s_row2[4][i]), .cout(c_row2[4][i+1]));
        end
        // 2.5
        for (genvar i = 52; i < 58; i++) begin
            assign s_row2[5][i] = c_row1[7][i];
        end
        for (genvar i = 58; i < 132; i++) begin
            compressor_3to2 comp2_5_ (.a(c_row1[7][i]), .b(s_row1[8][i]), .cin(c_row1[8][i]), .s(s_row2[5][i]), .cout(c_row2[5][i+1]));
        end

    // level 3
    // 12p split by (3333) -> 8p
    // totle: 4
    wire [132:0] s_row3  [3:0];
    wire [132:0] c_row3  [3:0];
        for (genvar i = 0; i < 6; i++) begin
            half_adder      comp3_0_ (.a(s_row2[0][i]), .b(c_row2[0][i]), .s(s_row3[0][i]), .cout(c_row3[0][i+1]));
        end
        for (genvar i = 6; i < 132; i++) begin
            compressor_3to2 comp3_0_ (.a(s_row2[0][i]), .b(c_row2[0][i]), .cin(s_row2[1][i]), .s(s_row3[0][i]), .cout(c_row3[0][i+1]));
        end
        // 3.1
        for (genvar i = 6; i < 22; i++) begin
            assign s_row3[1][i] = c_row2[1][i];
        end
        for (genvar i = 22; i < 132; i++) begin
            compressor_3to2 comp3_1_ (.a(c_row2[1][i]), .b(s_row2[2][i]), .cin(c_row2[2][i]), .s(s_row3[1][i]), .cout(c_row3[1][i+1]));
        end
        // 3.2
        for (genvar i = 30; i < 46; i++) begin
            half_adder      comp3_2_ (.a(s_row2[3][i]), .b(c_row2[3][i]), .s(s_row3[2][i]), .cout(c_row3[2][i+1]));
        end
        for (genvar i = 46; i < 132; i++) begin
            compressor_3to2 comp3_2_ (.a(s_row2[3][i]), .b(c_row2[3][i]), .cin(s_row2[4][i]), .s(s_row3[2][i]), .cout(c_row3[2][i+1]));
        end
        // 3.3
        for (genvar i = 46; i < 52; i++) begin
            assign s_row3[3][i] = c_row2[4][i];
        end
        for (genvar i = 52; i < 132; i++) begin
            compressor_3to2 comp3_3_ (.a(c_row2[4][i]), .b(s_row2[5][i]), .cin(c_row2[5][i]), .s(s_row3[3][i]), .cout(c_row3[3][i+1]));
        end

    // level 4
    // 8p split by (44) -> 4p
    // totle: 2
    wire [132:0] s_row4  [1:0];
    wire [132:0] c_row4  [1:0];
    wire [132:0] co_row4  [1:0];
        // 4.0
        for (genvar i = 0; i < 6; i++) begin
            half_adder      comp4_0_ (.a(s_row3[0][i]), .b(c_row3[0][i]), .s(s_row4[0][i]), .cout(c_row4[0][i+1]));
        end
        for (genvar i = 6; i < 132; i++) begin
            compressor_4to2 comp4_0_ (.a(s_row3[0][i]), .b(c_row3[0][i]), .c(s_row3[1][i]), .d(c_row3[1][i]), .cin(co_row4[0][i]), .s(s_row4[0][i]), .co(c_row4[0][i+1]), .cout(co_row4[0][i+1]));
        end
        // 4.1
        for (genvar i = 30; i < 46; i++) begin
            half_adder      comp4_1_ (.a(s_row3[2][i]), .b(c_row3[2][i]), .s(s_row4[1][i]), .cout(c_row4[1][i+1]));
        end
        for (genvar i = 46; i < 132; i++) begin
            compressor_4to2 comp4_0_ (.a(s_row3[2][i]), .b(c_row3[2][i]), .c(s_row3[3][i]), .d(c_row3[3][i]), .cin(co_row4[1][i]), .s(s_row4[1][i]), .co(c_row4[1][i+1]), .cout(co_row4[1][i+1]));
        end

    // level 5
    // 4p -> 2p
    // total: 1
    wire [132:0] s_row5;
    wire [132:0] c_row5;
    wire [132:0] co_row5;
        for (genvar i = 0; i < 30; i++) begin
            half_adder      comp5_ (.a(s_row4[0][i]), .b(c_row4[0][i]), .s(s_row5[i]), .cout(c_row5[i+1]));
        end
        for (genvar i = 30; i < 132; i++) begin
            compressor_4to2 comp5_ (.a(s_row4[0][i]), .b(c_row4[0][i]), .c(s_row4[1][i]), .d(c_row4[1][i]), .cin(co_row5[i]), .s(s_row5[i]), .co(c_row5[i+1]), .cout(co_row5[i+1]));
        end

    // result
    assign out[0] = s_row5[127:0];
    assign out[1] = c_row5[127:0];
endmodule;