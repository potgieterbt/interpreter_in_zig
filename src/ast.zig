const std = @import("std");
const Token = @import("token.zig").Token;

const Statements = enum {
    letStatement,
    returnStatement,
    expressionStatement,
};

pub const Program = struct {
    const Self = @This();
    Statements: std.ArrayList(Statement),

    pub fn init(alloc: std.mem.Allocator) Program {
        const p = Program{
            .Statements = std.ArrayList(Statement).init(alloc),
        };
        return p;
    }

    pub fn TokenLiteral(self: *Self) []const u8 {
        if (self.Statements.items.len > 0) {
            return self.Statements.items[self.Statements.items.len - 1].TokenLiteral();
        } else {
            return "";
        }
    }
};

pub const Node = union(Statements) {
    letStatement: LetStatement,
    returnStatement: ReturnStatement,
    expressionStatement: ExpressionStatement,
};

pub const Statement = struct {
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

pub const Expression = struct {
    token: Token,
    value: []const u8,
};

pub const Identifier = struct {
    const Self = @This();
    token: Token,
    value: []const u8,

    pub fn expressionNode() void {}

    pub fn TokenLiteral(self: *Self) []const u8 {
        return self.token.literal;
    }
};

pub const LetStatement = struct {
    const Self = @This();
    token: Token,
    name: Identifier,
    value: Expression,

    pub fn statementNode() void {}

    pub fn TokenLiteral(self: *Self) []const u8 {
        return self.token.literal;
    }
};
pub const ReturnStatement = struct {
    const Self = @This();
    token: Token,
    retVal: Expression,

    pub fn statementNode() void {}

    pub fn TokenLiteral(self: *Self) []const u8 {
        return self.token.literal;
    }
};
pub const ExpressionStatement = struct {};
