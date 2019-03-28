//
//  BlockInfoViewController.swift
//  ICONKit-example
//
//  Created by Seungyeon Lee on 22/02/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import UIKit
//import ICONKit

class BlockInfoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    public var blockInfo: Response.Block.ConfirmedTransactionList?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // tableView xib
        let nibName = UINib(nibName: "BlockInfoTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "infoCell")
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
        return 8
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "txHash"
        case 1:
            return "status"
        case 2:
            return "timeStamp"
        case 3:
            return "from"
        case 4:
            return "to"
        case 5:
            return "value"
        case 6:
            return "stepLimit"
        case 7:
            return "signature"
        default:
            return "unknown"
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! BlockInfoTableViewCell
        
        if let info = blockInfo {
            switch indexPath.section {
            case 0:
                
                cell.contentLabel.text = info.txHash
            case 1:
                cell.contentLabel.text = "success"
            case 2:
                let ts: NSString = info.timestamp as NSString
                if let date = ts.hexToDate() {
                    cell.contentLabel.text = dateformatter.string(from: date)
                } else {
                    cell.contentLabel.text = "err"
                }
            case 3:
                cell.contentLabel.text = info.from
            case 4:
                cell.contentLabel.text = info.to
            case 5:
                let value: String = String(info.value?.hexToBigUInt() ?? 0)
                cell.contentLabel.text = value
            case 6:
                let fee: String = String(info.stepLimit?.hexToBigUInt() ?? 0)
                cell.contentLabel.text = fee
            case 7:
                cell.contentLabel.text = info.signature
            default:
                cell.contentLabel.text = "unknown"
            }
            cell.contentLabel.sizeToFit()
        }
        
        return cell
    }
}

extension BlockInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
