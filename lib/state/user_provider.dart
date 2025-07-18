import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/models/user.dart';

final userProvider = StateProvider<User>((ref) => User(username: ''));