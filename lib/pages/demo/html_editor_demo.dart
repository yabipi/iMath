import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert'; // Added for json.decode

// void main() => runApp(HtmlEditorDemo());

// class HtmlEditorDemo extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(),
//       darkTheme: ThemeData.dark(),
//       home: HtmlEditorExample(title: 'Flutter HTML Editor Example'),
//     );
//   }
// }

class HtmlEditorExample extends StatefulWidget {
  HtmlEditorExample({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HtmlEditorExampleState createState() => _HtmlEditorExampleState();
}

class _HtmlEditorExampleState extends State<HtmlEditorExample> {
  String result = '';
  final HtmlEditorController controller = HtmlEditorController();

  /// 上传图片到后台服务器
  Future<String?> _uploadImageToServer(
      Uint8List imageBytes, String fileName) async {
    try {
      // 创建 multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('YOUR_BACKEND_URL/api/upload-image'), // 替换为你的后台API地址
      );

      // 添加图片数据
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // 字段名，根据你的后台API调整
          imageBytes,
          filename: fileName,
        ),
      );

      // 可选：添加其他参数
      // request.fields['userId'] = '123';
      // request.fields['category'] = 'editor';

      // 发送请求
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // 解析返回的JSON数据
        // 假设返回格式为: {"success": true, "url": "https://example.com/image.jpg"}
        var jsonResponse = json.decode(responseData);
        if (jsonResponse['success'] == true) {
          return jsonResponse['url'];
        }
      }

      // 如果上传失败，显示错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('图片上传失败: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } catch (e) {
      print('图片上传错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('图片上传错误: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  /// 处理粘贴的图片
  Future<void> _handlePastedImage(Uint8List imageBytes, String fileName) async {
    // 显示上传进度
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在上传图片...'),
        duration: Duration(seconds: 2),
      ),
    );

    // 上传图片到服务器
    final imageUrl = await _uploadImageToServer(imageBytes, fileName);

    if (imageUrl != null) {
      // 插入图片URL到编辑器
      // await controller.insertHtml(
      //     '<img src="$imageUrl" alt="$fileName" style="max-width: 100%; height: auto;" />');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('图片上传成功: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!kIsWeb) {
          controller.clearFocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0,
          actions: [
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  if (kIsWeb) {
                    controller.reloadWeb();
                  } else {
                    controller.editorController!.reload();
                  }
                }),
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                  if (kIsWeb) {
                    print(await controller.getText());
                  } else {
                    // controller.editorController!.reload();
                  }
                }),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.toggleCodeView();
          },
          child: Text(r'<\>',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HtmlEditor(
                controller: controller,
                htmlEditorOptions: HtmlEditorOptions(
                  hint: 'Your text here...',
                  shouldEnsureVisible: true,
                  //initialText: "<p>text content initial, if any</p>",
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  toolbarPosition: ToolbarPosition.aboveEditor, //by default
                  toolbarType: ToolbarType.nativeScrollable, //by default
                  onButtonPressed:
                      (ButtonType type, bool? status, Function? updateStatus) {
                    print(
                        "button '${type.name}' pressed, the current selected status is $status");
                    return true;
                  },
                  onDropdownChanged: (DropdownType type, dynamic changed,
                      Function(dynamic)? updateSelectedItem) {
                    print("dropdown '${type.name}' changed to $changed");
                    return true;
                  },
                  mediaLinkInsertInterceptor:
                      (String url, InsertFileType type) {
                    print(url);
                    return true;
                  },
                  mediaUploadInterceptor:
                      (PlatformFile file, InsertFileType type) async {
                    print(file.name); //filename
                    print(file.size); //size in bytes
                    print(file.extension); //file extension (eg jpeg or mp4)

                    // 如果是图片文件，上传到服务器
                    if (type == InsertFileType.image && file.bytes != null) {
                      try {
                        final imageUrl =
                            await _uploadImageToServer(file.bytes!, file.name);
                        if (imageUrl != null) {
                          // 返回false阻止默认的base64插入行为
                          return false;
                        }
                      } catch (e) {
                        print('图片上传失败: $e');
                      }
                    }

                    return true;
                  },
                ),
                otherOptions: OtherOptions(height: 550),
                callbacks: Callbacks(onBeforeCommand: (String? currentHtml) {
                  print('html before change is $currentHtml');
                }, onChangeContent: (String? changed) {
                  print('content changed to $changed');
                }, onChangeCodeview: (String? changed) {
                  print('code changed to $changed');
                }, onChangeSelection: (EditorSettings settings) {
                  print('parent element is ${settings.parentElement}');
                  print('font name is ${settings.fontName}');
                }, onDialogShown: () {
                  print('dialog shown');
                }, onEnter: () {
                  print('enter/return pressed');
                }, onFocus: () {
                  print('editor focused');
                }, onBlur: () {
                  print('editor unfocused');
                }, onBlurCodeview: () {
                  print('codeview either focused or unfocused');
                }, onInit: () {
                  print('init');
                }, onPaste: () {
                  print('pasted into editor');
                  // 这里可以监听粘贴事件，但需要额外的处理来获取粘贴的图片数据
                }, onImageUpload: (FileUpload file) async {
                  print('Image upload triggered');
                  print('File name: ${file.name}');
                  print('File size: ${file.size}');
                  print('File type: ${file.type}');

                  // 将base64转换为bytes
                  if (file.base64 != null) {
                    final bytes = base64Decode(file.base64!);
                    final imageUrl = await _uploadImageToServer(
                        bytes, file.name ?? 'image.jpg');

                    if (imageUrl != null) {
                      // 插入图片URL而不是base64
                      // await controller.insertHtml(
                      //     '<img src="$imageUrl" alt="${file.name ?? 'image'}" style="max-width: 100%; height: auto;" />');
                    }
                  }
                }, onImageUploadError:
                    (FileUpload? file, String? base64Str, UploadError error) {
                  print(error.name);
                  print(base64Str ?? '');
                  if (file != null) {
                    print(file.name);
                    print(file.size);
                    print(file.type);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('图片上传失败: ${error.name}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }, onKeyDown: (int? keyCode) {
                  print('$keyCode key downed');
                  print(
                      'current character count: ${controller.characterCount}');
                }, onKeyUp: (int? keyCode) {
                  print('$keyCode key released');
                }, onMouseDown: () {
                  print('mouse downed');
                }, onMouseUp: () {
                  print('mouse released');
                }, onNavigationRequestMobile: (String url) {
                  print(url);
                  return NavigationActionPolicy.ALLOW;
                }, onScroll: () {
                  print('editor scrolled');
                }),
                plugins: [
                  SummernoteAtMention(
                      getSuggestionsMobile: (String value) {
                        var mentions = <String>['test1', 'test2', 'test3'];
                        return mentions
                            .where((element) => element.contains(value))
                            .toList();
                      },
                      mentionsWeb: ['test1', 'test2', 'test3'],
                      onSelect: (String value) {
                        print(value);
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
