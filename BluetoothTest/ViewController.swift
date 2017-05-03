//
//  ViewController.swift
//  BluetoothTest
//
//  Created by Frank.Chen on 2017/5/2.
//  Copyright © 2017年 Frank.Chen. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var myCenteralManager: CBCentralManager?
    var BTPeripheral:[CBPeripheral] = [] // 儲存掃瞄到的 peripheral 物件
    var BTIsConnectable: [Int] = [] // 儲存各個藍芽裝置是否可連線
    var BTRSSI:[NSNumber] = [] // 儲存各個藍芽裝置的訊號強度
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 啟動掃描後當偵測到藍芽裝置就會進入進入didDiscoverPeripheral 的 callBack
        self.myCenteralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Callback
    // ---------------------------------------------------------------------
    // 搜尋藍芽裝置
    @IBAction func scanDevice(_ sender: Any) {
        // scan 週邊設備
        self.myCenteralManager!.scanForPeripherals(withServices: nil, options: nil)
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
    
    // CBCentralManagerDelegate scan 藍芽設備後的 callback func
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // 濾掉設備名稱一樣的(BTPeripheral 儲存掃瞄到的 peripheral 物件)
        let temp = BTPeripheral.filter { (pl) -> Bool in
            return pl.name == peripheral.name
        }
        
        // 將新的設備儲存到陣列裡
        if temp.count == 0 {
            BTPeripheral.append(peripheral)
            BTRSSI.append(RSSI)
            BTIsConnectable.append(Int((advertisementData[CBAdvertisementDataIsConnectable]! as AnyObject).description)!)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - DataSource
    // ---------------------------------------------------------------------
    // 設定表格section的列數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.BTPeripheral.count
    }
    
    // 表格的儲存格設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BLEUITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BLEUITableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.nameLabel.text = BTPeripheral[indexPath.row].name ?? "NoName" // 藍芽名稱
        cell.RSSILabel.text = "\(BTRSSI[indexPath.row])" // RSSI
        
        let distancePower =  Double(abs(BTRSSI[indexPath.row].intValue) - 70) / Double(10 * 1) // 距離
        cell.distLabel.text = "\(pow(10.0,distancePower)) M"
        
        cell.idLabel.text = BTPeripheral[indexPath.row].identifier.uuidString // uuid
        
        cell.conectableLabel.text = "\(BTIsConnectable[indexPath.row].description == "0" ? "否" : "是")" // 是否可連線
        
        return cell
    }
    
    // MARK: - Callback
    // ---------------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if segue.identifier == "sgToBTDeviceConfig" {
            let targetVC = segue.destination as! BTDeviceConfigViewController
            targetVC.peripheral = self.BTPeripheral[(tableView.indexPathForSelectedRow?.row)!]
            targetVC.btDeviceName = self.BTPeripheral[(tableView.indexPathForSelectedRow?.row)!].name
            targetVC.centralManager = self.myCenteralManager
        }
    }    
}

