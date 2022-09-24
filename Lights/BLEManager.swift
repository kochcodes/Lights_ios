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
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isSwitchedOn = false
    @Published var isScanning = false
    var myCentral: CBCentralManager!
    var myPeripheral: CBPeripheral!
    @Published var device: Peripheral!
    
    var setValueCharacteristic: CBCharacteristic?
    
    let batteryServiceCBUUID = CBUUID(string: "0x180F")
    let batteryLevelCharacteristicCBUUID = CBUUID(string: "2A19")
    
    let percentageServiceCBUUID = CBUUID(string: "0x27AD")
    let percentageCharacteristicCBUUID = CBUUID(string: "0x2A6E")

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
    }
    
    func disconnect(){
        if(device.status == "connected"){
            print("Disconnecting...")
            myCentral.cancelPeripheralConnection(myPeripheral)
        }
    }
    
    func startScanning() {
        print("startScanning")
        isScanning = true
        myCentral.scanForPeripherals(withServices: [batteryServiceCBUUID], options: nil)
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

    func sendPercentage(value: Int){
        let data = Data([UInt8(value)])
        if(setValueCharacteristic != nil){
            myPeripheral.writeValue(data, for: setValueCharacteristic!, type: CBCharacteristicWriteType.withResponse)
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
            if(characteristic.uuid == percentageCharacteristicCBUUID){
                setValueCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
            case batteryLevelCharacteristicCBUUID:
                let batteryLevel = batteryLevel(from: characteristic)
                device.batteryLevel = Int(batteryLevel)
            case percentageCharacteristicCBUUID:
                let percentage = percentage(from: characteristic)
                device.percentage = Int(percentage)
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

        if(pName == "Lights"){
            myPeripheral = peripheral
            device = Peripheral(
                id: 1,
                name: pName,
                rssi: RSSI.intValue,
                status: pConnecteable ? "ready" : "in use",
                batteryLevel: -1,
                percentage: 0
            )
            stopScanning()
            connect()
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
