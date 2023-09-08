module SignalAndImmCtrl (
    input [6:0] opcode,

    input [11:0] Iimm,
    input [11:0] Simm,
    input [12:0] Bimm,
    input [31:0] Uimm,
    input [20:0] Jimm,

    // opcode ctrl
    output R_alu64, R_alu32,
           I_alu64, I_alu32, I_memload, I_env, I_jalr,
           S_memstore,
           B_branch,
           U_auipc, U_lui,
           J_jal,
    // module ctrl
    output alu_en, mem_en, env_en, logic_jump_en, uimm_op_en,
    // imm sel
    output reg [63:0] imm
);
    assign R_alu64          = (opcode == R_ALU64);
    assign R_alu32          = (opcode == R_ALU32);
    assign I_alu64          = (opcode == I_ALU64);
    assign I_alu32          = (opcode == I_ALU32);
    assign I_memload        = (opcode == I_MEMLOAD);
    assign I_env            = (opcode == I_ENV);
    assign I_jalr           = (opcode == I_JALR);
    assign S_memstore       = (opcode == S_MEMSTORE);
    assign B_branch         = (opcode == B_BRANCH);
    assign U_auipc          = (opcode == U_AUIPC);
    assign U_lui            = (opcode == U_LUI);
    assign J_jal            = (opcode == J_JAL);

    assign alu_en           = R_alu64   | R_alu32   | I_alu64   | I_alu32;
    assign mem_en           = I_memload | S_memstore;
    assign env_en           = I_env;
    assign logic_jump_en    = I_jalr    | B_branch  | J_jal;
    assign uimm_op_en       = U_auipc   | U_lui;

    wire I = I_alu64 | I_alu32 | I_memload | I_env | I_jalr;
    wire S = S_memstore;
    wire B = B_branch;
    wire U = U_auipc | U_lui;
    wire J = J_jal;

    wire [4:0] type_sel = {I, S, B, U, J};

    parameter caseI = 5'b10000;
    parameter caseS = 5'b01000;
    parameter caseB = 5'b00100;
    parameter caseU = 5'b00010;
    parameter caseJ = 5'b00001;

    always @(*) begin
        case (type_sel)
            caseI: imm = {{(52){Iimm[11]}}, Iimm};
            caseS: imm = {{(52){Simm[11]}}, Simm};
            caseB: imm = {{(51){Bimm[12]}}, Bimm};
            caseU: imm = {{(32){Uimm[31]}}, Uimm};
            caseJ: imm = {{(43){Jimm[20]}}, Jimm};
            default: imm = 64'b0;
        endcase
    end
endmodule;
