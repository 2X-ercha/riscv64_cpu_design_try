module InstSplit (
    input [31:0] inst,
    output [6:0] opcode,
    // R type
    output [2:0] funct3,
    output [6:0] funct7,
    output [4:0] rs1addr,
    output [4:0] rs2addr,
    output [4:0] rdaddr,
    // I type
    output [11:0] Iimm,
    // S type
    output [11:0] Simm,
    // B type
    output [12:0] Bimm,
    // U type
    output [31:0] Uimm,
    // J Type
    output [20:0] Jimm
);
    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];
    assign rs1addr = inst[19:15];
    assign rs2addr = inst[24:20];
    assign rdaddr = inst[11:7];
    assign Iimm = inst[31:20];
    assign Simm = {inst[31:25], inst[11:7]};
    assign Bimm = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
    assign Uimm = {inst[31:12], 12'b0};
    assign Jimm = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
endmodule;
