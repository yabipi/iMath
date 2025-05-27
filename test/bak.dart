// Widget buildMixedText(String? text) {
//   if (text == null || text.isEmpty) {
//     return const Text('');
//   }
//
//   final List<Widget> widgets = [];
//   final RegExp latexPattern = RegExp(r'\\\((.*?)\\\)|\$(.*?)\$');
//   int lastIndex = 0;
//
//   try {
//     for (final Match match in latexPattern.allMatches(text)) {
//       if (match.start > lastIndex) {
//         widgets.add(
//           Text(
//             text.substring(lastIndex, match.start),
//             style: const TextStyle(fontSize: 16),
//           ),
//         );
//       }
//
//       final formula = match.group(1);
//       if (formula != null) {
//         widgets.add(
//           Math.tex(
//             formula,
//             textStyle: const TextStyle(fontSize: 16),
//             mathStyle: MathStyle.text,
//           ),
//         );
//       }
//
//       lastIndex = match.end;
//     }
//
//     if (lastIndex < text.length) {
//       widgets.add(
//         Text(
//           text.substring(lastIndex),
//           style: const TextStyle(fontSize: 16),
//         ),
//       );
//     }
//   } catch (e) {
//     print('Error in buildMixedText: $e');
//     return Text(text);
//   }
//
//   return Wrap(
//     crossAxisAlignment: WrapCrossAlignment.center,
//     spacing: 4,
//     children: widgets,
//   );
// }

