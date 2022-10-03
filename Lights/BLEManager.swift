//
//  BLEManager.swift
//  Lights
//
//  Created by Christopher Koch on 24.09.22.
//

import Foundation
import CoreBluetooth

struct Peripheral: Identifiable {
    var id: Int
    let name: String
    var rssi: Int
    var status: String
    var batteryLevel: Int
    var percentage: Int
    var sent_messages: Int
    var delivered_messages: Int
    var received_messages: Int
    var blink_routine: Int
    var mode: Int
}

struct Others: Identifiable{
    var id: Int
    let name: String
    let rssi: Int
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isSwitchedOn = false
    @Published var isScanning = false
    
    @Published var otherDevices: [Others] = []
    
    var myCentral: CBCentralManager!
    var myPeripheral: CBPeripheral!
    @Published var device: Peripheral!
    
    var setRoutineCharacteristic: CBCharacteristic?
    var setModeCharacteristic: CBCharacteristic?
    
    let batteryServiceCBUUID = CBUUID(string: "0x180F")
    let batteryLevelCharacteristicCBUUID = CBUUID(string: "2A19")
    
    let routineServiceCBUUID = CBUUID(string: "0x27AD")
    let routineCharacteristicCBUUID = CBUUID(string: "0x2A6E")

    let modeServiceCBUUID = CBUUID(string: "0x27AE")
    let modeCharacteristicCBUUID = CBUUID(string: "0x2A6F")
    
    let stateServiceCBUUID = CBUUID(string: "0x27AF")
    let stateSentMessagesCharacteristicCBUUID = CBUUID(string: "0x2A70")
    let stateReceivedMessagesCharacteristicCBUUID = CBUUID(string: "0x2A71")
    let stateDeliveredMessagesCharacteristicCBUUID = CBUUID(string: "0x2A72")
    
    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }
    
    func connect(){
        if(device.status == "ready"){
            print("Connecting...")
            myCentral.connect(myPeripheral)
        }
        stopScanning()
    }
    
    func disconnect(){
        if(device.status == "connected"){
            print("Disconnecting...")
            myCentral.cancelPeripheralConnection(myPeripheral)
        }
    }
    
    func startScanning() {
        otherDevices = []
        print("startScanning")
        isScanning = true
        myCentral.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanning() {
        isScanning = false
        print("stopScanning")
        myCentral.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        device.status = "connected"
        print("Connected!")
        myPeripheral.delegate = self
        myPeripheral.discoverServices(nil)
    }

    func sendRoutine(value: Int){
        let data = Data([UInt8(value)])
        if(setRoutineCharacteristic != nil){
            myPeripheral.writeValue(data, for: setRoutineCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            print("Sending")
        } else {
            print("No Characteristic found to send to")
        }
    }
    
    func sendMode(value: Int){
        let data = Data([UInt8(value)])
        self.device.mode = value
        if(setModeCharacteristic != nil){
            myPeripheral.writeValue(data, for: setModeCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            print("Sending")
        } else {
            print("No Characteristic found to send to")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered new Service")
        for service: CBService in peripheral.services! {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            print(characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            if(characteristic.uuid == routineCharacteristicCBUUID){
                setRoutineCharacteristic = characteristic
                self.sendMode(value: 1)
            } else if(characteristic.uuid == modeCharacteristicCBUUID){
                setModeCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
            case batteryLevelCharacteristicCBUUID:
                let batteryLevel = batteryLevel(from: characteristic)
                device.batteryLevel = Int(batteryLevel)
            case modeCharacteristicCBUUID:
                let mode = percentage(from: characteristic)
                device.mode = Int(mode)
            case stateSentMessagesCharacteristicCBUUID:
                let sent_messages = percentage(from: characteristic)
                device.sent_messages = Int(sent_messages)
            case stateDeliveredMessagesCharacteristicCBUUID:
                let delivered_messages = percentage(from: characteristic)
                device.delivered_messages = Int(delivered_messages)
            case stateReceivedMessagesCharacteristicCBUUID:
                let received_messages = percentage(from: characteristic)
                device.received_messages = Int(received_messages)
            case routineCharacteristicCBUUID:
                let blink_routine = percentage(from: characteristic)
                device.blink_routine = Int(blink_routine)
            default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
        myPeripheral.readRSSI()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        device.rssi = RSSI.intValue
    }
    
    private func percentage(from characteristic: CBCharacteristic) -> UInt8 {
        guard let characteristicData = characteristic.value,
        let byte = characteristicData.first else { return 0 }
        return byte
    }
    
    private func batteryLevel(from characteristic: CBCharacteristic) -> UInt8 {
        guard let characteristicData = characteristic.value,
        let byte = characteristicData.first else { return 0 }
        return byte
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        device.status = "disconnected"
        print("Disconnected!")
        device = nil
        if(error != nil){
            print(error as Any)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        print("failed to connect")
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral){
        print("Connection Event accured")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var pName: String!
        var pConnecteable: Bool!
        
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            pName = name
        } else {
            pName = "Undefined"
        }
        if let connecteable = advertisementData[CBAdvertisementDataIsConnectable] as? Bool {
            pConnecteable = connecteable
        } else {
            pConnecteable = false
        }
        
        if(pConnecteable){
            otherDevices.append(Others(id: otherDevices.count, name: pName, rssi: RSSI.intValue))
        }
        
        if(pName == "Lights"){
            myPeripheral = peripheral
            device = Peripheral(
                id: 1,
                name: pName,
                rssi: RSSI.intValue,
                status: pConnecteable ? "ready" : "in use",
                batteryLevel: -1,
                percentage: 0,
                sent_messages: 0,
                delivered_messages: 0,
                received_messages: 0,
                blink_routine: 0,
                mode: -1
            )
        }
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
    }
}
