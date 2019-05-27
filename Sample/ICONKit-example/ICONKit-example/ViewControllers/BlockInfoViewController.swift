//
//  BlockInfoViewController.swift
//  ICONKit-example
//
//  Created by Seungyeon Lee on 22/02/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import UIKit
import ICONKit

class BlockInfoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    public var blockInfo: Response.Block.ConfirmedTransactionList?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // tableView xib
//        let nibName = UINib(nibName: "BlockInfoTableViewCell", bundle: nil)
//        tableView.register(nibName, forCellReuseIdentifier: "infoCell")
        
        self.tableView.isUserInteractionEnabled = false
    }
    
    var dateformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:SSS"
        formatter.timeZone = TimeZone(identifier: "ko")
        return formatter
    }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BlockInfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "txHash"
        case 1:
            return "timeStamp"
        case 2:
            return "from"
        case 3:
            return "to"
        case 4:
            return "value"
        case 5:
            return "stepLimit"
        case 6:
            return "signature"
        default:
            return "unknown"
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! UITableViewCell
        
        if let info = blockInfo {
            switch indexPath.section {
            case 0:
                
                cell.textLabel?.text = info.txHash
            case 1:
                if let date = info.timestamp.hexToDate() {
                    cell.textLabel?.text = dateformatter.string(from: date)
                } else {
                    cell.textLabel?.text = "err"
                }
            case 2:
                cell.textLabel?.text = info.from
            case 3:
                cell.textLabel?.text = info.to
            case 4:
                let value: String = String(info.value?.hexToBigUInt()?.convertToICX() ?? 0) + " ICX"
                cell.textLabel?.text = value
            case 5:
                let fee: String = String(info.stepLimit?.hexToBigUInt() ?? 0)
                cell.textLabel?.text = fee
            case 6:
                cell.textLabel?.text = info.signature
            default:
                cell.textLabel?.text = "unknown"
            }
        }
        
        return cell
    }
}
