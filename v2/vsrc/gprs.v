module Gprs (
    input clk,
    input [4:0] rs1addr, rs2addr, rdaddr,
    input [2:0] RRW,
    input [63:0] rd,
    output [63:0] rs1, rs2,
    output [63:0] debug_gprs[32]
);
    reg [63:0] gprs[32];
    initial begin
        gprs[0] = 64'b0;
    end

    // The register values need to be fetched before memory load (posedge clk).
    assign rs1 = (RRW[2]) ? gprs[rs1addr] : 0;
    assign rs2 = (RRW[1]) ? gprs[rs2addr] : 0;

    `ifdef DEBUG_REG
    always @(posedge clk) begin
        if (RRW[2]) begin
                $display("rs1: [%2d] %x", rs1addr, gprs[rs1addr]);
        end
        if (RRW[1]) begin
                $display("rs2: [%2d] %x", rs2addr, gprs[rs2addr]);
        end
    end
    `endif

    always @(negedge clk) begin
        if (RRW[0] && rdaddr != 0) begin
            gprs[rdaddr] <= rd;
            `ifdef DEBUG_REG
                $display("rd : [%2d] %x", rdaddr, rd);
            `endif
        end
    end

    assign debug_gprs = gprs;
endmodule;
