String convertToVersion(String version, String environment) =>
    'release/v${version.replaceAll('+', '.')}-$environment';
