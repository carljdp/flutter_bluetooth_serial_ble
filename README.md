
# `flutter_bluetooth_serial_ble`


---

## This branch `build-repair` is just an attempt to fix the build process of the example application.
It is not intended to be merged into anywhere as-is.

### Additional steps taken outside of this repo:

- add a namespace property to the `android` section of the `build.gradle` file
  of the `integration_test` package (dependency)

- download an archived Flutter SDK v3.7.12, available from Github,
  [or here](https://docs.flutter.dev/release/archive)

### Run flutter commands via wrapper script:

I've added a wrapper script at both `./tools` and `./example/tools` directories
that you can invoke similarly to the `flutter` command, but it will read and use the
Flutter SDK version specified in your `local.properties` file.

Example usage:

```powershell

.\tool\legacy_flutter.ps1 clean`

.\tool\legacy_flutter.ps1 devices list

# Note that opts/flags/switches starting with `-` should be enclosed in quotes..

.\tool\legacy_flutter.ps1 run "--debug" "-d" "'SM J530F'"`

.\tool\legacy_flutter.ps1 build apk "--debug" "-d" "'SM J530F'"`

```

---


[![pub package](https://img.shields.io/pub/v/flutter_bluetooth_serial_ble.svg)](https://pub.dartlang.org/packages/flutter_bluetooth_serial_ble)

Flutter basic implementation for Classical Bluetooth (only RFCOMM for now), and now also BLE.  I hacked out parts of [SimpleBluetoothLeTerminal](https://github.com/kai-morich/SimpleBluetoothLeTerminal) and glued them to [flutter_bluetooth_serial](https://github.com/edufolly/flutter_bluetooth_serial) and now `BluetoothConnection.toAddress` accepts a second parameter, `type`, defaulting to `AUTO`, giving the behavior of trying to connect with the usual BT Classic mechanism first, then switching to BLE if that fails.  (Note this makes the default behavior slow to connect to a BLE device.)  It should work out of the box, a drop-in replacement of the previous version, aside from the addition of two "_ble"s to the imports.  Hasn't been tested very rigorously yet, sorry.  I do note that BLE connection fails the first time I try after installing the app, and is fine after that - probably some permissions thing in the wrong place.  Check permissions if you have trouble.


## Features

The first goal of this project, started by @edufolly was making an interface for Serial Port Protocol (HC-05 Adapter). Now the plugin features:

+ Adapter status monitoring,

+ Turning adapter on and off,

+ Opening settings,

+ Discovering devices (and requesting discoverability),

+ Listing bonded devices and pairing new ones,

+ Connecting to multiple devices at the same time,

+ Sending and receiving data (multiple connections).

The plugin (for now) uses Serial Port profile for moving data over RFCOMM, so make sure there is running Service Discovery Protocol that points to SP/RFCOMM channel of the device. There could be [max up to 7 Bluetooth connections](https://stackoverflow.com/a/32149519/4880243).

For now there is only Android support.


## Getting Started

#### Depending 
```yaml
# Add dependency to `pubspec.yaml` of your project.
dependencies:
    # ...
    flutter_bluetooth_serial_ble: ^0.5.0
```

#### Installing

```bash
# With pub manager
pub get
# or with Flutter
flutter pub get
```

#### Importing
```dart
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
```

#### Usage

You should look to the Dart code of the library (mostly documented functions) or to the examples code. 
```dart
// Some simplest connection :F
try {
    BluetoothConnection connection = await BluetoothConnection.toAddress(address);
    print('Connected to the device');

    connection.input.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        connection.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
            connection.finish(); // Closing connection
            print('Disconnecting by local host');
        }
    }).onDone(() {
        print('Disconnected by remote request');
    });
}
catch (exception) {
    print('Cannot connect, exception occured');
}
```

Note: Work is underway to make the communication easier than operations on byte streams. See #41 for discussion about the topic.

#### Examples

Check out [example application](example/README.md) with connections with both Arduino HC-05 and Raspberry Pi (RFCOMM) Bluetooth interfaces.

Main screen and options |  Discovery and connecting  |  Simple chat with server  |  Background connection  |
:---:|:---:|:---:|:---:|
![](https://i.imgur.com/qeeMsVe.png)  |  ![](https://i.imgur.com/zruuelZ.png)  |  ![](https://i.imgur.com/y5mTUey.png)  |  ![](https://i.imgur.com/3wvwDVo.png)


## To-do list

+ Add some utils to easier manage `BluetoothConnection` (see discussion #41),
+ Allow connection method/protocol/UUID specification,
+ Listening/server mode,
+ Recognizing and displaying `BluetoothClass` of device,
+ Maybe integration with `flutter_blue` one day ;)

You might also want to check [milestones](https://github.com/edufolly/flutter_bluetooth_serial/milestones).


## Credits

- [Eduardo Folly](mailto:edufolly@gmail.com)
- [Martin Mauch](mailto:martin.mauch@gmail.com)
- [Patryk Ludwikowski](mailto:patryk.ludwikowski.7@gmail.com)
- https://github.com/kai-morich/SimpleBluetoothLeTerminal for BLE code

After version 0.3.0 we have a lot of collaborators. If you would like to be credited, please send me an [email](mailto:edufolly@gmail.com).

#### Thanks for all the support!