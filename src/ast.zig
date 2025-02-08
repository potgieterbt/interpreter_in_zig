const std = @import("std");
const Token = @import("token.zig").Token;

const Statements = enum {
    letStatement,
    returnStatement,
    expressionStatement,
};

const Program = struct {
    const Self = @This();
    Statements: std.ArrayList(Statement),

    pub fn TokenLiteral(self: *Self) []const u8 {
        if (self.Statements.items.len > 0) {
            return self.Statements.items[self.Statements.items.len - 1].TokenLiteral();
        } else {
            return "";
        }
    }
};

const Node = union(Statements) {
    letStatement: LetStatement,
    returnStatement: ReturnStatement,
    expressionStatement: ExpressionStatement,
};

const Statement = struct {
    const Self = *@This();
    node: Node,

    pub fn TokenLiteral(self: *Self) []const u8 {
        switch (self.node) {
            .letStatement => |content| {
                return content.token.literal;
            },
        }
    }
};

const Expression = struct {
    token: Token,
    value: []const u8,
};

pub const LetStatement = struct {};
pub const ReturnStatement = struct {};
pub const ExpressionStatement = struct {};
