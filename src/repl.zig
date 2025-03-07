const std = @import("std");
const lexer = @import("lexer.zig");

pub fn main() !void {
    var reader = std.io.getStdIn().reader();

    var buffer: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var lex = lexer.Lexer.init(line);
        while (lex.has_tokens()) {
            const token = lex.NextToken();
            std.debug.print("{any}\n", .{token});
        }
    }
}
