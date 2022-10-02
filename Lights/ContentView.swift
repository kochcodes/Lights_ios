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
        ZStack{
            Image("header")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.size.width, height: 200, alignment: .center)
                .clipped()
            Rectangle()
                .fill(LinearGradient(
                    gradient: .init(colors: [Color.black, Color.black.opacity(0), Color.black.opacity(0), Color.black]),
                    startPoint: .init(x: 0, y: 0),
                    endPoint: .init(x: 0, y: 1)
                ))
                .frame(width: UIScreen.main.bounds.size.width, height: 200, alignment: .bottom)
            Text("Lights")
                .font(.system(size: 50))
                .padding(.leading, 20)
                .frame(width: UIScreen.main.bounds.size.width, height: 200, alignment: .bottomLeading)
        }
        .frame(width: UIScreen.main.bounds.size.width)
        
        List{
            if( !bleManager.isSwitchedOn ){
                Section{
                    Text("Bluetooth").badge(
                        Text(bleManager.isSwitchedOn ? "on" : "off")
                    )
                } header: {
                    Text("System Status")
                } footer: {
                    Text("To use this app and your bike lights, you need to turn on Bluetooth and allow this app to use Bluetooth.")
                }
            } else {
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
                        Text("RSSI").badge(
                            Text(String(bleManager.device.rssi) + " dBm")
                        )
                        if(bleManager.device.status == "connected"){
                            if( bleManager.device.batteryLevel != -1){
                                Text("Blink Routine").badge(
                                    Text(String(bleManager.device.blink_routine))
                                )
                            }
                            if( bleManager.device.sent_messages != -1){
                                Text("Sent Messages").badge(
                                    Text(String(bleManager.device.sent_messages))
                                )
                            }
                            if( bleManager.device.delivered_messages != -1){
                                Text("Delivered Messages").badge(
                                    Text(String(bleManager.device.delivered_messages))
                                )
                            }
                            if( bleManager.device.received_messages != -1){
                                Text("Received Messages").badge(
                                    Text(String(bleManager.device.received_messages))
                                )
                            }
                        }
                    } header: {
                        Text("Lights " + (bleManager.device.status == "connected" ? "connected" : "found"))
                    }
                    if(bleManager.device.status == "connected" && bleManager.device.mode >= 0){
                        Section{
                            if( bleManager.device.mode == 0){
                                Button(action: {
                                    bleManager.sendMode(value: 1)
                                }) {
                                    Text("Switch to slave mode")
                                }
                            } else if( bleManager.device.mode == 1){
                                Button(action: {
                                    bleManager.sendMode(value: 0)
                                }) {
                                    Text("Switch to master mode")
                                }
                            }
                        } header: {
                            Text( bleManager.device.mode > 0 ? "Slave Mode" : "Master Mode")
                        }
                        Section{
                            Button(action: {
                                bleManager.sendRoutine(value: 0)
                            }) {
                                Text("Mode 0")
                            }
                            Button(action: {
                                bleManager.sendRoutine(value: 1)
                            }) {
                                Text("Mode 1")
                            }
                            Button(action: {
                                bleManager.sendRoutine(value: 2)
                            }) {
                                Text("Mode 2")
                            }
                            Button(action: {
                                bleManager.sendRoutine(value: 3)
                            }) {
                                Text("Mode 3")
                            }
                        } header: {
                            Text("Light Modes")
                        }
                        
                    }
                    
                    if( bleManager.device.status == "connected"){
                        Button(action: {
                            bleManager.disconnect()
                        }) {
                            Text("Disconnect")
                        }
                    }
                    
                    if( bleManager.device.status == "ready"){
                        Button(action: {
                            bleManager.connect()
                        }) {
                            Text("Connect")
                        }
                    }
                }
            }
            if(bleManager.device != nil){
                if(bleManager.otherDevices.count > 0 && bleManager.device.status != "connected"){
                    Section{
                        Text("Other devices (" + String(bleManager.otherDevices.count) + ")")
                    }
                }
            }
        }.preferredColorScheme(.dark)
        .background(Color.purple)
        // end View here
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
