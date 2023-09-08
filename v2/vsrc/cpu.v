// `define DEBUG
// `define DEBUG_REG

`include "dpidef.v"
`include "const.v"

`include "fetch.v"
`include "inst_split.v"
`include "sign_imm_ctrl.v"

`include "gprs.v"

`include "env.v"
`include "memory.v"
`include "logic_jump.v"
`include "alu.v"
`include "uimm_op.v"

module cpu (
    input clk,
    output [63:0] pc_reg,
    output [63:0] debug_gprs[32]
);

    wire [31:0] inst;
    // decode
    wire [6:0] opcode; wire [2:0] funct3; wire [6:0] funct7;
    wire [4:0] rs1addr, rs2addr, rdaddr;
    // imm
    wire [11:0] Iimm; wire [11:0] Simm; wire [12:0] Bimm; wire [31:0] Uimm; wire [20:0] Jimm;
    wire [63:0] imm;
    // ctrl
    wire R_alu64, R_alu32,
         I_alu64, I_alu32, I_memload, I_env, I_jalr,
         S_memstore,
         B_branch,
         U_auipc, U_lui,
         J_jal;
    wire alu_en, mem_en, env_en, logic_jump_en, uimm_op_en;

    // fetch and decode
    Fetch fetch (
        .clk(clk),
        .jump_en(jump_en), .inst_addr(inst_addr),
        .inst(inst), .pc_reg(pc_reg),
        .debug_inst_analy(debug_inst_analy)
    );

    InstSplit split (
        .inst(inst),
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .rs1addr(rs1addr), .rs2addr(rs2addr), .rdaddr(rdaddr),
        .Iimm(Iimm), .Simm(Simm), .Bimm(Bimm), .Uimm(Uimm), .Jimm(Jimm)
    );

    SignalAndImmCtrl ctrl (
        .opcode(opcode),
        .Iimm(Iimm), .Simm(Simm), .Bimm(Bimm), .Uimm(Uimm), .Jimm(Jimm),
        // opcode ctrl
        .R_alu64(R_alu64), .R_alu32(R_alu32),
        .I_alu64(I_alu64), .I_alu32(I_alu32), .I_memload(I_memload), .I_env(I_env), .I_jalr(I_jalr),
        .S_memstore(S_memstore),
        .B_branch(B_branch),
        .U_auipc(U_auipc), .U_lui(U_lui),
        .J_jal(J_jal),
        // module ctrl
        .alu_en(alu_en), .mem_en(mem_en), .env_en(env_en), .logic_jump_en(logic_jump_en), .uimm_op_en(uimm_op_en),
        // imm
        .imm(imm)
    );

    // ------------------------------------------------------------------------------------------------------------------ //

    // gprs
    wire [63:0] rs1, rs2;

    Gprs gprs (
        .clk(clk),
        .rs1addr(rs1addr), .rs2addr(rs2addr), .rdaddr(rdaddr),
        .RRW({reg_to_bus1_en, reg_to_bus2_en, bus3_to_reg_en}),
        .rs1(rs1), .rs2(rs2), .rd(bus3),
        .debug_gprs(debug_gprs)
    );

    // ------------------------------------------------------------------------------------------------------------------ //

    // module out
    wire [63:0] mem_out;
    wire [63:0] jal_out, jalr_out, jal_addr_out, jalr_addr_out, branch_addr_out;
    wire [63:0] alu_out;
    wire [63:0] auipc_out, lui_out;
    // jump ctrl
    wire [63:0] inst_addr = (J_jal)      ? jal_addr_out      :
                            (I_jalr)     ? jalr_addr_out     :
                            (B_jump_en)  ? branch_addr_out   :
                                           64'b0             ;
    wire B_jump_en;
    wire jump_en = J_jal | I_jalr | B_jump_en;
    // inst finish debug flag
    wire debug_inst_env,    debug_inst_mem,     debug_inst_jal,     debug_inst_jalr,
         debug_inst_branch, debug_inst_alu,     debug_inst_auipc,   debug_inst_lui;
    wire debug_inst_analy = debug_inst_env    | debug_inst_mem  | debug_inst_jal    | debug_inst_jalr   |
                            debug_inst_branch | debug_inst_alu  | debug_inst_auipc  | debug_inst_lui    ;

    // module
    ENV env (
        .en(env_en), .imm(imm), .pc(pc_reg), .gpr10(debug_gprs[10]),
        .debug_inst_analy(debug_inst_env)
    );
    Memory mem (
        .clk(clk), .read_en(I_memload), .write_en(S_memstore), .funct3(funct3), .bus1(bus1), .bus2(bus2), .imm(imm), .mem_out(mem_out),
        .debug_inst_analy(debug_inst_mem)
    );
    JAL jal (
        .en(J_jal), .pc(pc_reg), .imm(imm), .jal_out(jal_out), .inst_addr(jal_addr_out),
        .debug_inst_analy(debug_inst_jal)
    );
    JALR jalr (
        .en(I_jalr), .funct3(funct3), .pc(pc_reg), .bus1(bus1), .imm(imm), .jalr_out(jalr_out), .inst_addr(jalr_addr_out),
        .debug_inst_analy(debug_inst_jalr)
    );
    Branch branch(
        .en(B_branch), .funct3(funct3), .pc(pc_reg), .bus1(bus1), .bus2(bus2), .imm(imm), .jump_en(B_jump_en), .inst_addr(branch_addr_out),
        .debug_inst_analy(debug_inst_branch)
    );
    ALU alu (
        .en(alu_en), .mode({I_alu32 | I_alu64, R_alu32 | I_alu32}), .funct3(funct3), .funct7(funct7), .bus1(bus1), .bus2(bus2), .imm(imm), .alu_out(alu_out),
        .debug_inst_analy(debug_inst_alu)
    );
    AUIPC auipc (
        .en(U_auipc), .pc(pc_reg), .imm(imm), .auipc_out(auipc_out),
        .debug_inst_analy(debug_inst_auipc)
    );
    LUI lui (
        .en(U_lui), .imm(imm), .lui_out(lui_out),
        .debug_inst_analy(debug_inst_lui)
    );

    // ------------------------------------------------------------------------------------------------------------------ //

    // gprs RRW ctrl
    wire reg_to_bus1_en = R_alu32   | R_alu64    | I_alu32    | I_alu64  |
                          I_memload | S_memstore |
                          I_jalr    | B_branch   ;
    wire reg_to_bus2_en = R_alu32   | R_alu64    | S_memstore | B_branch ;
    wire bus3_to_reg_en = R_alu32   | R_alu64    | I_alu32    | I_alu64  |
                          I_memload |
                          I_jalr    | J_jal      |
                          U_auipc   | U_lui      ;
    // bus ctrl
    wire [63:0] bus1 = (reg_to_bus1_en)  ? rs1            : 64'b0;
    wire [63:0] bus2 = (reg_to_bus2_en)  ? rs2            : 64'b0;
    wire [63:0] bus3 = (alu_en)          ? alu_out        :
                       (I_memload)       ? mem_out        :
                       (J_jal)           ? jal_out        :
                       (I_jalr)          ? jalr_out       :
                       (U_auipc)         ? auipc_out      :
                       (U_lui)           ? lui_out        :
                                           64'b0          ;
endmodule;
