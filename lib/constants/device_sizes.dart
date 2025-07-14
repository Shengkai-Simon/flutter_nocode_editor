import 'package:flutter/material.dart';

/// A class to represent a device's screen size.
class DeviceSize {
  final String name;
  final Size size;

  const DeviceSize(this.name, this.size);
}

/// A class to represent a category of devices.
class DeviceCategory {
  final String name;
  final IconData icon;
  final List<DeviceSize> devices;

  const DeviceCategory({
    required this.name,
    required this.icon,
    required this.devices,
  });
}

/// A list of predefined device categories for the canvas.
const List<DeviceCategory> kPredefinedDeviceCategories = [
  DeviceCategory(
    name: 'Phone',
    icon: Icons.smartphone,
    devices: [
      DeviceSize('iPhone 16 Pro Max', Size(430, 932)),
      DeviceSize('iPhone 16 Pro', Size(393, 852)),
      DeviceSize('iPhone 16', Size(393, 852)),
      DeviceSize('Google Pixel 9 Pro', Size(412, 915)),
      DeviceSize('Google Pixel 9', Size(412, 914)),
      DeviceSize('iPhone SE (3rd gen)', Size(375, 667)),
      DeviceSize('Samsung Galaxy S23 Ultra', Size(360, 740)),
    ],
  ),
  DeviceCategory(
    name: 'Tablet',
    icon: Icons.tablet_mac,
    devices: [
      DeviceSize('iPad Pro 12.9"', Size(1024, 1366)),
      DeviceSize('iPad Pro 11"', Size(834, 1194)),
      DeviceSize('iPad Air', Size(820, 1180)),
      DeviceSize('iPad Mini', Size(768, 1024)),
    ],
  ),
  DeviceCategory(
    name: 'Desktop',
    icon: Icons.desktop_mac,
    devices: [
      DeviceSize('Desktop 1080p', Size(1920, 1080)),
      DeviceSize('Desktop 1440p', Size(2560, 1440)),
      DeviceSize('Laptop', Size(1440, 900)),
      DeviceSize('Small Laptop', Size(1280, 800)),
    ],
  ),
  DeviceCategory(
    name: 'Other',
    icon: Icons.devices_other,
    devices: [
      DeviceSize('Custom', Size(0, 0)), // Represents the custom option
    ],
  ),
];