module universal_reg_group (
    input clk,
    input [4:0] InputRegaddr,
    input [4:0] OutputRegaddr1,
    input [4:0] OutputRegaddr2,
    input [2:0] WRR,
    input [63:0] InputDataBus,
    output reg [63:0] OutputDataBus1,
    output reg [63:0] OutputDataBus2
);
    reg [63:0] x[32];
    initial begin
        x[0] = 64'h0;
    end

    always @(posedge clk) begin
        if (WRR[1]) begin
            OutputDataBus1 <= x[OutputRegaddr1];
            $display("posedge:\nrs1reg - x%d:\t%x", OutputRegaddr1, x[OutputRegaddr1]);
        end
        if (WRR[0]) begin
            OutputDataBus2 <= x[OutputRegaddr2];
            $display("posedge:\nrs2reg - x%d:\t%x", OutputRegaddr2, x[OutputRegaddr2]);
        end
    end

    always @(negedge clk) begin
        if (WRR[2]) begin
            x[InputRegaddr] <= InputDataBus;
            $display("negedge:\nrd reg - x%d:\t%x", InputRegaddr, InputDataBus);
        end
    end
endmodule;
