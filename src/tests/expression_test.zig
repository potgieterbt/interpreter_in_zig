const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const print = std.debug.print;
const Token = @import("../token.zig").Token;
const Type = @import("../token.zig").Type;
const parser = @import("../parser.zig");
const lexer = @import("../lexer.zig");

pub fn TestIntegerExpression() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const input = "5;";

    const l = lexer.Lexer.init(input);
    var p = try parser.parser.init(alloc, l);

    const program = try p.ParseProgram();

    try checkParserErrors(p);

    if (program.Statements.items.len != 1) {
        print("Program Statements is too small to incluce expression: {any}\n", .{program.Statements.items});
        try testing.expectEqual(1, program.Statements.items.len);
    }

    const stmt = program.Statements.items[0].node.expressionStatement;

    const int = stmt.expression.integer_literal;

    try testing.expect(int.value == @as(i64, 5));
    try testing.expect(std.mem.eql(u8, int.token.literal, "5") == true);
    return 1;
}

pub fn TestIdentifierExpression() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const input = "foobar";

    const l = lexer.Lexer.init(input);
    var p = try parser.parser.init(alloc, l);

    const program = try p.ParseProgram();

    try checkParserErrors(p);

    if (program.Statements.items.len != 1) {
        print("Program Statements is too small to incluce expression: {any}\n", .{program.Statements.items});
        try testing.expectEqual(1, program.Statements.items.len);
    }

    const stmt = program.Statements.items[0].node.expressionStatement;

    const ident = stmt.expression.identifier;

    try testing.expect(std.mem.eql(u8, ident.value, "foobar") == true);
    try testing.expect(std.mem.eql(u8, ident.token.literal, "foobar") == true);
    return 1;
}

fn checkParserErrors(p: parser.parser) !void {
    if (p.errors.items.len != 0) std.log.err("\nparser had {any} errors \n", .{p.errors.items.len});
    for (p.errors.items) |err| std.log.err("{s}\n", .{err});
    try std.testing.expectEqual(@as(usize, 0), p.errors.items.len);
}
