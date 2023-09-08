/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */
module memory_middleware (
    input clk,
    input [6:0] opcode,
    input [2:0] funct3,
    input [63:0] PCaddr,
    input [63:0] InputDataBus1,
    input [63:0] InputDataBus2,
    input [11:0] Iimm,
    input [11:0] Simm,
    output reg [31:0] Instruction,
    output reg [63:0] OutputDataBus
);
    // 参照 verilater DPI-C 机制
    // https://verilator.org/guide/latest/connecting.html#direct-programming-interface-dpi
    import "DPI-C" function void pmem_init();
    import "DPI-C" function void pmem_read_instruction(
        input longint raddr,
        output int rdata);
    import "DPI-C" function void pmem_read_data(
        input longint raddr,
        output longint rdata);
    import "DPI-C" function void pmem_write_data(
        input longint waddr,
        input longint wdata,
        input byte wmask);

    initial begin
        pmem_init();
    end

    always @(posedge clk) begin
        // I-type
        // opcode = 0000011(RV32I/RV64I)
        if (opcode == 7'b0000011) begin
            reg [63:0] pmem_read_data_tmp;
            pmem_read_data(InputDataBus1 + {{(52){Iimm[11]}}, Iimm}, pmem_read_data_tmp);
            case (funct3)
                3'b000: OutputDataBus <= {{(56){pmem_read_data_tmp[7]}}, pmem_read_data_tmp[7:0]};                          // I lb
                3'b001: OutputDataBus <= {{(48){pmem_read_data_tmp[15]}}, pmem_read_data_tmp[15:0]};                        // I lh
                3'b010: OutputDataBus <= {{(32){pmem_read_data_tmp[31]}}, pmem_read_data_tmp[31:0]};                        // I lw
                3'b011: OutputDataBus <= pmem_read_data_tmp;                                                                // I ld
                3'b100: OutputDataBus <= {56'b0, pmem_read_data_tmp[7:0]};                                                  // I lbu
                3'b101: OutputDataBus <= {48'b0, pmem_read_data_tmp[15:0]};                                                 // I lhu
                3'b110: OutputDataBus <= {32'b0, pmem_read_data_tmp[31:0]};                                                 // I lwu
                3'b111: OutputDataBus <= pmem_read_data_tmp;
            endcase
        end
    end

    always @(negedge clk) begin
        // S-type
        // opcode = 0100011(RV32I/RV64I)
        if (opcode == 7'b0100011) begin
            case (funct3)
                3'b000: pmem_write_data(InputDataBus1 + {{(52){Simm[11]}}, Simm}, InputDataBus2, 8'b00000001); // S sb
                3'b001: pmem_write_data(InputDataBus1 + {{(52){Simm[11]}}, Simm}, InputDataBus2, 8'b00000011); // S sh
                3'b010: pmem_write_data(InputDataBus1 + {{(52){Simm[11]}}, Simm}, InputDataBus2, 8'b00001111); // S sw
                3'b011: pmem_write_data(InputDataBus1 + {{(52){Simm[11]}}, Simm}, InputDataBus2, 8'b11111111); // S sd
                default: ;
            endcase
        end
    end

    /* verilator lint_off SYNCASYNCNET */
    always @(PCaddr) begin
        pmem_read_instruction(PCaddr, Instruction);
    end
    /* verilator lint_on SYNCASYNCNET */
endmodule;
/* verilator lint_on UNUSEDSIGNAL */
/* verilator lint_on UNDRIVEN */
