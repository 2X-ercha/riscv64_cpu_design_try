module half_adder (
    input a, b,
    output s, cout
);
    assign cout = a & b;
    assign s    = a ^ b;
endmodule;

module compressor_3to2 (
    input  a, b, cin,
    output s, cout
);
    assign cout = (a & b) | (a & cin) | (b & cin);
    assign s    = a ^ b ^ cin;
endmodule;

module compressor_4to2 (
    input  a, b, c, d, cin,
    output s, co, cout
);
    wire tmp1 = (a & b) | (c & d);
    wire tmp2 = (a ^ b) ^ (c ^ d);

    assign cout = (a | b) & (c | d);
    assign co   = ~(~tmp1 | tmp2) | (tmp2 & cin);
    assign s    = tmp2 ^ cin;
endmodule;
