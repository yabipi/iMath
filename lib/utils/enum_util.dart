class EnumUtil {
  static T fromString<T extends Enum>(List<T> values, String value) {
    return values.firstWhere(
          (e) => e.name == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid enum value: $value'),
    );
  }
}