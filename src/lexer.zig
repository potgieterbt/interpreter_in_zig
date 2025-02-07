const std = @import("std");
const token = @import("token.zig");

const TokenError = error{
    UnknownToken,
};

pub const Lexer = struct {
    const Self = @This();

    _input: []const u8,
    position: usize = 0,
    readPosition: usize = 0,
    ch: u8 = 0,

    pub fn init(input: []const u8) Self {
        var lex = Self{
            ._input = input,
        };

        lex.readChar();

        return lex;
    }

    pub fn has_tokens(self: *Self) bool {
        return self.ch != 0;
    }

    pub fn readChar(self: *Self) void {
        if (self.readPosition >= self._input.len) {
            self.ch = 0;
        } else {
            self.ch = self._input[self.readPosition];
        }

        self.position = self.readPosition;
        self.readPosition += 1;
    }

    pub fn peekChar(self: *Self) u8 {
        if (self.readPosition >= self._input.len) {
            return 0;
        } else {
            return self._input[self.readPosition];
        }
    }

    fn isLetter(c: u8) bool {
        return std.ascii.isAlphabetic(c) or (c == '_');
    }

    fn isDigit(c: u8) bool {
        return std.ascii.isDigit(c);
    }

    fn readIdentifier(self: *Self) []const u8 {
        const position = self.position;
        while (isLetter(self.ch) == true) {
            self.readChar();
        }
        return self._input[position..self.position];
    }

    fn readInt(self: *Self) []const u8 {
        const position = self.position;
        while (isDigit(self.ch) == true) {
            self.readChar();
        }
        return self._input[position..self.position];
    }

    pub fn skipWhitespace(self: *Self) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.readChar();
        }
    }

    pub fn NextToken(self: *Self) !token.Token {
        self.skipWhitespace();

        const tok: token.Token = switch (self.ch) {
            '+' => token.Token{ .type = token.Type.PLUS, .literal = &[_]u8{self.ch} },
            '=' => blk: {
                if (self.peekChar() == '=') {
                    const chr = self.ch;
                    self.readChar();
                    break :blk token.Token{ .type = token.Type.EQ, .literal = &[_]u8{ chr, self.ch } };
                } else {
                    break :blk token.Token{ .type = token.Type.ASSIGN, .literal = &[_]u8{self.ch} };
                }
            },
            '-' => token.Token{ .type = token.Type.MINUS, .literal = &[_]u8{self.ch} },
            '!' => blk: {
                if (self.peekChar() == '=') {
                    const chr = self.ch;
                    self.readChar();
                    break :blk token.Token{ .type = token.Type.N_EQ, .literal = &[_]u8{ chr, self.ch } };
                } else {
                    break :blk token.Token{ .type = token.Type.BANG, .literal = &[_]u8{self.ch} };
                }
            },
            '/' => token.Token{ .type = token.Type.SLASH, .literal = &[_]u8{self.ch} },
            '*' => token.Token{ .type = token.Type.ASTRISK, .literal = &[_]u8{self.ch} },
            '<' => token.Token{ .type = token.Type.LT, .literal = &[_]u8{self.ch} },
            '>' => token.Token{ .type = token.Type.GT, .literal = &[_]u8{self.ch} },
            '(' => token.Token{ .type = token.Type.LPAREN, .literal = &[_]u8{self.ch} },
            ')' => token.Token{ .type = token.Type.RPAREN, .literal = &[_]u8{self.ch} },
            '{' => token.Token{ .type = token.Type.LBRACE, .literal = &[_]u8{self.ch} },
            '}' => token.Token{ .type = token.Type.RBRACE, .literal = &[_]u8{self.ch} },
            ',' => token.Token{ .type = token.Type.COMMA, .literal = &[_]u8{self.ch} },
            ';' => token.Token{ .type = token.Type.SEMICOLON, .literal = &[_]u8{self.ch} },
            0 => token.Token{ .type = token.Type.EOF, .literal = "" },
            'a'...'z', 'A'...'Z' => {
                const ident = self.readIdentifier();
                if (token.Token.keyword(ident)) |tok| {
                    return token.Token{ .type = tok, .literal = ident };
                }
                return token.Token{ .type = .IDENT, .literal = ident };
            },
            '0'...'9' => {
                const int = self.readInt();
                return token.Token{ .type = token.Type.INT, .literal = int };
            },
            else => token.Token{ .type = token.Type.ILLEGAL, .literal = "ILLEGAL" },
        };

        self.readChar();
        return tok;
    }
};
