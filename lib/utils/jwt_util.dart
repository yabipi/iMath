import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtUtil {
  static String generateJWT(Map<String, dynamic> data, String secret) {
    // Generate a JSON Web Token
    // You can provide the payload as a key-value map or a string
    final jwt = JWT(
      // Payload
      data,
      issuer: 'None',
    );

    // Sign it (default with HS256 algorithm)
    final token = jwt.sign(SecretKey(secret));
    // print('Signed token: $token\n');
    return token;
  }
}
