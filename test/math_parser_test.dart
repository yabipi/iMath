import 'package:flutter_test/flutter_test.dart';
import 'package:imath/math/math_parser.dart';

void main() {
  group('MathParser', () {
    test('should parse simple inline math', () {
      final result = MathParser.parse('这是一个公式 \\(x^2\\) 的测试');
      expect(result.length, 3);
      expect(result[0].content, '这是一个公式 ');
      expect(result[0].isMath, false);
      expect(result[1].content, 'x^2');
      expect(result[1].isMath, true);
      expect(result[2].content, ' 的测试');
      expect(result[2].isMath, false);
    });

    test('should parse dollar math', () {
      final result = MathParser.parse('这是一个公式 \$x^2\$ 的测试');
      expect(result.length, 3);
      expect(result[0].content, '这是一个公式 ');
      expect(result[0].isMath, false);
      expect(result[1].content, 'x^2');
      expect(result[1].isMath, true);
      expect(result[2].content, ' 的测试');
      expect(result[2].isMath, false);
    });

    test('should parse inline math', () {
      final result = MathParser.parse(
          '设 \\( A = \\begin{bmatrix}1 & 0 & 0 & 0 \\\\-2 & 3 & 0 & 0 \\\\0 & -4 & 5 & 0 \\\\0 & 0 & -6 & 71 & 0 & 0 & 0 \\\\-1 & 2 & 0 & 0 \\\\0 & -2 & 3 & 0 \\\\0 & 0 & -3 & 4');
      expect(result.length, 2);
      expect(result[0].content, '设 ');
      expect(result[0].isMath, false);
    });

    test('should parse environment math', () {
      final result =
          MathParser.parse('这是一个公式 \\begin{equation}x^2\\end{equation} 的测试');
      expect(result.length, 3);
      expect(result[0].content, '这是一个公式 ');
      expect(result[0].isMath, false);
      expect(result[1].content, '\\begin{equation}x^2\\end{equation}');
      expect(result[1].isMath, true);
      expect(result[1].environment, 'equation');
      expect(result[2].content, ' 的测试');
      expect(result[2].isMath, false);
    });

    test('should parse matrix environment', () {
      final result = MathParser.parse(
          '这是一个矩阵 \\begin{matrix}1 & 2 \\\\ 3 & 4\\end{matrix} 的测试');
      expect(result.length, 3);
      expect(result[0].content, '这是一个矩阵 ');
      expect(result[0].isMath, false);
      expect(result[1].content, '\\begin{matrix}1 & 2 \\\\ 3 & 4\\end{matrix}');
      expect(result[1].isMath, true);
      expect(result[1].environment, 'matrix');
      expect(result[2].content, ' 的测试');
      expect(result[2].isMath, false);
    });

    test('should parse pmatrix environment', () {
      final result = MathParser.parse(
          '这是一个带括号的矩阵 \\begin{pmatrix}1 & 2 \\\\ 3 & 4\\end{pmatrix} 的测试');
      expect(result.length, 3);
      expect(result[0].content, '这是一个带括号的矩阵 ');
      expect(result[0].isMath, false);
      expect(
          result[1].content, '\\begin{pmatrix}1 & 2 \\\\ 3 & 4\\end{pmatrix}');
      expect(result[1].isMath, true);
      expect(result[1].environment, 'pmatrix');
      expect(result[2].content, ' 的测试');
      expect(result[2].isMath, false);
    });

    test('should parse bmatrix environment', () {
      final result = MathParser.parse(
          '这是一个带方括号的矩阵 \\begin{bmatrix}1 & 2 \\\\ 3 & 4\\end{bmatrix} 的测试');
      expect(result.length, 3);
      expect(result[0].content, '这是一个带方括号的矩阵 ');
      expect(result[0].isMath, false);
      expect(
          result[1].content, '\\begin{bmatrix}1 & 2 \\\\ 3 & 4\\end{bmatrix}');
      expect(result[1].isMath, true);
      expect(result[1].environment, 'bmatrix');
      expect(result[2].content, ' 的测试');
      expect(result[2].isMath, false);
    });

    test('should parse multiple math expressions', () {
      final result = MathParser.parse(
          '公式1 \\(x^2\\) 公式2 \$y^2\$ 公式3 \\begin{equation}z^2\\end{equation}');
      expect(result.length, 5);
      expect(result[0].content, '公式1 ');
      expect(result[0].isMath, false);
      expect(result[1].content, 'x^2');
      expect(result[1].isMath, true);
      expect(result[2].content, ' 公式2 ');
      expect(result[2].isMath, false);
      expect(result[3].content, 'y^2');
      expect(result[3].isMath, true);
      expect(result[4].content, ' 公式3 ');
      expect(result[4].isMath, false);
      expect(result[5].content, '\\begin{equation}z^2\\end{equation}');
      expect(result[5].isMath, true);
      expect(result[5].environment, 'equation');
    });

    test('should throw on unmatched math delimiters', () {
      expect(() => MathParser.parse('这是一个公式 \\(x^2'), throwsException);
      expect(() => MathParser.parse('这是一个公式 \$x^2'), throwsException);
      expect(() => MathParser.parse('这是一个公式 \\begin{equation}x^2'),
          throwsException);
      expect(() => MathParser.parse('这是一个矩阵 \\begin{matrix}1 & 2'),
          throwsException);
    });

    test('should handle nested math expressions', () {
      final result = MathParser.parse(
          '公式1 \\(x^2 + \$y^2\$ + \\begin{equation}z^2\\end{equation}\\)');
      expect(result.length, 1);
      expect(result[0].content, '公式1 ');
      expect(result[0].isMath, false);
      expect(result[1].content,
          'x^2 + \$y^2\$ + \\begin{equation}z^2\\end{equation}');
      expect(result[1].isMath, true);
    });

    test('should handle empty input', () {
      final result = MathParser.parse('');
      expect(result.length, 0);
    });

    test('should handle text without math', () {
      final result = MathParser.parse('这是一个没有数学公式的文本');
      expect(result.length, 1);
      expect(result[0].content, '这是一个没有数学公式的文本');
      expect(result[0].isMath, false);
    });
  });
}
