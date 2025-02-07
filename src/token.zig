const std = @import("std");

pub const Type = enum {
    ILLEGAL,
    EOF,

    IDENT,
    INT,

    ASSIGN,
    PLUS,
    MINUS,
    BANG,
    ASTRISK,
    SLASH,

    LT,
    GT,

    EQ,
    N_EQ,

    COMMA,
    SEMICOLON,

    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,

    FUNCTION,
    LET,
    TRUE,
    FALSE,
    IF,
    ELSE,
    RETURN,
};

pub const Token = struct {
    type: Type,
    literal: []const u8,

    pub fn keyword(ident: []const u8) ?Type {
        const map = std.StaticStringMap(Type).initComptime(.{
            .{ "let", .LET },
            .{ "fn", .FUNCTION },
            .{ "true", .TRUE },
            .{ "false", .FALSE },
            .{ "if", .IF },
            .{ "else", .ELSE },
            .{ "return", .RETURN },
        });
        return map.get(ident);
    }
};
