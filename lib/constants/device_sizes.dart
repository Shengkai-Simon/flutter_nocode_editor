import 'dart:ui';

/// A class to represent a device's screen size.
class DeviceSize {
  final String name;
  final Size size;

  const DeviceSize(this.name, this.size);
}

/// A list of predefined device sizes for the canvas.
const List<DeviceSize> kPredefinedDeviceSizes = [
  DeviceSize('iPhone 16 Pro Max', Size(430, 932)),
  DeviceSize('iPhone 16 Pro', Size(393, 852)),
  DeviceSize('iPhone 16', Size(393, 852)),
  DeviceSize('Google Pixel 9 Pro', Size(412, 915)),
  DeviceSize('Google Pixel 9', Size(412, 914)),
  DeviceSize('iPhone SE (3rd gen)', Size(375, 667)),
  DeviceSize('Samsung Galaxy S23 Ultra', Size(360, 740)),
  DeviceSize('Custom', Size(0, 0)), // Represents the custom option
];