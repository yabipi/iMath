class Mathematician {
  final String name;
  final String imageUrl;
  final String biography;
  final List<String> achievements;
  final String period; // 年代
  final String nationality; // 国籍

  Mathematician({
    required this.name,
    required this.imageUrl,
    required this.biography,
    required this.achievements,
    required this.period,
    required this.nationality,
  });
}

// 示例数学家数据
final mathematicians = [
  Mathematician(
    name: '黎曼',
    imageUrl: 'assets/images/riemann.jpg',
    biography: '伯恩哈德·黎曼（Bernhard Riemann，1826年9月17日－1866年7月20日）是德国数学家，对数学分析和微分几何做出了开创性的贡献。',
    achievements: [
      '创立黎曼几何学，为广义相对论奠定数学基础',
      '提出黎曼猜想，这是数学界最重要的未解决问题之一',
      '发展了复变函数论，创立黎曼曲面理论',
      '在数论中提出黎曼ζ函数',
    ],
    period: '1826-1866',
    nationality: '德国',
  ),
  Mathematician(
    name: '伽罗瓦',
    imageUrl: 'assets/images/galois.jpg',
    biography: '埃瓦里斯特·伽罗瓦（Évariste Galois，1811年10月25日－1832年5月31日）是法国数学家，群论的创始人之一。',
    achievements: [
      '创立群论，为现代代数奠定基础',
      '证明五次及以上方程没有根式解',
      '发展了伽罗瓦理论，解决代数方程可解性问题',
      '为现代数学提供了重要的工具和方法',
    ],
    period: '1811-1832',
    nationality: '法国',
  ),
  Mathematician(
    name: '高斯',
    imageUrl: 'assets/images/gauss.jpg',
    biography: '卡尔·弗里德里希·高斯（Carl Friedrich Gauss，1777年4月30日－1855年2月23日）是德国数学家、物理学家、天文学家，被誉为"数学王子"。',
    achievements: [
      '创立数论中的高斯定理',
      '发展非欧几何学',
      '发明最小二乘法',
      '在天文学和物理学领域做出重要贡献',
      '创立高斯分布（正态分布）',
    ],
    period: '1777-1855',
    nationality: '德国',
  ),
]; 