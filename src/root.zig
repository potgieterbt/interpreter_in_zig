const std = @import("std");
const testing = std.testing;
const lex_test = @import("lexer_test.zig");
const parser_test = @import("parser_test.zig");

test "TestNextToken" {
    try testing.expect(try lex_test.TestNextToken() == 1);
}

test "TestNextTokenEx2" {
    try testing.expect(try lex_test.TestNextTokenEx2() == 1);
}

test "TestParser" {
    try testing.expect(try parser_test.parser_test() == 1);
}
