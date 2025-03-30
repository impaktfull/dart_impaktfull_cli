class CaseUtil {
  const CaseUtil._();

  static String snakeCaseToKebabCase(String value) {
    return value.replaceAll('_', '-');
  }
}
