module csr_reg_group (
    input clk,
    input [11:0] CSRaddr,
    input [1:0] RW,
    input [63:0] CSRInput,
    output reg [63:0] CSROutput
);
    reg [63:0] csr[4096];

    always @(posedge clk) begin
        if (RW[1]) begin
            CSROutput <= csr[CSRaddr];
        end
    end
    always @(negedge clk) begin
        if (RW[0]) begin
            csr[CSRaddr] <= CSRInput;
        end
    end
endmodule;
