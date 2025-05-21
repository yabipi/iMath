import 'package:flutter/material.dart';
import 'package:imath/components/math_cell.dart';
import 'package:imath/services/question_service.dart';

class SlideQuestion extends StatefulWidget {
  const SlideQuestion({super.key});

  @override
  SlideQuestionState createState() => SlideQuestionState();
}

class SlideQuestionState extends State<SlideQuestion> {
  // int _currentPage = 0;
  int _index = 0;
  List questionList = [];
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    QuestionService.loadQuestions(1).then((questions) {
      // print(questions);
      questionList.addAll(questions!);
    });
  }

  void _previousPage() {
    if (_index > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_index < questionList.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("题目"),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: questionList.length,
            onPageChanged: (int index) {
              setState(() {
                _index = index;
              });
            },
            itemBuilder: (context, index) {
              // print(questionList[index].title);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: MathCell(
                            title: '', content: questionList[index].title),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.comment), onPressed: () {}),
                        IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {}),
                        IconButton(
                            icon: const Icon(Icons.thumb_up), onPressed: () {}),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          // 左侧箭头按钮
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _previousPage,
            ),
          ),
          // 右侧箭头按钮
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _nextPage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
