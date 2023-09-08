`include "booth.v"
`include "wallace.v"
`include "add64.v"

module mul128 (
    input  [63:0] operand1, operand2,
    input         sign_x, sign_y,
    output [63:0] result_h, result_l
);
    logic [65 :0] x = sign_x ? {{(2){operand1[63]}}, operand1} : {2'b0, operand1};
    logic [65 :0] y = sign_y ? {{(2){operand1[63]}}, operand2} : {2'b0, operand2};
    logic [131:0] psum [32:0];
    logic [127:0] treeout [1:0];
    wire add_h64_c, add_l64_c;

    booth #(.INXY_W(66)) u_booth(.x(x), .y(y), .psum(psum));

    wallace_33 wallace (.in(psum), .out(treeout));

    add64 add_l64 (.operand1(treeout[0][63:0]), .operand2(treeout[1][63:0]), .c0(1'b0), .result(result_l), .carry(add_l64_c));

    add64 add_h64 (.operand1(treeout[0][127:64]), .operand2(treeout[1][127:64]), .c0(add_l64_c), .result(result_h), .carry(add_h64_c));
endmodule;
