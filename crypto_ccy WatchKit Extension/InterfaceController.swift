//
//  InterfaceController.swift
//  crypto_ccy WatchKit Extension
//
//  Created by Nikita Vtorushin on 27.11.2021.
//

import WatchKit
import Foundation
import Alamofire

struct ccy {
    var name: String
    var course: String = "-"
}

var tableData = [
    ccy(name: "BLOK"),
    ccy(name: "BTC"),
    ccy(name: "ETH"),
    ccy(name: "DOGE"),
    ccy(name: "DOT"),
    ccy(name: "ATOM")
]

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

class InterfaceController: WKInterfaceController {
    @IBOutlet var tableView: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        DispatchQueue.main.async {
            self.loadData()
        }
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    
    private func loadData() {
        if (tableView != nil) {
            tableView.setNumberOfRows(tableData.count, withRowType: "rowController")
            for (index, ccy) in tableData.enumerated() {
                if let row = tableView.rowController(at: index) as? rowController {
                    DispatchQueue.main.async {
                        
                        AF.request("https://www.okex.com/priapi/v5/public/mark-price?instId="+ccy.name+"-USDT"
                        ).responseJSON { responseJSON in
                            switch responseJSON.result {
                            case .success(let value):
                                guard let jsonArray = value as? [String: Any] else { return }
                                if (jsonArray["code"] as! String == "0") {
                                    let data = jsonArray["data"] as! [AnyObject]
                                    let _data = data[0]
                                    let result = _data.value(forKey: "markPx") as! String
                                    let couse = String(format: "%.4f", (result as NSString).doubleValue)
                                    row.cource.setText(couse + " $")
                                    row.ccyName.setText(ccy.name + " - ")
                                } else {
                                    row.cource.setText("NOT FOUND")
                                    row.ccyName.setText(ccy.name + " - ")
                                }
                            case .failure(_):
                                row.cource.setText("NOT FOUND")
                                row.ccyName.setText(ccy.name + " - ")
                            }
                        }
                        
                    }
                }
            }
        }
    }
}
