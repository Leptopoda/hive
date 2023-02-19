import 'package:analyzer/dart/element/element.dart';
import 'package:hive_generator/src/builder.dart';
import 'package:hive_generator/src/helper.dart';

class EnumBuilder extends Builder {
  EnumBuilder(InterfaceElement interface, List<AdapterField> getters)
      : super(interface, getters);

  @override
  String buildRead() {
    check(
        getters.isNotEmpty, '${interface.name} does not have any enum value.');

    var code = StringBuffer();
    code.writeln('switch (reader.readByte()) {');

    for (var field in getters) {
      code.writeln('''
        case ${field.index}:
          return ${interface.name}.${field.name};''');
    }

    var defaultField = getters.firstWhere(
        (it) => it.defaultValue?.toBoolValue() == true,
        orElse: () => getters.first);
    code.writeln(''' 
      default:
        return ${interface.name}.${defaultField.name};
      }''');

    return code.toString();
  }

  @override
  String buildWrite() {
    var code = StringBuffer();
    code.writeln('switch (obj) {');

    for (var field in getters) {
      code.writeln('''
        case ${interface.name}.${field.name}:
          writer.writeByte(${field.index});
          break;''');
    }

    code.writeln('}');

    return code.toString();
  }
}

class EnumClassBuilder extends Builder {
  EnumClassBuilder(InterfaceElement interface, List<AdapterField> getters)
      : super(interface, getters);

  @override
  String buildRead() {
    // Read the name of the enum class from the single field
    var code = StringBuffer()
      ..writeln('return ${interface.name}.valueOf(reader.read() as String);');
    return code.toString();
  }

  @override
  String buildWrite() {
    // Write the name of the enum class as the single field.
    var code = StringBuffer()
      ..writeln('writer') //
      ..writeln('..write(obj.name);');
    return code.toString();
  }
}
