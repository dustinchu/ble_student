import CoreBluetooth

final class PeripheralDelegate: NSObject, CBPeripheralDelegate {

    typealias ServicesDiscoveryHandler = (CBPeripheral, Error?) -> Void
    typealias CharacteristicsDiscoverHandler = (CBService, Error?) -> Void
    typealias CharacteristicNotificationStateUpdateHandler = (CBCharacteristic, Error?) -> Void
    typealias CharacteristicValueUpdateHandler = (CBCharacteristic, Error?) -> Void
    typealias CharacteristicValueWriteHandler = (CBCharacteristic, Error?) -> Void
    typealias ReadRssiHandler = (CBPeripheral, Int, Error?) -> Void

    private let onServicesDiscovery: ServicesDiscoveryHandler
    private let onCharacteristicsDiscovery: CharacteristicsDiscoverHandler
    private let onCharacteristicNotificationStateUpdate: CharacteristicNotificationStateUpdateHandler
    private let onCharacteristicValueUpdate: CharacteristicValueUpdateHandler
    private let onCharacteristicValueWrite: CharacteristicValueWriteHandler
    private let onReadRssi: ReadRssiHandler

    init(
        onServicesDiscovery: @escaping ServicesDiscoveryHandler,
        onCharacteristicsDiscovery: @escaping CharacteristicsDiscoverHandler,
        onCharacteristicNotificationStateUpdate: @escaping CharacteristicNotificationStateUpdateHandler,
        onCharacteristicValueUpdate: @escaping CharacteristicValueUpdateHandler,
        onCharacteristicValueWrite: @escaping CharacteristicValueWriteHandler,
        onReadRssi: @escaping ReadRssiHandler
    ) {
        self.onServicesDiscovery = onServicesDiscovery
        self.onCharacteristicsDiscovery = onCharacteristicsDiscovery
        self.onCharacteristicNotificationStateUpdate = onCharacteristicNotificationStateUpdate
        self.onCharacteristicValueUpdate = onCharacteristicValueUpdate
        self.onCharacteristicValueWrite = onCharacteristicValueWrite
        self.onReadRssi = onReadRssi
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        onServicesDiscovery(peripheral, error)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        onCharacteristicsDiscovery(service, error)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        onCharacteristicNotificationStateUpdate(characteristic, error)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        onCharacteristicValueUpdate(characteristic, error)
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        onCharacteristicValueWrite(characteristic, error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        onReadRssi(peripheral, RSSI.intValue, error)
    }
}
