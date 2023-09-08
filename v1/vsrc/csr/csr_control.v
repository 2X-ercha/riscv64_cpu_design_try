module csr_control (
    input [6:0] opcode,
    input [2:0] funct3,
    input [4:0] zimm,
    input [63:0] CSRInput,
    input [63:0] InputDataBus,
    output reg [63:0] CSROutput,
    output reg [63:0] OutputDataBus
);
    // I type
    // opcode = 1110011
    // RV32/RV64 Zicsr Standard Extension
    always @(*) begin
        if (opcode == 7'b1110011) begin
            // 3'b000 ecall and ebreak 非alu功能
            case (funct3)
                3'b001: begin // I csrrw
                    OutputDataBus = CSRInput;
                    CSROutput = InputDataBus;
                end
                3'b010: begin // I csrrs
                    OutputDataBus = CSRInput;
                    CSROutput = CSRInput | InputDataBus;
                end
                3'b011: begin // I csrrc
                    OutputDataBus = CSRInput;
                    CSROutput = CSRInput & InputDataBus;
                end
                3'b101: begin // I csrrwi
                    OutputDataBus = CSRInput;
                    CSROutput = {59'b0, zimm};
                end
                3'b110: begin // I csrrsi
                    OutputDataBus = CSRInput;
                    if (zimm == 0) CSROutput = CSRInput;
                    else CSROutput = CSRInput | {59'b0, zimm};
                end
                3'b111: begin // I csrrci
                    OutputDataBus = CSRInput;
                    if (zimm == 0) CSROutput = CSRInput;
                    else CSROutput = CSRInput & {59'b0, zimm};
                end
                default: begin
                    CSROutput = CSRInput;
                    OutputDataBus = 0;
                end
            endcase
        end
        else begin
            CSROutput = CSRInput;
            OutputDataBus = 0;
        end
    end
endmodule;
