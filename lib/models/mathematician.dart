class Mathematician {
  final String name;
  final String imageUrl;
  final String introduction;
  final List<String> contributions;
  final String birth_death; // 年代
  final String country; // 国籍

  Mathematician({
    required this.name,
    required this.imageUrl,
    required this.introduction,
    required this.contributions,
    required this.birth_death,
    required this.country,
  });

  Mathematician.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        // imageUrl = json['imageUrl'],
        imageUrl = '',
        introduction = json['introduction'],
        contributions = [''],
        // contributions = List<String>.from(json['contributions'].split(',')),
        birth_death = json['birth_death'],
        country = json['country'];
}

// 示例数学家数据
final mathematicians = [
  Mathematician(
    name: '黎曼',
    imageUrl: 'assets/images/riemann.jpg',
    introduction: '伯恩哈德·黎曼（Bernhard Riemann，1826年9月17日－1866年7月20日）是德国数学家，对数学分析和微分几何做出了开创性的贡献。',
    contributions: [
      '创立黎曼几何学，为广义相对论奠定数学基础',
      '提出黎曼猜想，这是数学界最重要的未解决问题之一',
      '发展了复变函数论，创立黎曼曲面理论',
      '在数论中提出黎曼ζ函数',
    ],
    birth_death: '1826-1866',
    country: '德国',
  ),
  Mathematician(
    name: '伽罗瓦',
    imageUrl: 'assets/images/galois.jpg',
    introduction: '埃瓦里斯特·伽罗瓦（Évariste Galois，1811年10月25日－1832年5月31日）是法国数学家，群论的创始人之一。',
    contributions: [
      '创立群论，为现代代数奠定基础',
      '证明五次及以上方程没有根式解',
      '发展了伽罗瓦理论，解决代数方程可解性问题',
      '为现代数学提供了重要的工具和方法',
    ],
    birth_death: '1811-1832',
    country: '法国',
  ),
  Mathematician(
    name: '高斯',
    imageUrl: 'assets/images/gauss.jpg',
    introduction: '卡尔·弗里德里希·高斯（Carl Friedrich Gauss，1777年4月30日－1855年2月23日）是德国数学家、物理学家、天文学家，被誉为"数学王子"。',
    contributions: [
      '创立数论中的高斯定理',
      '发展非欧几何学',
      '发明最小二乘法',
      '在天文学和物理学领域做出重要贡献',
      '创立高斯分布（正态分布）',
    ],
    birth_death: '1777-1855',
    country: '德国',
  ),
]; 