// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookingHiveModelAdapter extends TypeAdapter<BookingHiveModel> {
  @override
  final int typeId = 2;

  @override
  BookingHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookingHiveModel(
      bookingId: fields[0] as String?,
      user: fields[1] as AuthHiveModel?,
      driver: fields[2] as AuthHiveModel?,
      vehicleType: fields[3] as String,
      pickupCoordinates: (fields[4] as List).cast<double>(),
      dropCoordinates: (fields[5] as List).cast<double>(),
      distance: fields[6] as double?,
      price: fields[7] as int?,
      status: fields[8] as String,
      goodsTypes: (fields[9] as List).cast<String>(),
      pickupAddress: fields[17] as String,
      dropAddress: fields[18] as String,
      cancelledBy: fields[10] as String?,
      startedAt: fields[11] as DateTime?,
      completedAt: fields[12] as DateTime?,
      acceptedAt: fields[13] as DateTime?,
      estimatedArrival: fields[14] as int?,
      createdAt: fields[15] as DateTime?,
      updatedAt: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BookingHiveModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.bookingId)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.driver)
      ..writeByte(3)
      ..write(obj.vehicleType)
      ..writeByte(4)
      ..write(obj.pickupCoordinates)
      ..writeByte(5)
      ..write(obj.dropCoordinates)
      ..writeByte(6)
      ..write(obj.distance)
      ..writeByte(7)
      ..write(obj.price)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.goodsTypes)
      ..writeByte(10)
      ..write(obj.cancelledBy)
      ..writeByte(11)
      ..write(obj.startedAt)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.acceptedAt)
      ..writeByte(14)
      ..write(obj.estimatedArrival)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.pickupAddress)
      ..writeByte(18)
      ..write(obj.dropAddress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
