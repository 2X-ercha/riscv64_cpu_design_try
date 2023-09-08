module Fetch (
    input clk,
    input jump_en,
    input [63:0] inst_addr,
    output reg [31:0] inst,
    output reg [63:0] pc_reg,

    input debug_inst_analy
);
    reg [63:0] pc_next_reg;

    `ifdef DEBUG
        reg first_time_init;
    `endif

    initial begin
        pc_reg = PC_RESET;
        pc_next_reg = PC_RESET;

        `ifdef DEBUG
            first_time_init = 1;
        `endif
    end

    always @(pc_next_reg) begin
        pc_reg <= pc_next_reg;
    end

    always @(negedge clk) begin
        if (jump_en) begin
            pc_next_reg <= inst_addr + 4;
            inst <= readword(inst_addr);
        end
        else begin
            pc_next_reg <= pc_reg + 4;
            inst <= readword(pc_reg);
        end

        `ifdef DEBUG
            if (~debug_inst_analy && ~first_time_init) begin
                debug_inv(pc_reg - 4);
            end
            else begin
                first_time_init = 0;
            end
        `endif
    end
endmodule;
