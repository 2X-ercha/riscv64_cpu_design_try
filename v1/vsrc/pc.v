module pc (
    input clk,
    input JumpEn,
    input [63:0] InputAddr,
    output reg [63:0] InstructionAddr
);
    initial begin
        // FIXME: 地址暂时使用 0 作为开始
        // InstructionAddr = 64'h80000000;
        InstructionAddr = 64'h0;
    end

    always @(negedge clk) begin
        if (JumpEn) begin
            InstructionAddr <= InputAddr;
        end
        else begin
            InstructionAddr <= InstructionAddr + 4;
        end
    end
endmodule;
