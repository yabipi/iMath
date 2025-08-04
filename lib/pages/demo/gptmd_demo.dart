/**
 *
 */
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

const json = {
  "id": 49,
  "title": "双曲函数",
  "subtitle": "与双曲线（而非圆）相关的函数，类似于三角函数（圆函数）",
  "type": 0,
  "weight": 0,
  "author": "",
  "level": "高等数学",
  "branch": "函数论",
  "introduction": "",
  "content": "### **双曲函数（Hyperbolic Functions）及其应用**\n\n双曲函数是一类与双曲线（而非圆）相关的函数，类似于三角函数（圆函数），但在性质和应用上有显著差异。它们在数学、物理、工程等领域有广泛的应用。\n\n---\n\n## **1. 双曲函数的定义**\n双曲函数可以通过指数函数 \\( e^x \\) 定义，主要包括以下六种：\n\n### **(1) 双曲正弦（Hyperbolic Sine）**\n\\[\n\\sinh x = \\frac{e^x - e^{-x}}{2}\n\\]\n\n### **(2) 双曲余弦（Hyperbolic Cosine）**\n\\[\n\\cosh x = \\frac{e^x + e^{-x}}{2}\n\\]\n\n### **(3) 双曲正切（Hyperbolic Tangent）**\n\\[\n\\tanh x = \\frac{\\sinh x}{\\cosh x} = \\frac{e^x - e^{-x}}{e^x + e^{-x}}\n\\]\n\n### **(4) 双曲余切（Hyperbolic Cotangent）**\n\\[\n\\coth x = \\frac{\\cosh x}{\\sinh x} = \\frac{e^x + e^{-x}}{e^x - e^{-x}}\n\\]\n\n### **(5) 双曲正割（Hyperbolic Secant）**\n\\[\n\\operatorname{sech} x = \\frac{1}{\\cosh x} = \\frac{2}{e^x + e^{-x}}\n\\]\n\n### **(6) 双曲余割（Hyperbolic Cosecant）**\n\\[\n\\operatorname{csch} x = \\frac{1}{\\sinh x} = \\frac{2}{e^x - e^{-x}}\n\\]\n\n---\n\n## **2. 双曲函数的基本性质**\n### **(1) 与三角函数的关系**\n双曲函数与三角函数在形式上相似，但符号不同：\n- **欧拉公式**：\n  \\[\n  e^{ix} = \\cos x + i \\sin x\n  \\]\n- **双曲欧拉公式**：\n  \\[\n  e^{x} = \\cosh x + \\sinh x\n  \\]\n\n### **(2) 恒等式**\n- **基本恒等式**：\n  \\[\n  \\cosh^2 x - \\sinh^2 x = 1\n  \\]\n  （对比三角恒等式 \\( \\cos^2 x + \\sin^2 x = 1 \\)）\n- **加法公式**：\n  \\[\n  \\sinh(x + y) = \\sinh x \\cosh y + \\cosh x \\sinh y\n  \\]\n  \\[\n  \\cosh(x + y) = \\cosh x \\cosh y + \\sinh x \\sinh y\n  \\]\n\n### **(3) 导数与积分**\n| 函数 | 导数 | 积分 |\n|------|------|------|\n| \\( \\sinh x \\) | \\( \\cosh x \\) | \\( \\cosh x + C \\) |\n| \\( \\cosh x \\) | \\( \\sinh x \\) | \\( \\sinh x + C \\) |\n| \\( \\tanh x \\) | \\( \\operatorname{sech}^2 x \\) | \\( \\ln \\cosh x + C \\) |\n\n---\n\n## **3. 双曲函数的几何意义**\n双曲函数得名于**双曲线**（Hyperbola），类似于三角函数与圆的关系：\n- **单位圆**：\\( x^2 + y^2 = 1 \\)，参数方程 \\( x = \\cos \\theta, y = \\sin \\theta \\)。\n- **单位双曲线**：\\( x^2 - y^2 = 1 \\)，参数方程 \\( x = \\cosh t, y = \\sinh t \\)。\n\n双曲函数描述了双曲线的面积关系，类似于三角函数描述圆的弧长关系。\n\n---\n\n## **4. 双曲函数的应用**\n双曲函数在多个领域有重要应用：\n\n### **(1) 物理学**\n- **相对论（狭义相对论）**：\n  - 速度叠加公式涉及 \\( \\tanh \\) 函数：\n    \\[\n    v_{\\text{rel}} = \\frac{v_1 + v_2}{1 + v_1 v_2 / c^2}\n    \\]\n    可以表示为 \\( \\tanh(\\phi_1 + \\phi_2) \\)，其中 \\( \\phi = \\tanh^{-1}(v/c) \\) 是**快度（Rapidity）**。\n  - 洛伦兹变换可以用双曲函数表示：\n    \\[\n    \\begin{cases}\n    x' = x \\cosh \\phi - ct \\sinh \\phi \\\\\n    ct' = -x \\sinh \\phi + ct \\cosh \\phi\n    \\end{cases}\n    \\]\n\n- **悬链线（Catenary）**：\n  - 悬挂的链条或电缆的形状是双曲余弦函数：\n    \\[\n    y = a \\cosh \\left( \\frac{x}{a} \\right)\n    \\]\n\n### **(2) 工程学**\n- **电磁学**：\n  - 传输线方程的解涉及双曲函数：\n    \\[\n    V(x) = A \\cosh(\\gamma x) + B \\sinh(\\gamma x)\n    \\]\n    其中 \\( \\gamma \\) 是传播常数。\n\n- **热传导**：\n  - 某些热传导问题的解包含双曲函数。\n\n### **(3) 数学**\n- **积分计算**：\n  - 许多积分可以通过双曲代换简化，如：\n    \\[\n    \\int \\frac{dx}{\\sqrt{x^2 + a^2}} = \\sinh^{-1} \\left( \\frac{x}{a} \\right) + C\n    \\]\n- **微分方程**：\n  - 双曲函数常用于求解某些常微分方程（如波动方程）。\n\n### **(4) 计算机科学**\n- **激活函数（机器学习）**：\n  - \\( \\tanh(x) \\) 是神经网络中常用的激活函数，输出在 \\((-1, 1)\\) 之间：\n    \\[\n    \\tanh(x) = \\frac{e^x - e^{-x}}{e^x + e^{-x}}\n    \\]\n\n---\n\n## **5. 总结**\n- **双曲函数**是 \\( e^x \\) 和 \\( e^{-x} \\) 的线性组合，与双曲线相关。\n- **主要函数**：\\( \\sinh x, \\cosh x, \\tanh x \\) 最常用。\n- **应用领域**：\n  - 物理学（相对论、悬链线）\n  - 工程学（电磁学、热传导）\n  - 数学（积分计算、微分方程）\n  - 计算机科学（神经网络激活函数）\n\n双曲函数在理论和应用上都非常重要，特别是在涉及指数增长、双曲几何和相对论动力学的场景中。",
  "markdown": "",
  "html": "",
  "lake": "",
  "format": "markdown",
  "status": 1,
  "gmt_modified": "2025-07-24T18:03:09+08:00",
  "gmt_create": "2025-05-21T08:47:47+08:00"
};

const html1 = r"""
\(\frac a b\) 
\(|z| = \sqrt{a^2 + b^2}\)
""";
const mdHtml = r"""

### **双曲函数（Hyperbolic Functions）及其应用**\n\n双曲函数是一类与双曲线（而非圆）相关的函数，类似于三角函数（圆函数），
但在性质和应用上有显著差异。它们在数学、物理、工程等领域有广泛的应用。\n\n
---\n\n
## **1. 双曲函数的定义**\n双曲函数可以通过指数函数 \\( e^x \\) 定义，主要包括以下六种：\n\n
### **(1) 双曲正弦（Hyperbolic Sine）**\n\\[\n\\sinh x = \\frac{e^x - e^{-x}}{2}\n\\]\n\n
### **(2) 双曲余弦（Hyperbolic Cosine）**\n\\[\n\\cosh x = \\frac{e^x + e^{-x}}{2}\n\\]\n\n
### **(3) 双曲正切（Hyperbolic Tangent）**\n\\[\n\\tanh x = \\frac{\\sinh x}{\\cosh x} = \\frac{e^x - e^{-x}}{e^x + e^{-x}}\n\\]\n\n
### **(4) 双曲余切（Hyperbolic Cotangent）**\n\\[\n\\coth x = \\frac{\\cosh x}{\\sinh x} = \\frac{e^x + e^{-x}}{e^x - e^{-x}}\n\\]\n\n
### **(5) 双曲正割（Hyperbolic Secant）**\n\\[\n\\operatorname{sech} x = \\frac{1}{\\cosh x} = \\frac{2}{e^x + e^{-x}}\n\\]\n\n
### **(6) 双曲余割（Hyperbolic Cosecant）**\n\\[\n\\operatorname{csch} x = \\frac{1}{\\sinh x} = \\frac{2}{e^x - e^{-x}}\n\\]\n\n---\n\n


""";

class GptMarkdownScreen extends StatefulWidget {
  const GptMarkdownScreen({super.key});

  @override
  State<GptMarkdownScreen> createState() => _GptMarkdownScreenState();
}

class _GptMarkdownScreenState extends State<GptMarkdownScreen> {
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
        title: const Text('GptMarkdown内容显示'),
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
            GptMarkdown(
        html1,
              // json['content'] as String,
              // mdHtml!,
              style: const TextStyle(color: Colors.black),
            )
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