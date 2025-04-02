import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LatexTestScreen extends StatefulWidget {
  const LatexTestScreen({super.key});

  @override
  State<LatexTestScreen> createState() => _LatexTestScreenState();
}

class _LatexTestScreenState extends State<LatexTestScreen> {
  final TextEditingController _latexController = TextEditingController();
  String _currentLatex = r'\begin{matrix} 1 & 2 & 3 \\ 4 & 5 & 6 \\ 7 & 8 & 9 \end{matrix}';

  @override
  void initState() {
    super.initState();
    _latexController.text = _currentLatex;
  }

  @override
  void dispose() {
    _latexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LaTeX测试'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '预设矩阵示例:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Math.tex(
                    _currentLatex,
                    textStyle: const TextStyle(fontSize: 24),
                    mathStyle: MathStyle.display,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '其他矩阵示例:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMatrixExample(
              r'\begin{matrix} a & b \\ c & d \end{matrix}',
              '2x2矩阵',
            ),
            _buildMatrixExample(
              r'\begin{pmatrix} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 0 & 0 & 1 \end{pmatrix}',
              '单位矩阵（带圆括号）',
            ),
            _buildMatrixExample(
              r'\begin{bmatrix} x_{11} & x_{12} \\ x_{21} & x_{22} \end{bmatrix}',
              '带下标的矩阵（方括号）',
            ),
            _buildMatrixExample(
              r'\begin{vmatrix} a & b \\ c & d \end{vmatrix}',
              '行列式',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _latexController,
              decoration: const InputDecoration(
                labelText: '输入LaTeX公式',
                border: OutlineInputBorder(),
                helperText: '输入LaTeX代码并点击测试按钮',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentLatex = _latexController.text;
                  });
                },
                child: const Text('测试公式'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixExample(String latex, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Center(
          child: Math.tex(
            latex,
            textStyle: const TextStyle(fontSize: 20),
            mathStyle: MathStyle.display,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
          ),
        ),
        onTap: () {
          setState(() {
            _latexController.text = latex;
            _currentLatex = latex;
          });
        },
      ),
    );
  }
} 