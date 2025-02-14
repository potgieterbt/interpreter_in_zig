const std = @import("std");

const mem = std.mem;
const testing = std.testing;
const print = std.debug.print;

const token = @import("../token.zig");
const Lexer = @import("../lexer.zig").Lexer;

pub fn TestNextToken() !u8 {
    const input = "=+(){},;";

    const tests = [_]token.Token{
        token.Token{ .type = .ASSIGN, .literal = "" },
        token.Token{ .type = .PLUS, .literal = "" },
        token.Token{ .type = .LPAREN, .literal = "" },
        token.Token{ .type = .RPAREN, .literal = "" },
        token.Token{ .type = .LBRACE, .literal = "" },
        token.Token{ .type = .RBRACE, .literal = "" },
        token.Token{ .type = .COMMA, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },
        token.Token{ .type = .EOF, .literal = "" },
    };

    var lex = Lexer.init(input);

    for (tests) |tt| {
        const tok = try lex.NextToken();

        try testing.expectEqual(tt.type, tok.type);
    }
    return 1;
}

pub fn TestNextTokenEx2() !u8 {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\let add = fn(x, y) {
        \\x + y;
        \\};
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
        \\if (5 < 10) {
        \\return true;
        \\} else {
        \\return false;
        \\}
        \\10 == 10;
        \\10 != 9;
    ;

    const tests = [_]token.Token{
        token.Token{ .type = .LET, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .ASSIGN, .literal = "" },
        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },

        token.Token{ .type = .LET, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .ASSIGN, .literal = "" },
        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },

        token.Token{ .type = .LET, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .ASSIGN, .literal = "" },
        token.Token{ .type = .FUNCTION, .literal = "" },
        token.Token{ .type = .LPAREN, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .COMMA, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .RPAREN, .literal = "" },
        token.Token{ .type = .LBRACE, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .PLUS, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },
        token.Token{ .type = .RBRACE, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },

        token.Token{ .type = .LET, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .ASSIGN, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .LPAREN, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .COMMA, .literal = "" },
        token.Token{ .type = .IDENT, .literal = "" },
        token.Token{ .type = .RPAREN, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },

        token.Token{ .type = .BANG, .literal = "" },
        token.Token{ .type = .MINUS, .literal = "" },
        token.Token{ .type = .SLASH, .literal = "" },
        token.Token{ .type = .ASTRISK, .literal = "" },
        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },

        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .LT, .literal = "" },
        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .GT, .literal = "" },
        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },

        token.Token{ .type = .IF, .literal = "" },
        token.Token{ .type = .LPAREN, .literal = "" },
        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .LT, .literal = "" },
        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .RPAREN, .literal = "" },
        token.Token{ .type = .LBRACE, .literal = "" },
        token.Token{ .type = .RETURN, .literal = "" },
        token.Token{ .type = .TRUE, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },

        token.Token{ .type = .RBRACE, .literal = "" },
        token.Token{ .type = .ELSE, .literal = "" },
        token.Token{ .type = .LBRACE, .literal = "" },

        token.Token{ .type = .RETURN, .literal = "" },
        token.Token{ .type = .FALSE, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },
        token.Token{ .type = .RBRACE, .literal = "" },

        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .EQ, .literal = "" },
        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },

        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .N_EQ, .literal = "" },
        token.Token{ .type = .INT, .literal = "" },
        token.Token{ .type = .SEMICOLON, .literal = "" },

        token.Token{ .type = .EOF, .literal = "" },
    };

    var lex = Lexer.init(input);

    for (tests) |tt| {
        const tok = try lex.NextToken();

        print("{any}\n", .{tok});
        try testing.expectEqualDeep(tt.type, tok.type);
        // try testing.expectEqual(tok.literal, tt.literal);
        // user mem.eql
    }
    return 1;
}
