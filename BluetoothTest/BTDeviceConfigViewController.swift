//
//  BTDeviceConfigViewController.swift
//  BluetoothTest
//
//  Created by Frank.Chen on 2017/5/2.
//  Copyright © 2017年 Frank.Chen. All rights reserved.
//

import UIKit
import CoreBluetooth

// CBCentralManagerDelegate scan 的 delegate
// CBPeripheralDelegate 連線完成 delegate
class BTDeviceConfigViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var peripheral: CBPeripheral!
    var centralManager: CBCentralManager!
    var btDeviceName: String!
    @IBOutlet weak var titleBar: UINavigationBar!
    var btServices: [BTServiceInfo] = [BTServiceInfo]()
    
    @IBOutlet weak var isConnectLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleBar.topItem?.title = self.btDeviceName
        
        self.peripheral.delegate = self
        self.centralManager.delegate = self
        self.centralManager.connect(peripheral, options: nil) // device 連線，nil 表示都可以搜尋的到，當執行connectPeripheral，我們就會拿到這個 peripheral 所提供的 service (CBService) 和所屬該 service 的特徵值(CBCharacteristic)
        
        self.btServices = [] // 清空放置搜尋到的容器
    }
    
    // MARK: - Callback
    // ---------------------------------------------------------------------
    // 更新
    @IBAction func goUpdate(_ sender: Any) {
        // 更新...
    }
    
    // 返回
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - DataSource
    // ---------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.btServices.count
    }    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(self.btServices[section].service.uuid)"
    }
    
    // 設定表格section的列數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.btServices[section].characteristics.count
    }
    
    // 表格的儲存格設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BTServiceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BTServiceTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.descLabel.text = btServices[indexPath.section].characteristics[indexPath.row].uuid.description
        
        cell.propLabel.text = String(format: "0x%02X", self.btServices[indexPath.section].characteristics[indexPath.row].properties.rawValue)
        
        cell.valueLabel.text = self.btServices[indexPath.section].characteristics[indexPath.row].value?.description ?? "null"
        
        cell.notificationLabel.text = self.btServices[indexPath.section].characteristics[indexPath.row].isNotifying.description
        
        cell.uuidLabel.text = self.btServices[indexPath.section].characteristics[indexPath.row].uuid.uuidString
        
        // 查看有哪些權限，例如 Read / Wirte / Notify
        cell.propertyLabel.text = self.btServices[indexPath.section].characteristics[indexPath.row].getPropertyContent()
        print("propertyLabel： \(cell.propertyLabel.text!)")
        
        return cell
    }
    
    // MARK: - Delegate
    // ---------------------------------------------------------------------
    // 監聽 iOS 裝置的藍芽狀態
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case CBManagerState.poweredOn:
            print("BT ON")
        case CBManagerState.poweredOff:
            print("BT OFF")
        case CBManagerState.unknown:
            print("BT UNKNOWN")
        case CBManagerState.unsupported:
            print("BT UNSUPPORTED")
        case CBManagerState.unauthorized:
            print("BT UNAUTHORIZED")
        default:
            print("....")
        }
    }
    
    // centralManager 已連線 delegate
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.state == CBPeripheralState.connected {
            self.isConnectLabel.text = "Connected"
            peripheral.discoverServices(nil)
        }
    }
    
    // CBPeripheralDelegate 發現 service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for serviceObj in peripheral.services! {
            // btServices 裡面放的就是 BTServiceInfo 物件，所以在掃描到新的 service 的時候先判斷是否已經在容器裡，如果沒有就加入
            let service: CBService = serviceObj
            
            let isServiceIncluded = self.btServices.filter({ (item: BTServiceInfo) -> Bool in
                return item.service.uuid == service.uuid
            }).count
            
            if isServiceIncluded == 0 {
                btServices.append(BTServiceInfo(service: service, characteristics: []))
            }
            
            // 查詢 service 裡所有的 characteristic，觸發 didDiscoverCharacteristicsFor
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // CBPeripheralDelegate 發現 characteristic
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // 多個 characteristics
        let serviceCharacteristics = service.characteristics
        for item in self.btServices {
            if item.service.uuid == service.uuid {
                item.characteristics = serviceCharacteristics!
                break
            }
        }
        
        // 顯示所有的 service Characteristic 在畫面上
        self.tableView.reloadData()
    }
}

// 一個 service 可能會有多個 characteristic，故用類別再包 CBCharacteristic 陣列
class BTServiceInfo {
    var service: CBService!
    var characteristics: [CBCharacteristic]
    init(service: CBService, characteristics: [CBCharacteristic]) {
        self.service = service
        self.characteristics = characteristics
    }
}

extension CBCharacteristic {
    
    func isWritable() -> Bool {
        return (self.properties.intersection(CBCharacteristicProperties.write)) != []
    }
    
    func isReadable() -> Bool {
        return (self.properties.intersection(CBCharacteristicProperties.read)) != []
    }
    
    func isWritableWithoutResponse() -> Bool {
        return (self.properties.intersection(CBCharacteristicProperties.writeWithoutResponse)) != []
    }
    
    func isNotifable() -> Bool {
        return (self.properties.intersection(CBCharacteristicProperties.notify)) != []
    }
    
    func isIdicatable() -> Bool {
        return (self.properties.intersection(CBCharacteristicProperties.indicate)) != []
    }
    
    func isBroadcastable() -> Bool {
        return (self.properties.intersection(CBCharacteristicProperties.broadcast)) != []
    }
    
    func isExtendedProperties() -> Bool {
        return (self.properties.intersection(CBCharacteristicProperties.extendedProperties)) != []
    }
    
    func isAuthenticatedSignedWrites() -> Bool {
        return (self.properties.intersection(CBCharacteristicProperties.authenticatedSignedWrites)) != []
    }
    
    func isNotifyEncryptionRequired() -> Bool {
        return (self.properties.intersection(CBCharacteristicProperties.notifyEncryptionRequired)) != []
    }
    
    func isIndicateEncryptionRequired() -> Bool {
        return (self.properties.intersection(CBCharacteristicProperties.indicateEncryptionRequired)) != []
    }
    
    // 查看有哪些權限，例如 Read / Wirte / Notify
    // Characteristic 的 property 是以二進位去做區隔，例如可以 Read 就是在 Read 那個位元的位置是 1，假設 Read 在第一位元，Write 在第二位元，那 Read only 就可以表示成 10、Write only 就表示成 01、Read / Write 就可以表示成 11
    func getPropertyContent() -> String {
        var propContent = ""
        if (self.properties.intersection(CBCharacteristicProperties.broadcast)) != [] {
            propContent += "Broadcast,"
        }
        if (self.properties.intersection(CBCharacteristicProperties.read)) != [] {
            propContent += "Read,"
        }
        if (self.properties.intersection(CBCharacteristicProperties.writeWithoutResponse)) != [] {
            propContent += "WriteWithoutResponse,"
        }
        if (self.properties.intersection(CBCharacteristicProperties.write)) != [] {
            propContent += "Write,"
        }
        if (self.properties.intersection(CBCharacteristicProperties.notify)) != [] {
            propContent += "Notify,"
        }
        if (self.properties.intersection(CBCharacteristicProperties.indicate)) != [] {
            propContent += "Indicate,"
        }
        if (self.properties.intersection(CBCharacteristicProperties.authenticatedSignedWrites)) != [] {
            propContent += "AuthenticatedSignedWrites,"
        }
        if (self.properties.intersection(CBCharacteristicProperties.extendedProperties)) != [] {
            propContent += "ExtendedProperties,"
        }
        if (self.properties.intersection(CBCharacteristicProperties.notifyEncryptionRequired)) != [] {
            propContent += "NotifyEncryptionRequired,"
        }
        if (self.properties.intersection(CBCharacteristicProperties.indicateEncryptionRequired)) != [] {
            propContent += "IndicateEncryptionRequired,"
        }
        return propContent
    }
}
