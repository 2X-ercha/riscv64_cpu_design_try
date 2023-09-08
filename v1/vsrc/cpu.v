`include "./vsrc/pc.v"
`include "./vsrc/memory_middleware.v"
`include "./vsrc/decode.v"
`include "./vsrc/bus_control.v"
`include "./vsrc/universal_reg_group.v"
`include "./vsrc/alu.v"
`include "./vsrc/logic_jump.v"
`include "./vsrc/uimmediate.v"

module cpu (
    input clk
);
    wire JumpEn;
    wire [63:0] InputAddr;
    wire [63:0] InstructionAddr;
    wire [31:0] Instruction;
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [4:0] rs1addr;
    wire [4:0] rs2addr;
    wire [4:0] rdaddr;
    wire [63:0] MemoryInput;
    wire [63:0] LogicJumpInput;
    wire [63:0] aluInput;
    wire [63:0] UimmediateInput;
    wire [11:0] Iimm;
    wire [11:0] Simm;
    wire [12:0] Bimm;
    wire [31:0] Uimm;
    wire [20:0] Jimm;
    wire [63:0] OutputBus1;
    wire [63:0] OutputBus2;
    wire [63:0] OutputBus3;
    wire [63:0] UniversalRegInput1;
    wire [63:0] UniversalRegInput2;
    wire [2:0] WRR;

    pc pc_inst (
        .clk(clk),
        .JumpEn(JumpEn),
        .InputAddr(InputAddr),
        .InstructionAddr(InstructionAddr)
    );

    memory_middleware memory_middleware_inst (
        .clk(clk),
        .opcode(opcode),
        .funct3(funct3),
        .PCaddr(InstructionAddr),
        .InputDataBus1(OutputBus1),
        .InputDataBus2(OutputBus2),
        .Iimm(Iimm),
        .Simm(Simm),
        .Instruction(Instruction),
        .OutputDataBus(MemoryInput)
    );

    decode decode_inst (
        .Instruction(Instruction),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rs1addr(rs1addr),
        .rs2addr(rs2addr),
        .rdaddr(rdaddr),
        .Iimm(Iimm),
        .Simm(Simm),
        .Bimm(Bimm),
        .Uimm(Uimm),
        .Jimm(Jimm)
    );

    bus_control bus_control_inst (
        .opcode(opcode),
        .aluInput(aluInput),
        .UniversalRegInput1(UniversalRegInput1),
        .UniversalRegInput2(UniversalRegInput2),
        .MemoryInput(MemoryInput),
        .LogicJumpInput(LogicJumpInput),
        .UimmediateInput(UimmediateInput),
        .WRR(WRR),
        .OutputBus1(OutputBus1),
        .OutputBus2(OutputBus2),
        .OutputBus3(OutputBus3)
    );

    universal_reg_group universal_reg_group_inst (
        .clk(clk),
        .InputRegaddr(rdaddr),
        .OutputRegaddr1(rs1addr),
        .OutputRegaddr2(rs2addr),
        .WRR(WRR),
        .InputDataBus(OutputBus3),
        .OutputDataBus1(UniversalRegInput1),
        .OutputDataBus2(UniversalRegInput2)
    );

    alu alu_inst (
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),
        .InputDataBus1(OutputBus1),
        .InputDataBus2(OutputBus2),
        .imm(Iimm),
        .OutputDataBus(aluInput)
    );

    logic_jump logic_jump_inst (
        .opcode(opcode),
        .funct3(funct3),
        .Iimm(Iimm),
        .Bimm(Bimm),
        .Jimm(Jimm),
        .InputAddr(InstructionAddr),
        .InputDataBus1(OutputBus1),
        .InputDataBus2(OutputBus2),
        .JumpEn(JumpEn),
        .OutputDataBus(LogicJumpInput),
        .OutputAddr(InputAddr)
    );

    uimmediate uimmediate_inst (
        .opcode(opcode),
        .InputAddr(InstructionAddr),
        .Uimm(Uimm),
        .OutputDataBus(UimmediateInput)
    );
endmodule;
