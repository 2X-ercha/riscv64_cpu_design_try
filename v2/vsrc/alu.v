module ALU_M_ext (
    input en,
    input [2:0] funct3,
    input [63:0] operand1, operand2,
    output reg [63:0] alu_M_Out,

    output reg [7:0] debug_inst_alu_M_ext
);
    parameter ALU_MUL       = 3'b000;
    parameter ALU_MULH      = 3'b001;
    parameter ALU_MULHSU    = 3'b010;
    parameter ALU_MULHU     = 3'b011;
    parameter ALU_DIV       = 3'b100;
    parameter ALU_DIVU      = 3'b101;
    parameter ALU_REM       = 3'b110;
    parameter ALU_REMU      = 3'b111;

    parameter DEBUG_INST_MUL    = 8'b10000000;
    parameter DEBUG_INST_MULH   = 8'b01000000;
    parameter DEBUG_INST_MULHSU = 8'b00100000;
    parameter DEBUG_INST_MULHU  = 8'b00010000;
    parameter DEBUG_INST_DIV    = 8'b00001000;
    parameter DEBUG_INST_DIVU   = 8'b00000100;
    parameter DEBUG_INST_REM    = 8'b00000010;
    parameter DEBUG_INST_REMU   = 8'b00000001;
    parameter DEBUG_INST_NONE   = 8'b0;

    // arithmetic all result
    wire [127:0] result_mulss = $signed(operand1)   * $signed(operand2);
    wire [127:0] result_mulsu = $signed(operand1)   * $unsigned(operand2);
    wire [127:0] result_muluu = $unsigned(operand1) * $unsigned(operand2);

    wire [63:0] ans_mul     = result_mulss[63:0];
    wire [63:0] ans_mulh    = result_mulss[127:64];
    wire [63:0] ans_mulhsu  = result_mulsu[127:64];
    wire [63:0] ans_mulhu   = result_muluu[127:64];
    wire [63:0] ans_div     = $signed(operand1) / $signed(operand2);
    wire [63:0] ans_divu    = $unsigned(operand1) / $unsigned(operand2);
    wire [63:0] ans_rem     = $signed(operand1) % $signed(operand2);
    wire [63:0] ans_remu    = $unsigned(operand1) % $unsigned(operand2);

    // case result
    initial begin
        debug_inst_alu_M_ext = DEBUG_INST_NONE;
    end

    always @(*) begin
        if (~en) begin
            alu_M_Out = 64'b0;
            debug_inst_alu_M_ext = DEBUG_INST_NONE;
        end
        else begin
            case (funct3)
                ALU_MUL: begin
                    alu_M_Out = ans_mul;
                    debug_inst_alu_M_ext = DEBUG_INST_MUL;
                end
                ALU_MULH: begin
                    alu_M_Out = ans_mulh;
                    debug_inst_alu_M_ext = DEBUG_INST_MULH;
                end
                ALU_MULHSU: begin
                    alu_M_Out = ans_mulhsu;
                    debug_inst_alu_M_ext = DEBUG_INST_MULHSU;
                end
                ALU_MULHU: begin
                    alu_M_Out = ans_mulhu;
                    debug_inst_alu_M_ext = DEBUG_INST_MULHU;
                end
                ALU_DIV: begin
                    alu_M_Out = ans_div;
                    debug_inst_alu_M_ext = DEBUG_INST_DIV;
                end
                ALU_DIVU: begin
                    alu_M_Out = ans_divu;
                    debug_inst_alu_M_ext = DEBUG_INST_DIVU;
                end
                ALU_REM: begin
                    alu_M_Out = ans_rem;
                    debug_inst_alu_M_ext = DEBUG_INST_REM;
                end
                ALU_REMU: begin
                    alu_M_Out = ans_remu;
                    debug_inst_alu_M_ext = DEBUG_INST_REMU;
                end
            endcase
        end
    end
endmodule;

module ALU (
    input en,
    input [1:0] mode, // {Rtype/Itype, 64/32}
    input [2:0] funct3,
    input [6:0] funct7,
    input [63:0] bus1, bus2, imm,
    output [63:0] alu_out,

    output debug_inst_analy
);
    wire [63:0] operand1 = (mode[0]) ? {{(32){bus1[31]}}, bus1[31:0]}   :
                                       bus1                             ;
    wire [63:0] operand2 = (mode[1]) ? imm                              :
                           (mode[0]) ? {{(32){bus2[31]}}, bus2[31:0]}   :
                                       bus2                             ;

    reg [7:0] debug_inst_alu_I;
    wire [7:0] debug_inst_alu_M_ext;

    reg [63:0] result_I64;
    wire [63:0] result_M_ext64;

    parameter ALU_ADD   = 3'b000;
    parameter ALU_SHL   = 3'b001;
    parameter ALU_SLT   = 3'b010;
    parameter ALU_SLTU  = 3'b011;
    parameter ALU_XOR   = 3'b100;
    parameter ALU_SHR   = 3'b101;
    parameter ALU_OR    = 3'b110;
    parameter ALU_AND   = 3'b111;

    parameter DEBUG_INST_ADD    = 8'b10000000;
    parameter DEBUG_INST_SHL    = 8'b01000000;
    parameter DEBUG_INST_SLT    = 8'b00100000;
    parameter DEBUG_INST_SLTU   = 8'b00010000;
    parameter DEBUG_INST_XOR    = 8'b00001000;
    parameter DEBUG_INST_SHR    = 8'b00000100;
    parameter DEBUG_INST_OR     = 8'b00000010;
    parameter DEBUG_INST_AND    = 8'b00000001;
    parameter DEBUG_INST_NONE   = 8'b0;

    // arithmetic all result
    wire [5:0]  shift_amt   = operand2[5:0];

    wire [63:0] ans_add     = operand1 + operand2;
    wire [63:0] ans_sub     = operand1 - operand2;
    wire [63:0] ans_shl     = operand1 << shift_amt;
    wire [63:0] ans_slt     = ($signed(operand1) < $signed(operand2)) ? 64'b1 : 64'b0;
    wire [63:0] ans_sltu    = ($unsigned(operand1) < $unsigned(operand2)) ? 64'b1 : 64'b0;
    wire [63:0] ans_xor     = operand1 ^ operand2;
    wire [63:0] ans_srl64   = operand1 >> shift_amt;
    wire [63:0] ans_srl32   = {32'b0, operand1[31:0]} >> shift_amt;
    wire [63:0] ans_sra     = $signed(operand1) >>> shift_amt;
    wire [63:0] ans_or      = operand1 | operand2;
    wire [63:0] ans_and     = operand1 & operand2;

    ALU_M_ext alu_m_ext (
        .en(funct7[ALUINDEX_M_EXT] & ~mode[1]), .funct3(funct3), .operand1(operand1), .operand2(operand2), .alu_M_Out(result_M_ext64),
        .debug_inst_alu_M_ext(debug_inst_alu_M_ext)
    );

    // case result
    initial begin
        debug_inst_alu_I = DEBUG_INST_NONE;
    end

    always @(*) begin
        if (~en) begin
            result_I64 = 64'b0;
            debug_inst_alu_I = DEBUG_INST_NONE;
        end
        else begin
            case (funct3)
                ALU_ADD: begin
                    result_I64 = (funct7[ALUINDEX_OP_MODIFIER] & ~mode[1]) ? ans_sub : ans_add;
                    debug_inst_alu_I = DEBUG_INST_ADD;
                end
                ALU_SHL: begin
                    result_I64 = ans_shl;
                    debug_inst_alu_I = DEBUG_INST_SHL;
                end
                ALU_SLT: begin
                    result_I64 = ans_slt;
                    debug_inst_alu_I = DEBUG_INST_SLT;
                end
                ALU_SLTU: begin
                    result_I64 = ans_sltu;
                    debug_inst_alu_I = DEBUG_INST_SLTU;
                end
                ALU_XOR: begin
                    result_I64 = ans_xor;
                    debug_inst_alu_I = DEBUG_INST_XOR;
                end
                ALU_SHR: begin
                    result_I64 = (funct7[ALUINDEX_OP_MODIFIER]) ? ans_sra : ((mode[0]) ? ans_srl32 : ans_srl64);
                    debug_inst_alu_I = DEBUG_INST_SHR;
                end
                ALU_OR : begin
                    result_I64 = ans_or;
                    debug_inst_alu_I = DEBUG_INST_OR;
                end
                ALU_AND: begin
                    result_I64 = ans_and;
                    debug_inst_alu_I = DEBUG_INST_AND;
                end
            endcase
        end
    end

    wire [63:0] result_I32      = {{(32){result_I64[31]}}, result_I64[31:0]};
    wire [63:0] result_M_ext32  = {{(32){result_M_ext64[31]}}, result_M_ext64[31:0]};

    wire [63:0] result_I        = (mode[0])                             ? result_I32        : result_I64;
    wire [63:0] result_M_ext    = (mode[0])                             ? result_M_ext32    : result_M_ext64;
    assign alu_out              = (funct7[ALUINDEX_M_EXT] & ~mode[1])   ? result_M_ext      : result_I;

    assign debug_inst_analy = debug_inst_alu_I[7]     | debug_inst_alu_I[6]     | debug_inst_alu_I[5]     | debug_inst_alu_I[4]     |
                              debug_inst_alu_I[3]     | debug_inst_alu_I[2]     | debug_inst_alu_I[1]     | debug_inst_alu_I[0]     |
                              debug_inst_alu_M_ext[7] | debug_inst_alu_M_ext[6] | debug_inst_alu_M_ext[5] | debug_inst_alu_M_ext[4] |
                              debug_inst_alu_M_ext[3] | debug_inst_alu_M_ext[2] | debug_inst_alu_M_ext[1] | debug_inst_alu_M_ext[0] ;
endmodule;
