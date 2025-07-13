import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class CaptchaPage extends StatefulWidget {
  final String? purpose; // 验证目的：login, register, reset_password 等
  final Function(bool success, String? token)? onVerificationComplete;

  const CaptchaPage({
    Key? key,
    this.purpose,
    this.onVerificationComplete,
  }) : super(key: key);

  @override
  _CaptchaPageState createState() => _CaptchaPageState();
}

class _CaptchaPageState extends State<CaptchaPage>
    with TickerProviderStateMixin {
  late AnimationController _sliderController;
  late AnimationController _shakeController;
  late Animation<double> _sliderAnimation;
  late Animation<double> _shakeAnimation;

  double _sliderValue = 0.0;
  double _targetPosition = 0.0;
  bool _isVerified = false;
  bool _isLoading = false;
  bool _isFailed = false;
  String _captchaImage = '';
  String _captchaId = '';
  String _errorMessage = '';

  // 验证码配置
  final double _sliderHeight = 50.0;
  final double _sliderWidth = 300.0;
  final double _puzzleSize = 40.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCaptcha();
  }

  @override
  void dispose() {
    _sliderController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // 滑块动画控制器
    _sliderController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // 抖动动画控制器
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // 滑块动画
    _sliderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sliderController,
      curve: Curves.easeInOut,
    ));

    // 抖动动画
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));

    _sliderAnimation.addListener(() {
      setState(() {
        _sliderValue = _sliderAnimation.value;
      });
    });
  }

  // 加载验证码
  Future<void> _loadCaptcha() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // TODO: 调用后台API获取验证码
      // final response = await CaptchaService.getCaptcha(widget.purpose ?? 'login');
      // _captchaImage = response.imageUrl;
      // _captchaId = response.captchaId;
      // _targetPosition = response.targetPosition;

      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 800));
      
      // 模拟数据
      _captchaImage = 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&h=200&fit=crop';
      _captchaId = 'captcha_${DateTime.now().millisecondsSinceEpoch}';
      _targetPosition = 0.7; // 目标位置在70%处

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载验证码失败，请重试';
      });
    }
  }

  // 验证滑动位置
  Future<void> _verifyCaptcha() async {
    if (_isVerified || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 计算滑动位置与目标位置的差异
      double difference = (_sliderValue - _targetPosition).abs();
      bool isCorrect = difference < 0.05; // 允许5%的误差

      if (isCorrect) {
        // 验证成功
        await _handleSuccess();
      } else {
        // 验证失败
        await _handleFailure();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '验证失败，请重试';
      });
    }
  }

  // 处理验证成功
  Future<void> _handleSuccess() async {
    try {
      // TODO: 调用后台API验证滑动位置
      // final response = await CaptchaService.verifyCaptcha(
      //   captchaId: _captchaId,
      //   sliderPosition: _sliderValue,
      //   purpose: widget.purpose ?? 'login',
      // );

      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 500));

      setState(() {
        _isVerified = true;
        _isLoading = false;
      });

      // 显示成功动画
      _showSuccessAnimation();

      // 回调成功结果
      widget.onVerificationComplete?.call(true, 'token_${DateTime.now().millisecondsSinceEpoch}');

      // 延迟返回上一页
      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          context.pop();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '验证失败，请重试';
      });
    }
  }

  // 处理验证失败
  Future<void> _handleFailure() async {
    setState(() {
      _isFailed = true;
      _isLoading = false;
    });

    // 播放抖动动画
    _shakeController.forward();

    // 重置滑块位置
    _sliderController.animateTo(0.0);

    // 延迟重置状态
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isFailed = false;
        });
      }
    });
  }

  // 显示成功动画
  void _showSuccessAnimation() {
    // 可以添加成功动画效果
  }

  // 刷新验证码
  Future<void> _refreshCaptcha() async {
    setState(() {
      _isVerified = false;
      _isFailed = false;
      _sliderValue = 0.0;
      _errorMessage = '';
    });
    _sliderController.reset();
    await _loadCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('滑动验证'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshCaptcha,
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // 验证码图片区域
            _buildCaptchaImageArea(),
            
            // 滑动验证区域
            _buildSliderArea(),
            
            // 状态提示区域
            _buildStatusArea(),
            
            Spacer(),
            
            // 底部按钮区域
            _buildBottomArea(),
          ],
        ),
      ),
    );
  }

  // 验证码图片区域
  Widget _buildCaptchaImageArea() {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isLoading
            ? Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : _captchaImage.isNotEmpty
                ? Stack(
                    children: [
                      Image.network(
                        _captchaImage,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                      // 目标区域指示
                      Positioned(
                        left: _targetPosition * (_sliderWidth - _puzzleSize),
                        top: 20,
                        child: Container(
                          width: _puzzleSize,
                          height: _puzzleSize,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    height: 200,
                    child: Center(
                      child: Text(
                        '验证码加载失败',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  // 滑动验证区域
  Widget _buildSliderArea() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            '请将滑块拖到指定位置完成验证',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: _sliderWidth,
            height: _sliderHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_sliderHeight / 2),
              border: Border.all(
                color: _isFailed ? Colors.red : Colors.grey[300]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 进度条
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: _sliderValue * _sliderWidth,
                  height: _sliderHeight,
                  decoration: BoxDecoration(
                    color: _isVerified
                        ? Colors.green
                        : _isFailed
                            ? Colors.red
                            : Colors.blue,
                    borderRadius: BorderRadius.circular(_sliderHeight / 2),
                  ),
                ),
                // 滑块
                Positioned(
                  left: _sliderValue * (_sliderWidth - _sliderHeight),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (!_isVerified && !_isLoading) {
                        double newValue = (_sliderValue * _sliderWidth + details.delta.dx) / _sliderWidth;
                        newValue = newValue.clamp(0.0, 1.0);
                        setState(() {
                          _sliderValue = newValue;
                        });
                      }
                    },
                    onPanEnd: (details) {
                      if (!_isVerified && !_isLoading) {
                        _verifyCaptcha();
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _sliderHeight,
                      height: _sliderHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(_sliderHeight / 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _isVerified ? Colors.green : Colors.blue,
                                  ),
                                ),
                              )
                            : _isVerified
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 24,
                                  )
                                : Icon(
                                    Icons.arrow_forward,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 状态提示区域
  Widget _buildStatusArea() {
    if (_errorMessage.isNotEmpty) {
      return Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isVerified) {
      return Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '验证成功！',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  // 底部按钮区域
  Widget _buildBottomArea() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          if (!_isVerified)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _refreshCaptcha,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '刷新验证码',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '取消',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 验证码服务类（预留接口）
class CaptchaService {
  // 获取验证码
  static Future<CaptchaResponse> getCaptcha(String purpose) async {
    // TODO: 实现获取验证码的API调用
    // final response = await http.get('/api/captcha?purpose=$purpose');
    // return CaptchaResponse.fromJson(response.data);
    
    throw UnimplementedError('需要实现获取验证码的API调用');
  }

  // 验证滑动位置
  static Future<VerificationResponse> verifyCaptcha({
    required String captchaId,
    required double sliderPosition,
    required String purpose,
  }) async {
    // TODO: 实现验证滑动位置的API调用
    // final response = await http.post('/api/captcha/verify', data: {
    //   'captchaId': captchaId,
    //   'sliderPosition': sliderPosition,
    //   'purpose': purpose,
    // });
    // return VerificationResponse.fromJson(response.data);
    
    throw UnimplementedError('需要实现验证滑动位置的API调用');
  }
}

// 验证码响应数据模型
class CaptchaResponse {
  final String captchaId;
  final String imageUrl;
  final double targetPosition;

  CaptchaResponse({
    required this.captchaId,
    required this.imageUrl,
    required this.targetPosition,
  });

  factory CaptchaResponse.fromJson(Map<String, dynamic> json) {
    return CaptchaResponse(
      captchaId: json['captchaId'],
      imageUrl: json['imageUrl'],
      targetPosition: json['targetPosition'].toDouble(),
    );
  }
}

// 验证响应数据模型
class VerificationResponse {
  final bool success;
  final String? token;
  final String? message;

  VerificationResponse({
    required this.success,
    this.token,
    this.message,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      success: json['success'],
      token: json['token'],
      message: json['message'],
    );
  }
}
