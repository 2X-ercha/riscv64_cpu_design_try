module decode (
    input [31:0] Instruction,
    output reg [6:0] opcode,
    // R type
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg [4:0] rs1addr,
    output reg [4:0] rs2addr,
    output reg [4:0] rdaddr,
    // I type
    output reg [11:0] Iimm,
    // S type
    output reg [11:0] Simm,
    // B type
    output reg [12:0] Bimm,
    // U type
    output reg [31:0] Uimm,
    // J Type
    output reg [20:0] Jimm
);
    always @(*) begin
        opcode = Instruction[6:0];
        funct3 = Instruction[14:12];
        funct7 = Instruction[31:25];
        rs1addr = Instruction[19:15];
        rs2addr = Instruction[24:20];
        rdaddr = Instruction[11:7];
        Iimm = Instruction[31:20];
        Simm = {Instruction[31:25], Instruction[11:7]};
        Bimm = {Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
        Uimm = {Instruction[31:12], 12'b0};
        Jimm = {Instruction[31], Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
    end
endmodule;
