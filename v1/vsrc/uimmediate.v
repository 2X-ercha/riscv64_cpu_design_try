module uimmediate (
    input [6:0] opcode,
    input [63:0] InputAddr,
    input [31:0] Uimm,
    output reg [63:0] OutputDataBus
);
    always @(*) begin
        // U-type
        // opcode = 0010111(RV32I) 0110111(RV32I)
        if (opcode == 7'b0010111) OutputDataBus = InputAddr + {{(32){Uimm[31]}}, Uimm}; // U auipc
        else if (opcode == 7'b0110111) OutputDataBus = {{(32){Uimm[31]}}, Uimm};        // U lui
        else OutputDataBus = 0;
    end
endmodule;
