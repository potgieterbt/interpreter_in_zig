const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const print = std.debug.print;
const Token = @import("../token.zig").Token;
const Type = @import("../token.zig").Type;
const parser = @import("../parser.zig");
const lexer = @import("../lexer.zig");
const ast = @import("../ast.zig");

fn checkParserErrors(p: parser.parser) !void {
    if (p.errors.items.len != 0) std.log.err("\nparser had {any} errors \n", .{p.errors.items.len});
    for (p.errors.items) |err| std.log.err("{s}\n", .{err});
    try std.testing.expectEqual(@as(usize, 0), p.errors.items.len);
}

pub fn TestLetStatements() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    // const input =
    //     \\let x  5;
    //     \\let  = 10;
    //     \\let 838383;
    // ;
    const input =
        \\let x = 5;
        \\let y = 10;
        \\let foobar = 838383;
    ;

    const l = lexer.Lexer.init(input);
    var p = try parser.parser.init(alloc, l);

    const program = try p.ParseProgram();

    try checkParserErrors(p);

    if (program.Statements.items.len == 0) {
        // print("Program is empty: {any}\n", .{program.Statements.items});
        try testing.expectEqual(program.Statements.items.len, 1);
    }

    if (program.Statements.items.len != 3) {
        print("Program Statements is too small to incluce a let statement: {any}\n", .{program.Statements.items});
        try testing.expectEqual(@as(usize, 3), program.Statements.items.len);
    }

    const tests = [_]Token{
        Token{ .type = .LET, .literal = "x" },
        Token{ .type = .LET, .literal = "y" },
        Token{ .type = .LET, .literal = "foobar" },
    };

    print("{any}", .{program.Statements.items[0]});

    for (tests, 0..) |tt, i| {
        const stmt = program.Statements.items[i];
        try testing.expectEqual(tt.type, stmt.node.letStatement.token.type);
        try testing.expectEqualSlices(u8, tt.literal, stmt.node.letStatement.name.value);
    }
    return 1;
}

pub fn TestReturnStatements() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const input =
        \\return 5;
        \\return 10;
        \\return 993322;
    ;

    const l = lexer.Lexer.init(input);
    var p = parser.parser.init(alloc, l);

    const program = try p.ParseProgram();

    try checkParserErrors(p);

    if (program.Statements.items.len == 0) {
        print("Program is empty\n", .{});
        try testing.expectEqual(program.Statements.items.len, 1);
    }

    if (program.Statements.items.len != 3) {
        print("Program Statements is too small to incluce a let statement: {any}\n", .{program.Statements.items});
        try testing.expectEqual(3, program.Statements.items.len);
    }

    for (program.Statements.items) |stmt| {
        try testing.expectEqual(Type.RETURN, stmt.node.returnStatement.token.type);
    }
    return 1;
}
