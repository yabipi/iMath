import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';

const texHtml = r"""
<tex>i\hbar\frac{\partial}{\partial t}\Psi(\vec x,t) = -\frac{\hbar}{2m}\nabla^2\Psi(\vec x,t)+ V(\vec x)\Psi(\vec x,t)</tex>
<br><br>
<tex>\zeta(s)</tex>函数:
<tex>\zeta(s) = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \frac{1}{4^s} + \cdots。</tex>
非平凡零点（在此情况下是指 s  不为 <tex>(-2, -4, -6\cdots)</tex> 等点的值）的实数部分是 <tex>\frac{1}{2}</tex>
<br><br>
求和：
<tex>M(x)=\sum_{n \leq x}\mu(n)</tex>
<br><br>
<tex>\sum_{n=1}^\infty\frac{1}{n^2} = 1 + \frac{1}{2^2} + \frac{1}{3^2} + \dots + \frac{1}{n^2} = \frac{\pi^2}{6}</tex>
<br><br>
求积分：
<tex>\int_0^\infty \frac{x^2}{e^x-1}dx</tex>
<br><br>
求微分：
<tex>\frac{d}{dx}\left(\frac{x}{e^x}\right)</tex>
<br><br>

傅里叶转换：
<tex>\begin{aligned}
\hat{F}(k) &= \int_{-\infty}^{\infty} f(x) e^{-i k x} d x \\
f(x) &= \frac{1}{2 \pi} \int_{-\infty}^{\infty} \hat{F}(k) e^{i k x} d k
\end{aligned}</tex>
""";

class HtmlTexScreen extends StatefulWidget {
  const HtmlTexScreen({super.key});

  @override
  State<HtmlTexScreen> createState() => _HtmlTexScreenState();
}

class _HtmlTexScreenState extends State<HtmlTexScreen> {
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
        title: const Text('Html Math测试'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Html(
              data: texHtml,
              extensions: [
                TagExtension(
                    tagsToExtend: {"tex"},
                    builder: (extensionContext) {
                      return Math.tex(
                        extensionContext.innerHtml,
                        mathStyle: MathStyle.display,
                        textStyle: extensionContext.styledElement?.style.generateTextStyle(),
                        onErrorFallback: (FlutterMathException e) {
                          //optionally try and correct the Tex string here
                          return Text(e.message);
                        },
                      );
                    }
                ),
              ],
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