# Light Controller App

<img src="https://github.com/kochcodes/Lights_ios/blob/main/Lights/Assets.xcassets/AppIcon.appiconset/icon-83.5@2x.png?raw=true" width="120"/>

iOS/iPadOS app for controlling synchronized wireless LED lighting systems via Bluetooth Low Energy (BLE).

## Description

This native iOS application provides wireless control for a mesh network of synchronized LED lights. It connects via BLE to an ESP32 hub which coordinates multiple ESP8266-based light nodes synchronized via ESP-NOW. The system achieves sub-millisecond synchronization across all connected lights.

## Features

- **BLE Control** - Wireless communication with ESP32 lighting hub
- **Mode Selection** - Switch between different lighting animations
- **Power Management** - Adjust brightness and power levels
- **Real-time Control** - Instant response with <1ms sync across mesh
- **Multiple Animations** - Various lighting effects and patterns
- **User-friendly UI** - Clean, intuitive interface for light control

## System Architecture

The app is part of a three-component system:

```
[iOS App] ←BLE→ [ESP32 Hub] ←ESP-NOW→ [ESP8266 Lights]
(This repo)    (Lights_ESP32)      (Synchronized Mesh)
```

### Components

1. **iOS App** (this repository) - User interface and BLE client
2. **[ESP32 Hub](https://github.com/kochcodes/Lights_ESP32)** - BLE server and ESP-NOW coordinator
3. **[ESP8266 Lights](https://github.com/kochcodes/ESP8266MultiDeviceSyncLight)** - Synchronized light nodes

## Screenshots

<img src="https://github.com/kochcodes/Lights_ios/blob/main/docs/IMG_3587.PNG?raw=true" width="200" /> <img src="https://github.com/kochcodes/Lights_ios/blob/main/docs/IMG_3588.PNG?raw=true" width="200" /> <img src="https://github.com/kochcodes/Lights_ios/blob/main/docs/IMG_3589.PNG?raw=true" width="200" /> <img src="https://github.com/kochcodes/Lights_ios/blob/main/docs/IMG_3590.PNG?raw=true" width="200" />

## Requirements

- **iOS 14.0+** or **iPadOS 14.0+**
- **Xcode 12.0+** for building from source
- **ESP32 lighting hub** with firmware from [Lights_ESP32](https://github.com/kochcodes/Lights_ESP32)
- **BLE capability** on iOS device

## Installation

### From Source

1. Clone the repository:
\`\`\`bash
git clone https://github.com/kochcodes/Lights_ios.git
cd Lights_ios
\`\`\`

2. Open the project in Xcode:
\`\`\`bash
open Lights.xcodeproj
\`\`\`

3. Select your development team in project settings

4. Build and run on your iOS device or simulator

## Usage

### First Time Setup

1. **Ensure ESP32 hub is powered** and running the Lights_ESP32 firmware
2. **Launch the app** on your iOS device
3. **Enable Bluetooth** if prompted
4. **Scan for devices** - The ESP32 hub should appear
5. **Connect** to the hub

### Controlling Lights

- **Mode Selection**: Tap different animation modes to change lighting effects
- **Power Control**: Use sliders to adjust brightness
- **Edge Control**: Manage individual light segments
- **Sync Status**: View real-time connection and synchronization status

## Features in Detail

### Animation Modes

The app supports multiple lighting animations:
- Solid colors
- Fading effects
- Rainbow patterns
- Custom animations
- And more...

### Edge Management

Control individual "edges" (light segments) independently while maintaining synchronization across the entire mesh network. The mesh handles synchronization automatically via ESP-NOW.

### BLE Communication

The app uses Core Bluetooth framework to:
- Discover ESP32 devices
- Establish BLE connections
- Send control commands
- Receive status updates

## Development

### Project Structure

\`\`\`
Lights_ios/
├── Lights/                 # Main app code
│   ├── ViewControllers/    # UI controllers
│   ├── Models/             # Data models
│   ├── BLE/                # Bluetooth handling
│   └── Assets.xcassets/    # Images and resources
├── Lights.xcodeproj/       # Xcode project
└── docs/                   # Screenshots and documentation
\`\`\`

### Building

- Open \`Lights.xcodeproj\` in Xcode
- Select target device
- Build and run (Cmd+R)

## Architecture

The app uses:
- **Core Bluetooth** for BLE communication
- **UIKit** for user interface
- **MVC pattern** for code organization
- **SwiftUI** components (where applicable)

## Troubleshooting

### BLE Connection Issues
- Ensure Bluetooth is enabled on iOS device
- Verify ESP32 is powered and advertising
- Check that no other device is connected to the ESP32

### Synchronization Problems
- Confirm ESP8266 lights are on the same network
- Verify ESP-NOW mesh is properly configured
- Check ESP32 hub firmware is up to date

### App Crashes
- Check Xcode console for error messages
- Verify iOS version compatibility
- Ensure proper permissions are granted

## Related Projects

- **[Lights_ESP32](https://github.com/kochcodes/Lights_ESP32)** - ESP32 BLE hub firmware
- **[ESP8266MultiDeviceSyncLight](https://github.com/kochcodes/ESP8266MultiDeviceSyncLight)** - ESP8266 synchronized light nodes

## License

Open source - check repository for license details.

## Tags

\`ios\` \`swift\` \`ble\` \`bluetooth\` \`home-automation\` \`led-control\` \`esp32\` \`lighting\` \`mesh-network\` \`core-bluetooth\`
