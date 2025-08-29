// Aggregated questions map: imports and combined map
import 'questions/agile_xp.dart';
import 'questions/algorithm_design.dart';
import 'questions/algorithms_complexity.dart';
import 'questions/c_cpp.dart';
import 'questions/csharp.dart';
import 'questions/data_structures.dart';
import 'questions/design_patterns_gof.dart';
import 'questions/divide_and_conquer.dart';
import 'questions/driven_development.dart';
import 'questions/java.dart';
import 'questions/javascript_typescript.dart';
import 'questions/kotlin.dart';
import 'questions/microservices.dart';
import 'questions/programming_languages.dart';
import 'questions/prolog.dart';
import 'questions/python.dart';
import 'questions/rust.dart';
import 'questions/soft_skills.dart';
import 'questions/solid.dart';
import 'questions/tools_ides.dart';

final Map<String, String> qA = {
  ...qAProgrammingLanguages,
  ...qAPython,
  ...qACAndCpp,
  ...qARust,
  ...qACSharp,
  ...qAProlog,
  ...qASOLID,
  ...qAAlgorithmsComplexity,
  ...qADivideAndConquer,
  ...qADataStructures,
  ...qAAlgorithmDesign,
  ...qAMicroservices,
  ...qAToolsIDEs,
  ...qASoftSkills,
  ...qAAgileXP,
  ...qADrivenDevelopment,
  ...qAJavaScriptTypeScript,
  ...qAJava,
  ...qAKotlin,
  ...qADesignPatternsGoF,
};
