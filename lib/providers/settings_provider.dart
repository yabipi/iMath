import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/constants.dart';

final mathLevelProvider = StateProvider<MATH_LEVEL>((ref) => MATH_LEVEL.Primary);