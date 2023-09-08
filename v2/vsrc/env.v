module ENV (
    input en,
    input [63:0] imm, pc, gpr10,

    output reg debug_inst_analy
);
    initial begin
        debug_inst_analy = 0;
    end

    always @(*) begin
        if (~en) begin
            debug_inst_analy = 0;
        end
        else begin
            if (imm == ENVFLAG_ECALL) begin
                ;
                debug_inst_analy = 0;
            end
            else if (imm == ENVFLAG_EBREAK) begin
                ebreak(pc - 4, gpr10);
                debug_inst_analy = 1;
            end
            else begin
                debug_inst_analy = 0;
            end
        end
    end
endmodule;
