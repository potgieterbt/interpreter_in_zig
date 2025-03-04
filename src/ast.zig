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

        for (self.Statements.items, 0..) |s, i| {
            _ = s;
            var stmt = self.Statements.items[i];
            switch (stmt.node) {
                .letStatement => try std.fmt.format(self.stringBuf.items[self.stringBuf.items.len - 1].writer(), "{s}", .{try stmt.node.letStatement.String()}),
                .expressionStatement => {
                    try std.fmt.format(self.stringBuf.items[self.stringBuf.items.len - 1].writer(), "{s}", .{try stmt.node.expressionStatement.String()});
                    switch (stmt.node.expressionStatement.expression) {
                        .identifier => try std.fmt.format(self.stringBuf.items[self.stringBuf.items.len - 1].writer(), "{s}", .{try stmt.node.expressionStatement.expression.identifier.String()}),
                        .integer_literal => try std.fmt.format(self.stringBuf.items[self.stringBuf.items.len - 1].writer(), "{s}", .{try stmt.node.expressionStatement.expression.integer_literal.String()}),
                    }
                },
                .returnStatement => try std.fmt.format(self.stringBuf.items[self.stringBuf.items.len - 1].writer(), "{s}", .{try stmt.node.returnStatement.String()}),
            }
        }
        return self.stringBuf.items[0].toOwnedSlice();
    }
};

pub const Node = union(Statements) {
    const Self = @This();
    letStatement: LetStatement,
    returnStatement: ReturnStatement,
    expressionStatement: ExpressionStatement,
};

pub const ExpressionStatement = struct {
    const Self = @This();
    alloc: std.mem.Allocator,
    token: Token,
    expression: Expression,

    pub fn String(self: *Self) ![]u8 {
        _ = self;
        return "";
    }
};

pub const IntegerLiteral = struct {
    const Self = @This();
    token: Token,
    value: i64,

    pub fn String(self: *Self) !i64 {
        return self.token.literal;
    }
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

pub const Expression = union(enum) {
    identifier: Identifier,
    integer_literal: IntegerLiteral,
};

pub const Identifier = struct {
    const Self = @This();
    token: Token,
    value: []const u8,

    pub fn expressionNode() void {}

    pub fn TokenLiteral(self: *Self) []const u8 {
        return self.token.literal;
    }

    pub fn String(self: *Self) ![]u8 {
        return self.value;
    }
};

pub const LetStatement = struct {
    const Self = @This();
    token: Token,
    name: Identifier,
    value: Expression,
    alloc: std.mem.Allocator,

    pub fn statementNode() void {}

    pub fn TokenLiteral(self: *Self) []const u8 {
        return self.token.literal;
    }

    pub fn String(self: *Self) ![]u8 {
        var msg = std.ArrayList(u8).init(self.alloc);

        try std.fmt.format(msg.writer(), "{s} {s} = {s};", .{ self.TokenLiteral(), self.name.value, self.value.value });
        return msg.toOwnedSlice();
    }
};

pub const ReturnStatement = struct {
    const Self = @This();
    token: Token,
    retVal: Expression,
    alloc: std.mem.Allocator,

    pub fn statementNode() void {}

    pub fn TokenLiteral(self: *Self) []const u8 {
        return self.token.literal;
    }

    pub fn String(self: *Self) ![]u8 {
        var msg = std.ArrayList(u8).init(self.alloc);

        try std.fmt.format(msg.writer(), "{s} {s};", .{ self.TokenLiteral(), self.retVal.value });
        return msg.toOwnedSlice();
    }
};

// pub const ExpressionStatement = struct {
//     const Self = @This();
//     token: Token,
//     expression: Expression,
//     alloc: std.mem.Allocator,
//
//     pub fn statementNode(self: *Self) void {
//         _ = self;
//         return;
//     }
//
//     pub fn TokenLiteral(self: *Self) []const u8 {
//         return self.token.literal;
//     }
//
//     pub fn String(self: *Self) ![]u8 {
//         // var msg = std.ArrayList(u8).init(self.alloc);
//         //
//         // try std.fmt.format(msg.writer(), "{s} {s} = {s}", .{ self.TokenLiteral(), self.name.value, self.value.value });
//         // return msg.toOwnedSlice();
//         if (self.expression.String()) {
//             return self.expression.String();
//         }
//         return "";
//     }
// };
