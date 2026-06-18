// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthHiveModelAdapter extends TypeAdapter<AuthHiveModel> {
  @override
  final int typeId = 0;

  @override
  AuthHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthHiveModel(
      authId: fields[0] as String?,
      username: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      password: fields[4] as String?,
      role: fields[5] as String,
      accountStatus: fields[6] as String,
      imageUrl: fields[7] as String?,
      vehicleModel: fields[8] as String?,
      vehicleColor: fields[9] as String?,
      numberPlate: fields[10] as String?,
      licenseNumber: fields[11] as String?,
      isAvailable: fields[12] as bool?,
      location: (fields[13] as List?)?.cast<double>(),
      vehicleType: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.authId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.accountStatus)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.vehicleModel)
      ..writeByte(9)
      ..write(obj.vehicleColor)
      ..writeByte(10)
      ..write(obj.numberPlate)
      ..writeByte(11)
      ..write(obj.licenseNumber)
      ..writeByte(12)
      ..write(obj.isAvailable)
      ..writeByte(13)
      ..write(obj.location)
      ..writeByte(14)
      ..write(obj.vehicleType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
