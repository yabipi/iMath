class MathContent {
  final String content;
  final bool isMath;
  final String? environment;
  final bool hasUnderline;
  final bool isDisplayMode;
  final bool isSpacing;
  final int spacingCount;

  MathContent({
    required this.content,
    required this.isMath,
    this.environment,
    this.hasUnderline = false,
    this.isDisplayMode = false,
    this.isSpacing = false,
    this.spacingCount = 0,
  });
}

class MathParser {
  static List<MathContent> parse(String text) {
    List<MathContent> result = [];
    int currentIndex = 0;

    while (currentIndex < text.length) {
      // 查找下一个数学公式的开始标记
      int nextMathStart = text.indexOf('\\(', currentIndex);
      int nextDisplayMathStart = text.indexOf('\\[', currentIndex);
      int nextDollarStart = text.indexOf('\$', currentIndex);
      int nextBeginStart = text.indexOf('\\begin', currentIndex);
      int nextUnderlineStart = text.indexOf('\\underline{', currentIndex);
      int nextQuadStart = text.indexOf('\\quad', currentIndex);
      int nextQuadQuadStart = text.indexOf('\\qquad', currentIndex);

      // 找到最近的开始标记
      int nextStart = -1;
      String startMarker = '';
      if (nextMathStart != -1 &&
          (nextStart == -1 || nextMathStart < nextStart)) {
        nextStart = nextMathStart;
        startMarker = '\\(';
      }
      if (nextDisplayMathStart != -1 &&
          (nextStart == -1 || nextDisplayMathStart < nextStart)) {
        nextStart = nextDisplayMathStart;
        startMarker = '\\[';
      }
      if (nextDollarStart != -1 &&
          (nextStart == -1 || nextDollarStart < nextStart)) {
        nextStart = nextDollarStart;
        startMarker = '\$';
      }
      if (nextBeginStart != -1 &&
          (nextStart == -1 || nextBeginStart < nextStart)) {
        nextStart = nextBeginStart;
        startMarker = '\\begin';
      }
      if (nextUnderlineStart != -1 &&
          (nextStart == -1 || nextUnderlineStart < nextStart)) {
        nextStart = nextUnderlineStart;
        startMarker = '\\underline';
      }
      if (nextQuadStart != -1 &&
          (nextStart == -1 || nextQuadStart < nextStart)) {
        nextStart = nextQuadStart;
        startMarker = '\\quad';
      }
      if (nextQuadQuadStart != -1 &&
          (nextStart == -1 || nextQuadQuadStart < nextStart)) {
        nextStart = nextQuadQuadStart;
        startMarker = '\\qquad';
      }

      // 如果没有找到数学公式，将剩余文本作为普通文本
      if (nextStart == -1) {
        if (currentIndex < text.length) {
          result.add(MathContent(
            content: text.substring(currentIndex),
            isMath: false,
          ));
        }
        break;
      }

      // 添加开始标记之前的普通文本
      if (currentIndex < nextStart) {
        result.add(MathContent(
          content: text.substring(currentIndex, nextStart),
          isMath: false,
        ));
      }

      // 处理数学公式
      if (startMarker == '\\(') {
        int endIndex = text.indexOf('\\)', nextStart + 2);
        if (endIndex == -1) {
          // 如果没有找到结束标记，尝试查找下一个开始标记
          int nextMathStart2 = text.indexOf('\\(', nextStart + 2);
          if (nextMathStart2 != -1) {
            // 如果找到下一个开始标记，将当前内容作为普通文本处理
            result.add(MathContent(
              content: text.substring(nextStart, nextMathStart2),
              isMath: false,
            ));
            currentIndex = nextMathStart2;
            continue;
          } else {
            // 如果没有找到下一个开始标记，将剩余内容作为普通文本
            result.add(MathContent(
              content: text.substring(nextStart),
              isMath: false,
            ));
            break;
          }
        }
        result.add(MathContent(
          content: text.substring(nextStart + 2, endIndex),
          isMath: true,
        ));
        currentIndex = endIndex + 2;
      } else if (startMarker == '\\[') {
        int endIndex = text.indexOf('\\]', nextStart + 2);
        if (endIndex == -1) {
          // 如果没有找到结束标记，尝试查找下一个开始标记
          int nextDisplayMathStart2 = text.indexOf('\\[', nextStart + 2);
          if (nextDisplayMathStart2 != -1) {
            // 如果找到下一个开始标记，将当前内容作为普通文本处理
            result.add(MathContent(
              content: text.substring(nextStart, nextDisplayMathStart2),
              isMath: false,
            ));
            currentIndex = nextDisplayMathStart2;
            continue;
          } else {
            // 如果没有找到下一个开始标记，将剩余内容作为普通文本
            result.add(MathContent(
              content: text.substring(nextStart),
              isMath: false,
            ));
            break;
          }
        }
        result.add(MathContent(
          content: text.substring(nextStart + 2, endIndex),
          isMath: true,
          isDisplayMode: true,
        ));
        currentIndex = endIndex + 2;
      } else if (startMarker == '\$') {
        int endIndex = text.indexOf('\$', nextStart + 1);
        if (endIndex == -1) {
          // 如果没有找到结束标记，将剩余内容作为普通文本
          result.add(MathContent(
            content: text.substring(nextStart),
            isMath: false,
          ));
          break;
        }
        result.add(MathContent(
          content: text.substring(nextStart + 1, endIndex),
          isMath: true,
        ));
        currentIndex = endIndex + 1;
      } else if (startMarker == '\\begin') {
        int endIndex = text.indexOf('\\end', nextStart + 6);
        if (endIndex == -1) {
          // 如果没有找到结束标记，尝试查找下一个开始标记
          int nextBeginStart2 = text.indexOf('\\begin', nextStart + 6);
          if (nextBeginStart2 != -1) {
            // 如果找到下一个开始标记，将当前内容作为普通文本处理
            result.add(MathContent(
              content: text.substring(nextStart, nextBeginStart2),
              isMath: false,
            ));
            currentIndex = nextBeginStart2;
            continue;
          } else {
            // 如果没有找到下一个开始标记，将剩余内容作为普通文本
            result.add(MathContent(
              content: text.substring(nextStart),
              isMath: false,
            ));
            break;
          }
        }
        // 找到对应的 \end 标记
        int braceStart = text.indexOf('{', nextStart + 6);
        if (braceStart == -1) {
          // 如果没有找到环境名称，将内容作为普通文本处理
          result.add(MathContent(
            content: text.substring(nextStart, endIndex + 4),
            isMath: false,
          ));
          currentIndex = endIndex + 4;
          continue;
        }
        int braceEnd = text.indexOf('}', braceStart + 1);
        if (braceEnd == -1) {
          // 如果没有找到环境名称的结束括号，将内容作为普通文本处理
          result.add(MathContent(
            content: text.substring(nextStart, endIndex + 4),
            isMath: false,
          ));
          currentIndex = endIndex + 4;
          continue;
        }
        String environment = text.substring(braceStart + 1, braceEnd);
        int endEnvironment = text.indexOf('\\end{$environment}', endIndex);
        if (endEnvironment == -1) {
          // 如果没有找到匹配的结束标记，尝试查找下一个开始标记
          int nextBeginStart2 = text.indexOf('\\begin', nextStart + 6);
          if (nextBeginStart2 != -1) {
            // 如果找到下一个开始标记，将当前内容作为普通文本处理
            result.add(MathContent(
              content: text.substring(nextStart, nextBeginStart2),
              isMath: false,
            ));
            currentIndex = nextBeginStart2;
            continue;
          } else {
            // 如果没有找到下一个开始标记，将剩余内容作为普通文本
            result.add(MathContent(
              content: text.substring(nextStart),
              isMath: false,
            ));
            break;
          }
        }
        result.add(MathContent(
          content: text.substring(
              nextStart, endEnvironment + 6 + environment.length + 1),
          isMath: true,
          environment: environment,
          isDisplayMode: true,
        ));
        currentIndex = endEnvironment + 6 + environment.length + 1;
      } else if (startMarker == '\\underline') {
        int braceStart = text.indexOf('{', nextStart + 10);
        if (braceStart == -1) {
          // 如果没有找到开始括号，将内容作为普通文本处理
          result.add(MathContent(
            content: text.substring(nextStart),
            isMath: false,
          ));
          break;
        }
        int braceEnd = text.indexOf('}', braceStart + 1);
        if (braceEnd == -1) {
          // 如果没有找到结束括号，将内容作为普通文本处理
          result.add(MathContent(
            content: text.substring(nextStart),
            isMath: false,
          ));
          break;
        }
        // 解析下划线内的内容
        String underlinedContent = text.substring(braceStart + 1, braceEnd);
        // 递归解析下划线内的内容，因为它可能包含其他数学公式
        List<MathContent> underlinedParts = parse(underlinedContent);
        // 为每个部分添加下划线标记
        for (var part in underlinedParts) {
          result.add(MathContent(
            content: part.content,
            isMath: part.isMath,
            environment: part.environment,
            hasUnderline: true,
            isDisplayMode: part.isDisplayMode,
          ));
        }
        currentIndex = braceEnd + 1;
      } else if (startMarker == '\\quad' || startMarker == '\\qquad') {
        // 处理间距命令
        result.add(MathContent(
          content: '',
          isMath: false,
          isSpacing: true,
          spacingCount: startMarker == '\\qquad' ? 2 : 1,
        ));
        currentIndex = nextStart + (startMarker == '\\qquad' ? 7 : 5);
      }
    }

    return result;
  }
}
