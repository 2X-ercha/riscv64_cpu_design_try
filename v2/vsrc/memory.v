module Memory (
    input clk, read_en, write_en,
    input [2:0] funct3,
    input [63:0] bus1, bus2, imm,
    output [63:0] mem_out,

    output debug_inst_analy
);
    reg debug_inst_read, debug_inst_write;
    reg [63:0] mem_read;

    wire [63:0] addr = bus1 + imm;

    initial begin
        debug_inst_read = 0;
        debug_inst_write = 0;
    end

    always @(posedge clk) begin
        if (~read_en) begin
            mem_read = 64'b0;
            debug_inst_read = 0;
        end
        else begin
            case (funct3[1:0])
                MEMFLAG_TYPE_BYTE   : mem_read = {56'b0 , readbyte(addr)};
                MEMFLAG_TYPE_HALF   : mem_read = {48'b0 , readhalf(addr)};
                MEMFLAG_TYPE_WORD   : mem_read = {32'b0 , readword(addr)};
                MEMFLAG_TYPE_DWORD  : mem_read = readdword(addr);
            endcase
            debug_inst_read = 1;
        end
    end

    always @(negedge clk) begin
        if (~write_en) begin
            debug_inst_write = 0;
        end
        else begin
            case (funct3[1:0])
                MEMFLAG_TYPE_BYTE   : writebyte(addr, bus2[7:0]);
                MEMFLAG_TYPE_HALF   : writehalf(addr, bus2[15:0]);
                MEMFLAG_TYPE_WORD   : writeword(addr, bus2[31:0]);
                MEMFLAG_TYPE_DWORD  : writedword(addr, bus2);
            endcase
            debug_inst_write = 1;
        end
    end

    assign mem_out = (funct3[MEMINDEX_UNSIGNED])        ? mem_read :
                     (funct3[1:0] == MEMFLAG_TYPE_BYTE) ? {{(56){mem_read[7]}}, mem_read[7:0]}   :
                     (funct3[1:0] == MEMFLAG_TYPE_HALF) ? {{(48){mem_read[15]}}, mem_read[15:0]} :
                     (funct3[1:0] == MEMFLAG_TYPE_WORD) ? {{(32){mem_read[31]}}, mem_read[31:0]} :
                                                          mem_read                               ;

    assign debug_inst_analy = debug_inst_read | debug_inst_write;
endmodule;
