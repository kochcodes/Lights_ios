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
                        Text("Name").badge(
                            Text(bleManager.device.name)
                        )
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
                            if( bleManager.device.mode != -1){
                                Text("Mode").badge(
                                    Text(String(bleManager.device.mode))
                                )
                            }
                            Button(action: {
                                bleManager.sendPercentage(value: 20)
                            }) {
                                Text("Send")
                            }
                        }
                    } header: {
                        Text("Lights found")
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
