module logic_jump (
    input [6:0] opcode,
    input [2:0] funct3,
    input [11:0] Iimm,
    input [12:0] Bimm,
    input [20:0] Jimm,
    input [63:0] InputAddr,
    input [63:0] InputDataBus1,
    input [63:0] InputDataBus2,
    output reg JumpEn,
    output reg [63:0] OutputDataBus,
    output reg [63:0] OutputAddr
);
    initial begin
        JumpEn = 0;
    end
    always @(*) begin
        // I-type
        // opcode = 1100111(RV32I)
        if (opcode == 7'b1100111 && funct3 == 3'b000) begin                     // I jalr
            OutputDataBus = InputAddr + 4;
            OutputAddr = (InputDataBus1 + {{(52){Iimm[11]}}, Iimm}) & ~(64'b1);
            JumpEn = 1;
        end
        // B-type
        // opcode = 1100011(RV32I)
        else if (opcode == 7'b1100011) begin
            case (funct3)
                3'b000: begin                                                   // B beq
                    if (InputDataBus1 == InputDataBus2) begin
                        OutputAddr = InputAddr + {{(51){Bimm[12]}}, Bimm};
                        JumpEn = 1;
                        OutputDataBus = 0;
                    end
                    else begin
                        OutputAddr = 0;
                        JumpEn = 0;
                        OutputDataBus = 0;
                    end
                end
                3'b001: begin                                                   // B bne
                    if (InputDataBus1 != InputDataBus2) begin
                        OutputAddr = InputAddr + {{(51){Bimm[12]}}, Bimm};
                        JumpEn = 1;
                        OutputDataBus = 0;
                    end
                    else begin
                        OutputAddr = 0;
                        JumpEn = 0;
                        OutputDataBus = 0;
                    end
                end
                3'b100: begin                                                   // B blt
                    if ($signed(InputDataBus1) < $signed(InputDataBus2)) begin
                        OutputAddr = InputAddr + {{(51){Bimm[12]}}, Bimm};
                        JumpEn = 1;
                        OutputDataBus = 0;
                    end
                    else begin
                        OutputAddr = 0;
                        JumpEn = 0;
                        OutputDataBus = 0;
                    end
                end
                3'b101: begin                                                   // B bge
                    if ($signed(InputDataBus1) >= $signed(InputDataBus2)) begin
                        OutputAddr = InputAddr + {{(51){Bimm[12]}}, Bimm};
                        JumpEn = 1;
                        OutputDataBus = 0;
                    end
                    else begin
                        OutputAddr = 0;
                        JumpEn = 0;
                        OutputDataBus = 0;
                    end
                end
                3'b110: begin                                                   // B bltu
                    if ($unsigned(InputDataBus1) < $unsigned(InputDataBus2)) begin
                        OutputAddr = InputAddr + {{(51){Bimm[12]}}, Bimm};
                        JumpEn = 1;
                        OutputDataBus = 0;
                    end
                    else begin
                        OutputAddr = 0;
                        JumpEn = 0;
                        OutputDataBus = 0;
                    end
                end
                3'b111: begin                                                   // B bgeu
                    if ($unsigned(InputDataBus1) >= $unsigned(InputDataBus2)) begin
                        OutputAddr = InputAddr + {{(51){Bimm[12]}}, Bimm};
                        JumpEn = 1;
                        OutputDataBus = 0;
                    end
                    else begin
                        OutputAddr = 0;
                        JumpEn = 0;
                        OutputDataBus = 0;
                    end
                end
                default: begin
                    OutputAddr = 0;
                    JumpEn = 0;
                    OutputDataBus = 0;
                end
            endcase
        end
        // J-type
        // opcode = 1101111(RV32I)
        else if (opcode == 7'b1101111) begin                                    // J jal
            OutputDataBus = InputAddr + 4;
            OutputAddr = InputAddr + {{(43){Jimm[20]}}, Jimm};
            JumpEn = 1;
        end
        else begin
            OutputAddr = 0;
            JumpEn = 0;
            OutputDataBus = 0;
        end
    end
endmodule;
