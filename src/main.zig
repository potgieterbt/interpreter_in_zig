const std = @import("std");
const lexer = @import("lexer.zig");
const repl = @import("repl.zig");

pub fn main() !void {
    try repl.main();
}
