const std = @import("std");
const Token = @import("token.zig").Token;
const Type = @import("token.zig").Type;
const Lexer = @import("lexer.zig").Lexer;
const ast = @import("ast.zig");

pub const parser = struct {
    const Self = @This();

    const ParseErr = error{
        OutOfMemory,
        Overflow,
        InvalidCharacter,
    };

    alloc: std.mem.Allocator,
    lex: Lexer,
    curToken: Token,
    peekToken: Token,
    program: ast.Program,
    errors: std.ArrayList([]const u8),

    const Precedence = enum {
        LOWEST,
        EQUALS,
        LESSGREATER,
        SUM,
        PRODUCT,
        PREFIX,
        CALL,
    };

    const prefix_fn = *const (fn (*parser) ParseErr!?ast.Expression);
    const infix_fn = *const (fn (*parser, ast.Expression) ParseErr!?ast.Expression);

    const prefixParseFns = std.StaticStringMap(prefix_fn).initComptime(.{
        .{ @tagName(.IDENT), parser.parseIdentifier },
        .{ @tagName(.INT), parser.parseInteger },
        .{ @tagName(.BANG), parser.parsePrefixExpression },
        .{ @tagName(.MINUS), parser.parsePrefixExpression },
    });

    const infixParseFns = std.StaticStringMap(infix_fn).initComptime(.{});

    pub fn init(alloc: std.mem.Allocator, lex: Lexer) !parser {
        var p = parser{
            .alloc = alloc,
            .curToken = undefined,
            .peekToken = undefined,
            .lex = lex,
            .program = ast.Program.init(alloc),
            .errors = std.ArrayList([]const u8).init(alloc),
        };

        p.NextToken();
        p.NextToken();
        return p;
    }

    pub fn Errors(self: *Self) *std.ArrayList([]const u8) {
        return &self.errors;
    }

    pub fn peekError(self: *Self, t: Type) !void {
        const msg = try std.fmt.allocPrint(self.alloc, "expected next token to be {any}, got {any} indtead\n", .{ t, self.peekToken.type });
        try self.errors.append(msg);
    }

    pub fn NextToken(self: *Self) void {
        self.curToken = self.peekToken;
        self.peekToken = try self.lex.NextToken();
    }

    pub fn ParseProgram(self: *Self) !*ast.Program {
        while (self.curToken.type != Type.EOF) {
            if (try self.parseStatement()) |stmt| {
                try self.program.Statements.append(stmt);
            }
            self.NextToken();
        }

        return &self.program;
    }

    pub fn parseStatement(self: *Self) !?ast.Statement {
        switch (self.curToken.type) {
            Type.LET => {
                if (try self.parseLetStatement()) |letStatement| {
                    return ast.Statement{ .node = ast.Node{ .letStatement = letStatement } };
                }
                return null;
            },
            Type.RETURN => {
                if (try self.parseReturnStatement()) |returnStatement| {
                    return ast.Statement{ .node = ast.Node{ .returnStatement = returnStatement } };
                }
                return null;
            },
            // Type.IF => {
            //     if (self.parseIfStatement()) |ifStatement| {
            //         return ast.Statement{ .node = ast.Node{ .returnStatement = ifStatement } };
            //     }
            //     return null;
            // },
            else => {
                if (try self.parseExpressionStatement()) |expressionStatement| {
                    return ast.Statement{ .node = .{ .expressionStatement = expressionStatement } };
                }
                return null;
            },
        }
    }

    pub fn parseLetStatement(self: *Self) !?ast.LetStatement {
        var stmt = ast.LetStatement{ .token = Token{
            .type = self.curToken.type,
            .literal = self.curToken.literal,
        }, .name = undefined, .value = undefined, .alloc = self.alloc };

        if (!try self.expectPeek(Type.IDENT)) {
            return null;
        }

        stmt.name = ast.Identifier{ .token = Token{ .type = self.curToken.type, .literal = self.curToken.literal }, .value = self.curToken.literal };

        if (!try self.expectPeek(Type.ASSIGN)) {
            return null;
        }

        // TODO parse expression
        while (!self.curTokenIs(Type.SEMICOLON)) {
            self.NextToken();
        }

        return stmt;
    }

    pub fn parseReturnStatement(self: *Self) !?ast.ReturnStatement {
        const stmt = ast.ReturnStatement{
            .token = Token{
                .type = self.curToken.type,
                .literal = self.curToken.literal,
            },
            .retVal = undefined,
            .alloc = self.alloc,
        };

        // TODO parse expression
        while (!self.curTokenIs(Type.SEMICOLON)) {
            self.NextToken();
        }

        return stmt;
    }

    pub fn parseExpressionStatement(self: *Self) !?ast.ExpressionStatement {
        const stmt = ast.ExpressionStatement{
            .alloc = self.alloc,
            .token = self.curToken,
            .expression = (try self.parseExpression(.LOWEST)).?.*,
        };

        if (self.peekTokenIs(Type.SEMICOLON)) {
            self.NextToken();
        }

        return stmt;
    }

    pub fn noPrefixFnError(self: *Self, tok: Token) !void {
        const msg = try std.fmt.allocPrint(self.alloc, "no prefix parse function for '{s}' found", .{@tagName(tok.type)});
        std.debug.print("no prefix parse function for '{s}' found", .{@tagName(tok.type)});
        try self.errors.append(msg);
    }

    pub fn parseExpression(self: *Self, prec: Precedence) !?*const ast.Expression {
        _ = prec;
        const prefix_maybe = parser.prefixParseFns.get(@tagName(self.curToken.type));
        if (prefix_maybe == null) {
            try self.noPrefixFnError(self.curToken);
            return null;
        }
        const prefix = prefix_maybe.?;

        const left_expr = try prefix(self);
        // while (true) {}

        return &left_expr.?;
    }

    pub fn parseIdentifier(self: *parser) error{OutOfMemory}!?ast.Expression {
        return ast.Expression{ .identifier = .{
            .token = self.curToken,
            .value = self.curToken.literal,
        } };
    }

    pub fn parseInteger(self: *parser) error{ OutOfMemory, Overflow, InvalidCharacter }!?ast.Expression {
        return ast.Expression{
            .integer_literal = .{
                .token = self.curToken,
                .value = try std.fmt.parseInt(i64, self.curToken.literal, 10),
            },
        };
    }

    pub fn parsePrefixExpression(self: *parser) error{ OutOfMemory, Overflow, InvalidCharacter }!?ast.Expression {
        var exp = ast.Expression{
            .prefix_expression = .{
                .operator = self.curToken.literal,
                .token = self.curToken,
                .right = undefined,
            },
        };

        self.NextToken();

        exp.prefix_expression.right = (try self.parseExpression(.PREFIX)).?;
        return exp;
    }

    pub fn peekTokenIs(self: *Self, t: Type) bool {
        return self.peekToken.type == t;
    }
    pub fn curTokenIs(self: *Self, t: Type) bool {
        return self.curToken.type == t;
    }
    pub fn expectPeek(self: *Self, t: Type) !bool {
        if (self.peekTokenIs(t)) {
            self.NextToken();
            return true;
        } else {
            try self.peekError(t);
            return false;
        }
    }
};
