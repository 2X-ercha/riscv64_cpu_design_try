module alu (
    input [2:0] funct3,
    input [6:0] funct7,
    input [6:0] opcode,
    input [63:0] InputDataBus1,
    input [63:0] InputDataBus2,
    input [11:0] imm,
    output reg [63:0] OutputDataBus
);
    always @(*) begin
        // R-type
        // opcode = 0110011(RV32I/RV32M) 0111011(RV64I/RV64M)
        if (opcode == 7'b0110011) begin
            case (funct3)
                3'b000: begin
                    if (funct7 == 7'h00)      OutputDataBus = $signed(InputDataBus1) + $signed(InputDataBus2);              // R add
                    else if (funct7 == 7'h20) OutputDataBus = $signed(InputDataBus1) - $signed(InputDataBus2);              // R sub
                    else if (funct7 == 7'h01) OutputDataBus = $signed(InputDataBus1) * $signed(InputDataBus2);              // R mul
                    else OutputDataBus = 0;
                end
                3'b001: begin
                    if (funct7 == 7'h00)      OutputDataBus = InputDataBus1 << InputDataBus2[5:0];                          // R sll
                    else if (funct7 == 7'h01) begin                                                                         // R mulh
                        /* verilator lint_off WIDTHTRUNC */
                        OutputDataBus = $signed({{(64){InputDataBus1[63]}}, InputDataBus1}) * $signed({{(64){InputDataBus2[63]}}, InputDataBus2}) >> 64;
                        /* verilator lint_on WIDTHTRUNC */
                    end
                    else OutputDataBus = 0;
                end
                3'b010: begin
                    if (funct7 == 7'h00)      OutputDataBus = ($signed(InputDataBus1) < $signed(InputDataBus2)) ? 1 : 0;    // R slt
                    else if (funct7 == 7'h01) begin                                                                         // R mulhsu
                        /* verilator lint_off WIDTHTRUNC */
                        OutputDataBus = $signed({{(64){InputDataBus1[63]}}, InputDataBus1}) * $unsigned({64'b0, InputDataBus2}) >> 64;
                        /* verilator lint_on WIDTHTRUNC */
                    end
                    else OutputDataBus = 0;
                end
                3'b011: begin
                    if (funct7 == 7'h00)      OutputDataBus = ($unsigned(InputDataBus1) < $unsigned(InputDataBus2)) ? 1 : 0;// R sltu
                    else if (funct7 == 7'h01) begin                                                                         // R mulhu
                        /* verilator lint_off WIDTHTRUNC */
                        OutputDataBus = $unsigned({64'b0, InputDataBus1}) * $unsigned({64'b0, InputDataBus2}) >> 64;
                        /* verilator lint_on WIDTHTRUNC */
                    end
                    else OutputDataBus = 0;
                end
                3'b100: begin
                    if (funct7 == 7'h00)      OutputDataBus = InputDataBus1 ^ InputDataBus2;                                // R xor
                    else if (funct7 == 7'h01) OutputDataBus = $signed(InputDataBus1) / $signed(InputDataBus2);              // R div
                    else OutputDataBus = 0;
                end
                3'b101: begin
                    if (funct7 == 7'h00)      OutputDataBus = InputDataBus1 >> InputDataBus2[5:0];                          // R srl
                    else if (funct7 == 7'h20) OutputDataBus = $signed(InputDataBus1) >>> InputDataBus2[5:0];                // R sra
                    else if (funct7 == 7'h01) OutputDataBus = $unsigned(InputDataBus1) / $unsigned(InputDataBus2);          // R divu
                    else OutputDataBus = 0;
                end
                3'b110: begin
                    if (funct7 == 7'h00)      OutputDataBus = InputDataBus1 | InputDataBus2;                                // R or
                    else if (funct7 == 7'h01) OutputDataBus = $signed(InputDataBus1) % $signed(InputDataBus2);              // R rem
                    else OutputDataBus = 0;
                end
                3'b111: begin
                    if (funct7 == 7'h00)      OutputDataBus = InputDataBus1 & InputDataBus2;                                // R and
                    else if (funct7 == 7'h01) OutputDataBus = $unsigned(InputDataBus1) % $unsigned(InputDataBus2);          // R remu
                    else OutputDataBus = 0;
                end
            endcase
        end
        else if (opcode == 7'b0111011) begin
            case (funct3)
                3'b000: begin
                    if (funct7 == 7'h00)      begin                                                                         // R addw
                        OutputDataBus = {32'b0, InputDataBus1[31:0]} + {32'b0, InputDataBus2[31:0]};
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end
                    else if (funct7 == 7'h20) begin                                                                         // R subw
                        OutputDataBus = {32'b0, InputDataBus1[31:0]} - {32'b0, InputDataBus2[31:0]};
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end
                    else if (funct7 == 7'h01) begin                                                                         // R mulw
                        OutputDataBus = {32'b0, InputDataBus1[31:0]} * {32'b0, InputDataBus2[31:0]};
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end
                    else OutputDataBus = 0;
                end
                3'b001: begin
                    if (funct7 == 7'h00)      begin                                                                         // R sllw
                        OutputDataBus = InputDataBus1 << InputDataBus2[4:0];
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end
                    else OutputDataBus = 0;
                end
                3'b100: begin
                    if (funct7 == 7'h01)      begin                                                                         // R divw
                        OutputDataBus = {32'b0, InputDataBus1[31:0]} / {32'b0, InputDataBus2[31:0]};
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end
                    else OutputDataBus = 0;
                end
                3'b101: begin
                    if (funct7 == 7'h00)      begin                                                                         // R srlw
                        OutputDataBus = {32'b0, InputDataBus1[31:0]};
                        OutputDataBus = OutputDataBus >> InputDataBus2[4:0];
                    end
                    else if (funct7 == 7'h20) begin                                                                         // R sraw
                        OutputDataBus = {{(32){InputDataBus1[31]}}, InputDataBus1[31:0]};
                        OutputDataBus = $signed(OutputDataBus) >>> InputDataBus2[4:0];
                    end
                    else if (funct7 == 7'h01) begin                                                                         // R divuw
                        OutputDataBus = $unsigned({32'b0, InputDataBus1[31:0]}) / $unsigned({32'b0, InputDataBus2[31:0]});
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end                                                           // FIXME: divuw的扩展应该有符号还是无符号，下面的remuw也是
                    else OutputDataBus = 0;
                end
                3'b110: begin
                    if (funct7 == 7'h01)      begin                                                                         // R remw
                        OutputDataBus = {32'b0, InputDataBus1[31:0]} % {32'b0, InputDataBus2[31:0]};
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end
                    else OutputDataBus = 0;
                end
                3'b111: begin
                    if (funct7 == 7'h01)     begin                                                                          // R remuw
                        OutputDataBus = $unsigned({32'b0, InputDataBus1[31:0]}) % $unsigned({32'b0, InputDataBus2[31:0]});
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end
                    else OutputDataBus = 0;
                end
                default: OutputDataBus = 0;
            endcase
        end
        // I-type
        // opcode = 0010011(RV32I/RV64I) 0011011(RV64I)
        else if (opcode == 7'b0010011) begin
            case (funct3)
                3'b000: OutputDataBus = $signed(InputDataBus1) + $signed({{(52){imm[11]}}, imm});                           // I addi
                3'b001: begin
                    if (imm[11:6] == 6'h00) OutputDataBus = InputDataBus1 << imm[5:0];                                      // I slli
                    else OutputDataBus = 0;
                end
                3'b010: OutputDataBus = ($signed(InputDataBus1) < $signed({{(52){imm[11]}}, imm})) ? 1 : 0;                 // I slti
                3'b011: OutputDataBus = ($unsigned(InputDataBus1) < $unsigned({{(52){imm[11]}}, imm})) ? 1 : 0;             // I sltiu
                3'b100: OutputDataBus = InputDataBus1 ^ {{(52){imm[11]}}, imm};                                             // I xori
                3'b101: begin
                    if (imm[11:6] == 6'h00) OutputDataBus = InputDataBus1 >> imm[5:0];                                      // I srli
                    else if (imm[11:6] == 6'h10) OutputDataBus = $signed(InputDataBus1) >>> imm[5:0];                       // I srai
                    else OutputDataBus = 0;
                end
                3'b110: OutputDataBus = InputDataBus1 | {{(52){imm[11]}}, imm};                                             // I ori
                3'b111: OutputDataBus = InputDataBus1 & {{(52){imm[11]}}, imm};                                             // I andi
            endcase
        end
        else if (opcode == 7'b0011011) begin
            case (funct3)
                3'b000: begin                                                                                               // I addiw
                    OutputDataBus = $signed(InputDataBus1) + $signed({{(52){imm[11]}}, imm});
                    OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                end
                3'b001: begin
                    if (imm[11:5] == 7'h00) begin                                                                           // I slliw
                        OutputDataBus = InputDataBus1 << imm[4:0];
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end
                    else OutputDataBus = 0;
                end
                3'b101: begin
                    if (imm[11:5] == 7'h00) begin                                                                           // I srliw
                        // 把寄存器 x[rs1]左移 shamt 位，空出的位置填入 0，结果截为 32 位，进行有符号扩展后写入 x[rd]。
                        OutputDataBus = InputDataBus1 >> imm[4:0];
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end
                    else if (imm[11:5] == 7'h20) begin                                                                      // I sraiw
                        // [!] 把寄存器 x[rs1]的低 32 位右移 shamt 位，空位用 x[rs1][31]填充，结果进行有符号扩展后写入 x[rd]。
                        OutputDataBus = $signed({{(32){InputDataBus1[31]}}, InputDataBus1[31:0]}) >>> imm[4:0];
                        OutputDataBus = {{(32){OutputDataBus[31]}}, OutputDataBus[31:0]};
                    end
                    else OutputDataBus = 0;
                end
                default: OutputDataBus = 0;
            endcase
        end
        else OutputDataBus = 0;
    end
endmodule;
