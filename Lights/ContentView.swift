//
//  ContentView.swift
//  Lights
//
//  Created by Christopher Koch on 24.09.22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    Text("Bluetooth").badge(
                        Text(bleManager.isSwitchedOn ? "on" : "off")
                    )
                } header: {
                    Text("System Status")
                }
                if(bleManager.device == nil){
                    Section{
                        if(!bleManager.isScanning){
                            Button(action: {
                                self.bleManager.startScanning()
                            }) {
                                Text("Start")
                            }
                        } else {
                            Button(action: {
                                self.bleManager.stopScanning()
                            }) {
                                Text("Stop")
                            }
                        }
                    }header: {
                        Text("BLE Scanning")
                    }
                } else {
                    Section{
                        Text("Status").badge(
                            Text(String(bleManager.device.status))
                        )
                        Text("RSSI").badge(
                            Text(String(bleManager.device.rssi) + " dBm")
                        )
                        if(bleManager.device.status == "connected"){
                            if( bleManager.device.batteryLevel != -1){
                                Text("Battery Level").badge(
                                    Text(String(bleManager.device.batteryLevel) + "%")
                                )
                            }
                            if( bleManager.device.percentage != -1){
                                Text("Percentage").badge(
                                    Text(String(bleManager.device.percentage) + "%")
                                )
                            }
                        }
                        if( bleManager.device.status == "ready"){
                            Button(action: {
                                bleManager.connect()
                            }) {
                                Text("Connect")
                            }
                        }
                        if( bleManager.device.status == "connected"){
                            Button(action: {
                                bleManager.sendPercentage(value: 20)
                            }) {
                                Text("Send")
                            }
                        }
                    } header: {
                        Text(bleManager.device.name)
                    }
                    Section{
                        Button(action: {
                            bleManager.disconnect()
                        }) {
                            Text("Disconnect")
                        }
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
