class CaseUtil {
  const CaseUtil._();

  static String snakeCaseToKebabCase(String value) =>
      value.replaceAll('_', '-');

  static String kebabCaseToSnakeCase(String value) =>
      value.replaceAll('-', '_');
}
