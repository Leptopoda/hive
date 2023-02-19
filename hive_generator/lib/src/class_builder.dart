// ignore_for_file: lines_longer_than_80_chars

import 'dart:typed_data';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart' as bv;
import 'package:hive/hive.dart';
import 'package:hive_generator/src/builder.dart';
import 'package:hive_generator/src/helper.dart';
import 'package:hive_generator/src/type_helper.dart';
import 'package:source_gen/source_gen.dart';

import 'type_adapter_generator.dart';

class ClassBuilder extends Builder {
  ClassBuilder(
    InterfaceElement interface,
    List<AdapterField> getters,
    List<AdapterField> setters,
  ) : super(interface, getters, setters);

  var hiveListChecker = const TypeChecker.fromRuntime(HiveList);
  var listChecker = const TypeChecker.fromRuntime(List);
  var mapChecker = const TypeChecker.fromRuntime(Map);
  var setChecker = const TypeChecker.fromRuntime(Set);
  var iterableChecker = const TypeChecker.fromRuntime(Iterable);
  var uint8ListChecker = const TypeChecker.fromRuntime(Uint8List);

  @override
  String buildRead() {
    var constr =
        interface.constructors.firstOrNullWhere((it) => it.name.isEmpty);
    check(constr != null, 'Provide an unnamed constructor.');

    // The remaining fields to initialize.
    var fields = setters.toList();

    // Empty classes
    if (constr!.parameters.isEmpty && fields.isEmpty) {
      return 'return ${interface.name}();';
    }

    var code = StringBuffer();
    code.writeln('''
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return ${interface.name}(
    ''');

    for (var param in constr.parameters) {
      var field = fields.firstOrNullWhere((it) => it.name == param.name);
      // Final fields
      field ??= getters.firstOrNullWhere((it) => it.name == param.name);
      if (field != null) {
        if (param.isNamed) {
          code.write('${param.name}: ');
        }
        code.write(_value(
          param.type,
          'fields[${field.index}]',
          field.defaultValue,
        ));
        code.writeln(',');
        fields.remove(field);
      }
    }

    code.writeln(')');

    // There may still be fields to initialize that were not in the constructor
    // as initializing formals. We do so using cascades.
    for (var field in fields) {
      code.write('..${field.name} = ');
      code.writeln(_value(
        field.type,
        'fields[${field.index}]',
        field.defaultValue,
      ));
    }

    code.writeln(';');

    return code.toString();
  }

  String _value(DartType type, String variable, DartObject? defaultValue) {
    var value = _cast(type, variable);
    if (defaultValue?.isNull != false) return value;
    return '$variable == null ? ${constantToString(defaultValue!)} : $value';
  }

  String _cast(DartType type, String variable) {
    var suffix = _suffixFromType(type);
    if (hiveListChecker.isAssignableFromType(type)) {
      return '($variable as HiveList$suffix)$suffix.castHiveList()';
    } else if (iterableChecker.isAssignableFromType(type) &&
        !isUint8List(type)) {
      return '($variable as List$suffix)${_castIterable(type)}';
    } else if (mapChecker.isAssignableFromType(type)) {
      return '($variable as Map$suffix)${_castMap(type)}';
    } else {
      return '$variable as ${_displayString(type)}';
    }
  }

  bool isMapOrIterable(DartType type) {
    return iterableChecker.isAssignableFromType(type) ||
        mapChecker.isAssignableFromType(type);
  }

  bool isUint8List(DartType type) {
    return uint8ListChecker.isExactlyType(type);
  }

  String _castIterable(DartType type) {
    var paramType = type as ParameterizedType;
    var arg = paramType.typeArguments.first;
    var suffix = _accessorSuffixFromType(type);
    if (isMapOrIterable(arg) && !isUint8List(arg)) {
      var cast = '';
      // Using assignable because List? is not exactly List
      if (listChecker.isAssignableFromType(type)) {
        cast = '.toList()';
        // Using assignable because Set? is not exactly Set
      } else if (setChecker.isAssignableFromType(type)) {
        cast = '.toSet()';
      }
      // The suffix is not needed with nnbd on $cast becauuse it short circuits,
      // otherwise it is needed.
      var castWithSuffix = isLibraryNNBD(interface) ? '$cast' : '$suffix$cast';
      return '$suffix.map((dynamic e)=> ${_cast(arg, 'e')})$castWithSuffix';
    } else {
      return '$suffix.cast<${_displayString(arg)}>()';
    }
  }

  String _castMap(DartType type) {
    var paramType = type as ParameterizedType;
    var arg1 = paramType.typeArguments[0];
    var arg2 = paramType.typeArguments[1];
    var suffix = _accessorSuffixFromType(type);
    if (isMapOrIterable(arg1) || isMapOrIterable(arg2)) {
      return '$suffix.map((dynamic k, dynamic v)=>'
          'MapEntry(${_cast(arg1, 'k')},${_cast(arg2, 'v')}))';
    } else {
      return '$suffix.cast<${_displayString(arg1)}, '
          '${_displayString(arg2)}>()';
    }
  }

  @override
  String buildWrite() {
    var code = StringBuffer();
    code.writeln('writer');
    code.writeln('..writeByte(${getters.length})');
    for (var field in getters) {
      var value = _convertIterable(field.type, 'obj.${field.name}');
      code.writeln('''
      ..writeByte(${field.index})
      ..write($value)''');
    }
    code.writeln(';');

    return code.toString();
  }

  String _convertIterable(DartType type, String accessor) {
    if (listChecker.isAssignableFromType(type)) {
      return accessor;
    } else
    // Using assignable because Set? and Iterable? are not exactly Set and
    // Iterable
    if (setChecker.isAssignableFromType(type) ||
        iterableChecker.isAssignableFromType(type)) {
      var suffix = _accessorSuffixFromType(type);
      return '$accessor$suffix.toList()';
    } else {
      return accessor;
    }
  }
}

class BuiltClassBuilder extends ClassBuilder {
  BuiltClassBuilder(
    InterfaceElement interface,
    List<AdapterField> getters,
    List<AdapterField> setters,
  ) : super(interface, getters, setters);

  var builtValueChecker = const TypeChecker.fromRuntime(bv.BuiltValue);

  var builtChecker = const TypeChecker.fromRuntime(bv.Built);
  var builtListChecker = const TypeChecker.fromRuntime(BuiltList);
  var builtSetChecker = const TypeChecker.fromRuntime(BuiltSet);
  var builtMapChecker = const TypeChecker.fromRuntime(BuiltMap);

  var builderChecker = const TypeChecker.fromRuntime(bv.Builder);
  var listBuilderChecker = const TypeChecker.fromRuntime(ListBuilder);
  var setBuilderChecker = const TypeChecker.fromRuntime(SetBuilder);
  var mapBuilderChecker = const TypeChecker.fromRuntime(MapBuilder);

  final typeAdapterGenerator = TypeAdapterGenerator();

  DartType get builderType => interface.interfaces
      .singleWhere(builtChecker.isExactlyType)
      .typeArguments
      .last;

  bool _nestedBuildersFromAnnotation() {
    final annotation = interface.metadata
        .map(
          (e) => e.computeConstantValue(),
        )
        .singleWhere(
          (e) => e?.type != null
              ? builtValueChecker.isExactlyType(e!.type!)
              : false,
          orElse: () => null,
        );
    if (annotation == null) {
      print('no annotation on ${interface.displayName}');
      return true;
    }
    final reader = ConstantReader(annotation);
    final nestedBuilders = reader.read('nestedBuilders');
    if (nestedBuilders.isNull) {
      return true;
    }
    print(
        'annotation on ${interface.displayName}: ${nestedBuilders.boolValue}');
    return nestedBuilders.boolValue;
  }

  @override
  String buildRead() {
    var code = StringBuffer();
    code.writeln('''
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    ''');

    String builderName;
    List<AdapterField> fields;
    bool nestedBuilders;

    // In case the builder is being generated, we assume it has the default
    // name and fields
    if (!builderType.isDynamic) {
      // The builder type was manually created, therefore we look it up for
      // @HiveField annotations
      final builderCls = builderType.element as ClassElement;
      builderName = builderCls.name;
      var gettersAndSetters =
          typeAdapterGenerator.getAccessors(builderCls, builderCls.library);

      var setters = gettersAndSetters[1];
      typeAdapterGenerator.verifyFieldIndices(setters);

      // The fields that need to be set on the cascade are the setters in the
      // builder class.
      fields = setters;

      // We do not need to look it up in the annotation, as this information is
      // contained in each setter's DartType, allowing for correct casting.
      nestedBuilders = false;
    } else {
      builderName = '${interface.name}Builder';

      // The fields that need to be set on the cascade are the getters in the
      // built class, because they have an corresponding setter in the builder.
      fields = getters;

      // We want to set an builder instead of the built class depending on the
      // @BuiltValue annotation, but we cant express this easily with DartType,
      // so we pass this info to cast()
      nestedBuilders = _nestedBuildersFromAnnotation();
    }

    // Instantiate the builder
    code.writeln('    return ($builderName()');

    // Initialize the parameters using setters with cascades on the builder.
    for (var field in fields) {
      code.writeln('..${field.name} = ${_cast(
        field.type,
        'fields[${field.index}]',
        nestedBuilders,
      )}');
    }

    // Build the class
    code.write(').build()');

    code.writeln(';');

    return code.toString();
  }

  String _castBuiltCollection(
    DartType type,
    String variable, [
    bool nestedBuilders = false,
  ]) {
    String? builderConstructor;
    String? typeToBeCasted;
    // Wether or not we should call build() on the end.
    //
    // This when the user annotated with nestedBuilders = false, so the Builder
    // for that class expects an Built value, instead of a builder.
    //
    // This is not the case when either nestedBuilders is true or ommited, or
    // when an custom builder was specified with an ListBuilder for example.
    var shouldBeBuilt = !nestedBuilders || isBuilderOrCollectionBuilder(type);

    if (builtMapChecker.isExactlyType(type) ||
        mapBuilderChecker.isExactlyType(type)) {
      builderConstructor = 'MapBuilder';
      typeToBeCasted = 'Map';
    } else {
      typeToBeCasted = 'Iterable';
      if (builtSetChecker.isExactlyType(type) ||
          setBuilderChecker.isExactlyType(type)) {
        builderConstructor = 'SetBuilder';
      }
      if (builtListChecker.isExactlyType(type) ||
          listBuilderChecker.isExactlyType(type)) {
        builderConstructor = 'ListBuilder';
      }
    }
    check(
      builderConstructor != null,
      Exception('Unrecognized built_collection type ${_displayString(type)}'),
    );

    final buildExpression = '$builderConstructor<${_typeParamsString(type)}>'
        '($variable as $typeToBeCasted)'
        '${shouldBeBuilt ? '.build()' : ''}';

    return '$variable == null ? null : $buildExpression';
  }

  @override
  String _cast(
    DartType type,
    String variable, [
    bool nestedBuilders = false,
  ]) {
    if (!isBuiltOrBuiltCollection(type) &&
        !isBuilderOrCollectionBuilder(type)) {
      // This value needs no special treatment.
      return super._cast(type, variable);
    }

    if ((isBuilt(type) && nestedBuilders) || isBuilder(type)) {
      // We need to call .toBuilder(), because variable is always an Built
      // value, but we need an Builder value.
      return '($variable as ${_displayString(type)})?.toBuilder()';
    }

    if (isBuiltCollection(type) || isCollectionBuilder(type)) {
      return _castBuiltCollection(type, variable, nestedBuilders);
    }

    // We just need to cast the value. This happens when the type is of a Built
    // value in a custom Builder which accepts the plain Built value instead of
    // a builder, for example.
    return '$variable as ${_displayString(type)}';
  }

  bool isBuilt(DartType type) {
    return builtChecker.isAssignableFromType(type);
  }

  bool isBuiltCollection(DartType type) {
    return builtListChecker.isExactlyType(type) ||
        builtSetChecker.isExactlyType(type) ||
        builtMapChecker.isExactlyType(type);
  }

  bool isBuiltOrBuiltCollection(DartType type) {
    return isBuilt(type) || isBuiltCollection(type);
  }

  bool isBuilder(DartType type) {
    return builderChecker.isAssignableFromType(type);
  }

  bool isCollectionBuilder(DartType type) {
    return listBuilderChecker.isExactlyType(type) ||
        setBuilderChecker.isExactlyType(type) ||
        mapBuilderChecker.isExactlyType(type);
  }

  bool isBuilderOrCollectionBuilder(DartType type) {
    return isBuilder(type) || isCollectionBuilder(type);
  }

  String _typeParamsString(DartType type) {
    var paramType = type as ParameterizedType;
    var typeParams = paramType.typeArguments.map(_displayString);
    return typeParams.join(', ');
  }

  @override
  String _convertIterable(DartType type, String accessor) {
    if (isBuiltCollection(type)) {
      return builtMapChecker.isExactlyType(type)
          ? '$accessor?.toMap()'
          : '$accessor?.toList()';
    } else {
      return super._convertIterable(type, accessor);
    }
  }
}

extension _FirstOrNullWhere<T> on Iterable<T> {
  T? firstOrNullWhere(bool Function(T) predicate) {
    for (var it in this) {
      if (predicate(it)) {
        return it;
      }
    }
    return null;
  }
}

/// Suffix to use when accessing a field in [type].
/// $variable$suffix.field
String _accessorSuffixFromType(DartType type) {
  if (type.nullabilitySuffix == NullabilitySuffix.star) {
    return '?';
  }
  if (type.nullabilitySuffix == NullabilitySuffix.question) {
    return '?';
  }
  return '';
}

/// Suffix to use when casting a value to [type].
/// $variable as $type$suffix
String _suffixFromType(DartType type) {
  if (type.nullabilitySuffix == NullabilitySuffix.star) {
    return '';
  }
  if (type.nullabilitySuffix == NullabilitySuffix.question) {
    return '?';
  }
  return '';
}

String _displayString(DartType e) {
  var suffix = _suffixFromType(e);
  return '${e.getDisplayString(withNullability: false)}$suffix';
}
