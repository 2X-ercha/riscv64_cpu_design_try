// booth 二位乘变换
// yi+1 yi   yi-1
// 0    0    0    : psum += 0
// 0    0    1    : psum += x
// 0    1    0    : psum += x
// 0    1    1    : psum += x << 1
// 1    0    0    : psum -= x << 1
// 1    0    1    : psum -= x
// 1    1    0    : psum -= x
// 1    1    1    : psum += 0
// 优化1：
// 由于减法实际上是加上取反加一，每次遇到减法就来一个加法器不太合理，故把减法的+1全部整合后最后一起加
// 优化2：
// booth编码产生的partial sum，需要再左移对应的bit，才算生成完毕最终的booth编码。
// 如果每个booth编码产生的partial sum[i]不进行+1，而是将其放在partial sum[i+1]的低位上(反正本身也要补零，0+1一定是1)，这样就不会引入额外的partial sum
module booth #(
    parameter INXY_W = 66,
    parameter PSUM_W = INXY_W*2,
    parameter PSUM_N = INXY_W/2
) (
    input  [INXY_W-1:0] x,
    input  [INXY_W-1:0] y,
    output [PSUM_W-1:0] psum [PSUM_N-1:0]
);
    logic [INXY_W:0] psum_raw [PSUM_N-1:0];
    logic            clow_raw [PSUM_N-1:0];

    booth_sel #(.WIDTH(INXY_W)) b_sel_0(.x(x), .sel({y[1:0], 1'b0}), .psum(psum_raw[0]), .carry(clow_raw[0]));
    assign psum[0] = {{(INXY_W-1){psum_raw[0][INXY_W]}}, psum_raw[0]};
    for (genvar i = 1; i < PSUM_N; i++) begin
        booth_sel #(.WIDTH(INXY_W)) b_sel_(.x(x), .sel(y[2*i+1:2*i-1]), .psum(psum_raw[i]), .carry(clow_raw[i]));
        assign psum[i] = {{(INXY_W-1-2*i){psum_raw[i][INXY_W]}}, psum_raw[i], 1'b0, clow_raw[i-1], {(2*i-2){1'b0}}};
    end
endmodule;

module booth_sel #(
    parameter WIDTH = 32
) (
    input  [WIDTH-1:0] x,
    input  [2      :0] sel,
    output [WIDTH  :0] psum,
    output             carry
);
    wire sel_neg  =  sel[2] & (sel[1] ^ sel[0]);
    wire sel_pos  = ~sel[2] & (sel[1] ^ sel[0]);
    wire sel_dneg =  sel[2] & ~sel[1] & ~sel[0];
    wire sel_dpos = ~sel[2] &  sel[1] &  sel[0];

    assign psum  = sel_neg  ? ~{x[WIDTH-1], x} :
                   sel_pos  ?  {x[WIDTH-1], x} :
                   sel_dneg ? ~{x, 1'b0}       :
                   sel_dpos ?  {x, 1'b0}       :
                               {(WIDTH+1){1'b0}};
    assign carry = sel[2] & ~(sel[1] & sel[0]);
endmodule;
