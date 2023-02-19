// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BuiltEnum _$builtEnumValue1 = const BuiltEnum._('value1');
const BuiltEnum _$builtEnumValue2 = const BuiltEnum._('value2');

BuiltEnum _$builtEnumValueOf(String name) {
  switch (name) {
    case 'value1':
      return _$builtEnumValue1;
    case 'value2':
      return _$builtEnumValue2;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<BuiltEnum> _$builtEnumValues =
    new BuiltSet<BuiltEnum>(const <BuiltEnum>[
  _$builtEnumValue1,
  _$builtEnumValue2,
]);

Serializer<BuiltClass> _$builtClassSerializer = new _$BuiltClassSerializer();
Serializer<BuiltEnum> _$builtEnumSerializer = new _$BuiltEnumSerializer();

class _$BuiltClassSerializer implements StructuredSerializer<BuiltClass> {
  @override
  final Iterable<Type> types = const [BuiltClass, _$BuiltClass];
  @override
  final String wireName = 'BuiltClass';

  @override
  Iterable<Object?> serialize(Serializers serializers, BuiltClass object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'param1',
      serializers.serialize(object.param1, specifiedType: const FullType(int)),
      'param2',
      serializers.serialize(object.param2,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  BuiltClass deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new BuiltClassBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'param1':
          result.param1 = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'param2':
          result.param2 = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$BuiltEnumSerializer implements PrimitiveSerializer<BuiltEnum> {
  @override
  final Iterable<Type> types = const <Type>[BuiltEnum];
  @override
  final String wireName = 'BuiltEnum';

  @override
  Object serialize(Serializers serializers, BuiltEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  BuiltEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BuiltEnum.valueOf(serialized as String);
}

class _$BuiltClass extends BuiltClass {
  @override
  final int param1;
  @override
  final String param2;

  factory _$BuiltClass([void Function(BuiltClassBuilder)? updates]) =>
      (new BuiltClassBuilder()..update(updates))._build();

  _$BuiltClass._({required this.param1, required this.param2}) : super._() {
    BuiltValueNullFieldError.checkNotNull(param1, r'BuiltClass', 'param1');
    BuiltValueNullFieldError.checkNotNull(param2, r'BuiltClass', 'param2');
  }

  @override
  BuiltClass rebuild(void Function(BuiltClassBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BuiltClassBuilder toBuilder() => new BuiltClassBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BuiltClass &&
        param1 == other.param1 &&
        param2 == other.param2;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, param1.hashCode);
    _$hash = $jc(_$hash, param2.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BuiltClass')
          ..add('param1', param1)
          ..add('param2', param2))
        .toString();
  }
}

class BuiltClassBuilder implements Builder<BuiltClass, BuiltClassBuilder> {
  _$BuiltClass? _$v;

  int? _param1;
  int? get param1 => _$this._param1;
  set param1(int? param1) => _$this._param1 = param1;

  String? _param2;
  String? get param2 => _$this._param2;
  set param2(String? param2) => _$this._param2 = param2;

  BuiltClassBuilder();

  BuiltClassBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _param1 = $v.param1;
      _param2 = $v.param2;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuiltClass other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$BuiltClass;
  }

  @override
  void update(void Function(BuiltClassBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BuiltClass build() => _build();

  _$BuiltClass _build() {
    final _$result = _$v ??
        new _$BuiltClass._(
            param1: BuiltValueNullFieldError.checkNotNull(
                param1, r'BuiltClass', 'param1'),
            param2: BuiltValueNullFieldError.checkNotNull(
                param2, r'BuiltClass', 'param2'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Class1Adapter extends TypeAdapter<Class1> {
  @override
  final int typeId = 1;

  @override
  Class1 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Class1(
      fields[0] == null
          ? const Class2(4, 'param', {
              5: {
                'magic': [
                  const Class1(const Class2(5, 'sad')),
                  const Class1(const Class2(5, 'sad'), Enum1.emumValue1)
                ]
              },
              67: {
                'hold': [const Class1(const Class2(42, 'meaning of life'))]
              }
            })
          : fields[0] as Class2,
    );
  }

  @override
  void write(BinaryWriter writer, Class1 obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.nested);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Class1Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class Class2Adapter extends TypeAdapter<Class2> {
  @override
  final int typeId = 2;

  @override
  Class2 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Class2(
      fields[0] == null ? 0 : fields[0] as int,
      fields[1] as String,
      (fields[6] as Map?)?.map((dynamic k, dynamic v) => MapEntry(
          k as int,
          (v as Map).map((dynamic k, dynamic v) =>
              MapEntry(k as String, (v as List).cast<Class1>())))),
    );
  }

  @override
  void write(BinaryWriter writer, Class2 obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.param1)
      ..writeByte(1)
      ..write(obj.param2)
      ..writeByte(6)
      ..write(obj.what);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Class2Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmptyClassAdapter extends TypeAdapter<EmptyClass> {
  @override
  final int typeId = 4;

  @override
  EmptyClass read(BinaryReader reader) {
    return EmptyClass();
  }

  @override
  void write(BinaryWriter writer, EmptyClass obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmptyClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuiltClassAdapter extends TypeAdapter<BuiltClass> {
  @override
  final int typeId = 5;

  @override
  BuiltClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return (BuiltClassBuilder()
          ..param1 = fields[0] as int
          ..param2 = fields[1] as String)
        .build();
  }

  @override
  void write(BinaryWriter writer, BuiltClass obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.param1)
      ..writeByte(1)
      ..write(obj.param2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuiltClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuiltEnumAdapter extends TypeAdapter<BuiltEnum> {
  @override
  final int typeId = 6;

  @override
  BuiltEnum read(BinaryReader reader) {
    return BuiltEnum.valueOf(reader.read() as String);
  }

  @override
  void write(BinaryWriter writer, BuiltEnum obj) {
    writer.write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuiltEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class Enum1Adapter extends TypeAdapter<Enum1> {
  @override
  final int typeId = 3;

  @override
  Enum1 read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Enum1.emumValue1;
      case 1:
        return Enum1.emumValue2;
      case 2:
        return Enum1.emumValue3;
      default:
        return Enum1.emumValue2;
    }
  }

  @override
  void write(BinaryWriter writer, Enum1 obj) {
    switch (obj) {
      case Enum1.emumValue1:
        writer.writeByte(0);
        break;
      case Enum1.emumValue2:
        writer.writeByte(1);
        break;
      case Enum1.emumValue3:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Enum1Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
