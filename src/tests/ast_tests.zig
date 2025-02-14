const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const print = std.debug.print;
const Token = @import("../token.zig").Token;
const Type = @import("../token.zig").Type;
const parser = @import("../parser.zig");
const lexer = @import("../lexer.zig");
const ast = @import("../ast.zig");

pub fn StringTest() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const node1 = ast.Statement{
        .node = .{ .letStatement = ast.LetStatement{
            .token = Token{ .type = .LET, .literal = "let" },
            .name = ast.Identifier{
                .token = Token{ .type = .IDENT, .literal = "myVar" },
                .value = "myVar",
            },
            .value = ast.Expression{
                .token = Token{
                    .type = .IDENT,
                    .literal = "anotherVar",
                },
                .value = "anotherVar",
            },
        } },
    };

    var program = ast.Program.init(alloc);
    try program.Statements.append(node1);

    if (!std.mem.eql(u8, try program.String(), "let myVar = anotherVar")) {
        std.log.err("\nprogram.String() wrong, got={any}\n", .{program.String()});
    }
    return 1;
}
