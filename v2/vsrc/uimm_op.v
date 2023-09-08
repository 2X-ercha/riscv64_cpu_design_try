module AUIPC (
    input en,
    input [63:0] pc, imm,
    output reg [63:0] auipc_out,

    output reg debug_inst_analy
);
    initial begin
        debug_inst_analy = 0;
    end

    always @(*) begin
        if (~en) begin
            auipc_out = 64'b0;
            debug_inst_analy = 0;
        end
        else begin
            auipc_out = pc - 4 + imm;
            debug_inst_analy = 1;
        end
    end
endmodule;

module LUI (
    input en,
    input [63:0] imm,
    output reg [63:0] lui_out,

    output reg debug_inst_analy
);
    initial begin
        debug_inst_analy = 0;
    end

    always @(*) begin
        if (~en) begin
            lui_out = 64'b0;
            debug_inst_analy = 0;
        end
        else begin
            lui_out = imm;
            debug_inst_analy = 1;
        end
    end
endmodule;

