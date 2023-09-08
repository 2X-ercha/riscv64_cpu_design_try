module JAL (
    input en,
    input [63:0] pc, imm,
    output reg [63:0] jal_out, inst_addr,

    output reg debug_inst_analy
);
    initial begin
        debug_inst_analy = 0;
    end

    always @(*) begin
        if (~en) begin
            jal_out = 64'b0;
            inst_addr = 64'b0;
            debug_inst_analy = 0;
        end
        else begin
            jal_out = pc;
            inst_addr = pc - 4 + imm;
            debug_inst_analy = 1;
        end
    end
endmodule;

module JALR (
    input en,
    input [63:0] pc, bus1, imm,
    input [2:0] funct3,
    output reg [63:0] jalr_out, inst_addr,

    output reg debug_inst_analy
);
    initial begin
        debug_inst_analy = 0;
    end

    always @(*) begin
        if (~en) begin
            jalr_out = 64'b0;
            inst_addr = 64'b0;
            debug_inst_analy = 0;
        end
        else begin
            case (funct3)
                3'b000: begin
                    jalr_out = pc;
                    inst_addr = (bus1 + imm) & ~(64'b1);
                    debug_inst_analy = 1;
                end
                default: begin
                    jalr_out = 64'b0;
                    inst_addr = 64'b0;
                    debug_inst_analy = 0;
                end
            endcase
        end
    end
endmodule;

module Branch (
    input en,
    input [63:0] pc, bus1, bus2, imm,
    input [2:0] funct3,
    output reg jump_en,
    output reg [63:0] inst_addr,

    output reg debug_inst_analy
);
    wire sless = ($signed(bus1)     <   $signed(bus2)   );
    wire uless = ($unsigned(bus1)   <   $unsigned(bus2) );
    wire equal = (bus1              ==  bus2            );

    wire less       = (funct3[LOGICINDEX_UNSIGNED])     ? uless         : sless     ;
    wire result_tmp = (funct3[LOGICINDEX_OPTYPE])       ? less          : equal     ;
    wire result     = (funct3[LOGICINDEX_INVERTFLAG])   ? ~result_tmp   : result_tmp;

    initial begin
        debug_inst_analy = 0;
    end

    always @(*) begin
        if (~en) begin
            jump_en = 0;
            inst_addr = 64'b0;
            debug_inst_analy = 0;
        end
        else begin
            jump_en = result;
            inst_addr = (result) ? pc - 4 + imm : 64'b0;
            debug_inst_analy = 1;
        end
    end
endmodule;
