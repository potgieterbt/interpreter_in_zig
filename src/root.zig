const std = @import("std");
const testing = std.testing;
const lex_test = @import("tests/lexer_test.zig");
const parser_test = @import("tests/parser_test.zig");
const ast_test = @import("tests/ast_tests.zig");
const express_test = @import("tests/expression_test.zig");

// test "TestNextToken" {
//     try testing.expect(try lex_test.TestNextToken() == 1);
// }
//
// test "TestNextTokenEx2" {
//     try testing.expect(try lex_test.TestNextTokenEx2() == 1);
// }
//
// test "TestParserLet" {
//     try testing.expect(try parser_test.TestLetStatements() == 1);
// }
//
// test "TestParserRet" {
//     try testing.expect(try parser_test.TestReturnStatements() == 1);
// }
//
// test "StringTest" {
//     try testing.expect(try ast_test.StringTest() == 1);
// }

test "IdentifierExpressionTest" {
    try testing.expect(try express_test.TestIdentifierExpression() == 1);
}

test "IdentifierIntegerTest" {
    try testing.expect(try express_test.TestIntegerExpression() == 1);
}
