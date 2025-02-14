const std = @import("std");
const testing = std.testing;
const lex_test = @import("lexer_test.zig");
const parser_test = @import("parser_test.zig");

// test "TestNextToken" {
//     try testing.expect(try lex_test.TestNextToken() == 1);
// }
//
// test "TestNextTokenEx2" {
//     try testing.expect(try lex_test.TestNextTokenEx2() == 1);
// }

test "TestParserLet" {
    try testing.expect(try parser_test.TestLetStatements() == 1);
}

test "TestParserRet" {
    try testing.expect(try parser_test.TestReturnStatements() == 1);
}
