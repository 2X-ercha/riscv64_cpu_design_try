module bus_control (
    input [6:0] opcode,
    // 总线的各个入口出口
    input [63:0] aluInput,
    input [63:0] UniversalRegInput1,
    input [63:0] UniversalRegInput2,
    input [63:0] MemoryInput,
    input [63:0] LogicJumpInput,
    input [63:0] UimmediateInput,
    // 权限控制（内存权限不用这里分配）
    output reg [2:0] WRR,
    // 总线接收分配
    output reg [63:0] OutputBus1,
    output reg [63:0] OutputBus2,
    output reg [63:0] OutputBus3
);
    // alu -> Output -> universal reg group
    // memory -> Input2
    // universal reg group -> Input1/2 -> alu/memory
    // 组合逻辑
    always @(*) begin
        // alu R-type
        // opcode = 0110011(RV32I/RV32M) 0111011(RV64I/RV64M)
        if (opcode == 7'b0110011 || opcode == 7'b0111011) begin
            OutputBus1 = UniversalRegInput1;
            OutputBus2 = UniversalRegInput2;
            OutputBus3 = aluInput;
            WRR = 3'b111;
        end
        // alu I-type
        // opcode = 0010011(RV32I/RV64I) 0011011(RV64I)
        else if (opcode == 7'b0010011 || opcode == 7'b0011011) begin
            OutputBus1 = UniversalRegInput1;
            OutputBus2 = 0;
            OutputBus3 = aluInput;
            WRR = 3'b110;
        end
        // memory_middleware I-type
        // opcode = 0000011(RV32I/RV64I)
        else if (opcode == 7'b0000011) begin
            OutputBus1 = UniversalRegInput1;
            OutputBus2 = 0;
            OutputBus3 = MemoryInput;
            WRR = 3'b010;
        end
        // memory_middleware S-type
        // opcode = 0100011(RV32I/RV64I)
        else if (opcode == 7'b0100011) begin
            OutputBus1 = UniversalRegInput1;
            OutputBus2 = UniversalRegInput2;
            OutputBus3 = 0;
            WRR = 3'b011;
        end
        // logic_jump I-type
        // opcode = 1100111(RV32I)
        else if (opcode == 7'b1100111) begin
            OutputBus1 = UniversalRegInput1;
            OutputBus2 = 0;
            OutputBus3 = LogicJumpInput;
            WRR = 3'b110;
        end
        // logic_jump B-type
        // opcode = 1100011(RV32I)
        else if (opcode == 7'b1100011) begin
            OutputBus1 = UniversalRegInput1;
            OutputBus2 = UniversalRegInput2;
            OutputBus3 = 0;
            WRR = 3'b011;
        end
        // logic_jump J-type
        // opcode = 1101111(RV32I)
        else if (opcode == 7'b1101111) begin
            OutputBus1 = 0;
            OutputBus2 = 0;
            OutputBus3 = LogicJumpInput;
            WRR = 3'b100;
        end
        // uimmediate U-type
        // opcode = 0010111(RV32I) 0110111(RV32I)
        else if (opcode == 7'b0010111 || opcode == 7'b0110111) begin
            OutputBus1 = 0;
            OutputBus2 = 0;
            OutputBus3 = UimmediateInput;
            WRR = 3'b100;
        end
        else begin
            OutputBus1 = 0;
            OutputBus2 = 0;
            OutputBus3 = 0;
            WRR = 0;
        end
    end
endmodule;
