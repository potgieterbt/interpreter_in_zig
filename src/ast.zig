const std = @import("std");
const Token = @import("token.zig").Token;

const Statements = enum {
    letStatement,
    returnStatement,
    expressionStatement,
};

pub const Program = struct {
    const Self = @This();
    alloc: std.mem.Allocator,
    Statements: std.ArrayList(Statement),
    stringBuf: std.ArrayList(std.ArrayList(u8)),

    pub fn init(alloc: std.mem.Allocator) Program {
        const p = Program{
            .alloc = alloc,
            .Statements = std.ArrayList(Statement).init(alloc),
            .stringBuf = std.ArrayList(std.ArrayList(u8)).init(alloc),
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

    pub fn String(self: *Self) ![]const u8 {
        const msg = std.ArrayList(u8).init(self.alloc);

        try self.stringBuf.append(msg);

        for (self.Statements.items, 0..) |stmt, i| {
            _ = i;
            try std.fmt.format(self.stringBuf.items[self.stringBuf.items.len - 1].writer(), "{s}", .{stmt.String()});
        }
        return self.stringBuf.items[0].toOwnedSlice();
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

    pub fn String(self: *Self) []const u8 {
        switch (self.node) {
            .letStatement => {
                return "";
            },
            .returnStatement => {
                return "";
            },
            .expressionStatement => {
                return "";
            },
            else => {
                return "";
            },
        }
    }

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

    pub fn string(self: *Self) []const u8 {
        _ = self;
        return "";
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
pub const ExpressionStatement = struct {
    const Self = @This();
    token: Token,
    expression: Expression,

    pub fn statementNode(self: *Self) void {
        _ = self;
        return;
    }

    pub fn TokenLiteral(self: *Self) []const u8 {
        return self.token.literal;
    }
};
