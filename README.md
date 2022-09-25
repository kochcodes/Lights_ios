# Light Controller App
This app is meant to be the BLE connection point to the light system.
The light system consists of multiple wireless lights, which are syncronized via esp-now. With syncronized I mean, really syncron (< 1ms).
More info about the sync lights can be found in this repo [here](https://github.com/kochcodes/ESP8266MultiDeviceSyncLight).

This app is there to switch modes between the different animations, set the power etc. of one edge. (This edge needs a ESP32 due to BLE connectivity instead of an ESP8266).

The sync between the single edges is handled by the mesh itself.

### Screenshots

<img src="https://github.com/kochcodes/Lights_ios/blob/main/docs/IMG_276500648773-1.jpeg" data-canonical-src="https://github.com/kochcodes/Lights_ios/blob/main/docs/IMG_276500648773-1.jpeg" width="250" />
