import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:yaml/yaml.dart';

import 'package:version_name_extractor/version_name_extractor.dart'
    as version_name_extractor;

void main() async {
  final chopperModuleEntity = File('lib/src/core/di/chopper_module.dart');

  final enironmentsEntity = File('lib/src/core/di/enviroments.dart');

  final collection = AnalysisContextCollection(
    includedPaths: [
      chopperModuleEntity.absolute.path,
      enironmentsEntity.absolute.path,
    ],
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );

  String? environmentUrl;
  String? prodEnv;
  String? betaEnv;

  for (final context in collection.contexts) {
    for (final filePath in context.contextRoot.analyzedFiles()) {
      if (!filePath.endsWith('.dart')) return;

      final result = (await context.currentSession.getUnitElement(filePath))
          as UnitElementResult;

      if (filePath.endsWith('chopper_module.dart')) {
        result.element.topLevelVariables.forEach((variable) {
          if (variable.displayName == 'enviromentUrl') {
            environmentUrl = variable.computeConstantValue()?.toStringValue();
            return;
          }
        });
      }

      if (filePath.endsWith('enviroments.dart')) {
        final envClass = result.element.getClass('Enviroments');

        prodEnv = envClass
            ?.getField('production')
            ?.computeConstantValue()
            ?.toStringValue();

        betaEnv =
            envClass?.getField('beta')?.computeConstantValue()?.toStringValue();
      }
    }
  }

  String environment = switch (environmentUrl) {
    (String url) when url == prodEnv => 'prod',
    (String url) when url == betaEnv => 'beta',
    (String url) when url.toLowerCase().contains('beta') => 'test',
    (_) => throw Exception("Invalid url for release"),
  };

  File file = File('./pubspec.yaml');
  String yamlString = file.readAsStringSync();

  YamlMap yaml = loadYaml(yamlString);

  print(
    version_name_extractor.convertToVersion(
      yaml['version'],
      environment,
    ),
  );
}
