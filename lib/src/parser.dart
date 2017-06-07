import 'ast.dart';
import 'exception.dart';
import 'token.dart';

class Parser {
  Token _current;
  int _index = -1;
  final List<Token> tokens;

  Parser(this.tokens);

  Token get current {
    if (_index < 0 || _index > tokens.length - 1) return null;
    return _current ?? (_current = tokens[_index]);
  }

  JsonxException _expected(String type) =>
      new JsonxException(null, 'expected \'$type\', found ${current?.type}');

  bool next(TokenType type) {
    if (_index < tokens.length - 1 && tokens[_index + 1].type == type) {
      _index++;
      _current = null;
      return true;
    }
    return false;
  }

  Node parseExpression() {
    return parseArray() ??
        parseObject() ??
        parseString() ??
        parseNumber() ??
        parseTrue() ??
        parseFalse() ??
        parseNull();
  }

  Node parseArray() {
    if (next(TokenType.LBRACKET)) {
      var expr = parseExpression();

      if (next(TokenType.RBRACKET)) {
        return new Node(NodeType.ARRAY, children: expr != null ? [expr] : []);
      }

      List<Node> c = [];

      while (expr != null) {
        c.add(expr);
        if (next(TokenType.RBRACKET))
          return new Node(NodeType.ARRAY, children: c);
        if (!next(TokenType.COMMA)) throw _expected(',');
        expr = parseExpression();
      }

      throw _expected(']');
    } else
      return null;
  }

  Node parseObject() {
    if (next(TokenType.LBRACE)) {
      var kv = parseKeyValuePair();

      if (next(TokenType.RBRACE)) {
        return new Node(NodeType.OBJECT, children: kv != null ? [kv] : []);
      }

      List<Node> c = [];

      while (kv != null) {
        c.add(kv);
        if (next(TokenType.RBRACE))
          return new Node(NodeType.OBJECT, children: c);
        if (!next(TokenType.COMMA)) throw _expected(',');
        kv = parseKeyValuePair();
      }

      throw _expected('}');
    } else
      return null;
  }

  Node parseKeyValuePair() {
    var string = parseString();

    if (string == null)
      return null;
    else if (!(next(TokenType.COLON)))
      throw _expected(':');
    else {
      var expr = parseExpression();
      if (expr == null) throw new JsonxException(null, 'expected expression');
      return new Node(NodeType.KEY_VALUE_PAIR, children: [string, expr]);
    }
  }

  Node parseString() {
    if (next(TokenType.STRING))
      return new Node(NodeType.STRING, text: current.text);
    else
      return null;
  }

  Node parseNumber() {
    if (next(TokenType.NUMBER))
      return new Node(NodeType.NUMBER, text: current.text);
    else
      return null;
  }

  Node parseTrue() {
    if (next(TokenType.TRUE))
      return new Node(NodeType.TRUE);
    else
      return null;
  }

  Node parseFalse() {
    if (next(TokenType.FALSE))
      return new Node(NodeType.FALSE);
    else
      return null;
  }

  Node parseNull() {
    if (next(TokenType.NULL))
      return new Node(NodeType.NULL);
    else
      return null;
  }
}
