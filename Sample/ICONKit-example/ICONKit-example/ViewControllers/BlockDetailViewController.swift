//
//  BlockDetailViewController.swift
//  ICONKit-example
//
//  Created by Seungyeon Lee on 27/05/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import UIKit
import ICONKit

class BlockDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var blockInfo: Response.Block?
    
    let blockTitles = ["BlockHash", "Height", "Date", "Peer ID", "Signature"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view..
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nibName = UINib(nibName: "BlockDetailTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "cell2")
    }
}

extension BlockDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Block Detail"
        default:
            return "Transactions \(self.blockInfo?.confirmedTransactionList.count ?? 0)"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        default:
            return blockInfo?.confirmedTransactionList.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
            
            cell.isUserInteractionEnabled = false
            cell.textLabel?.text = blockTitles[indexPath.row]
            
            guard let blockInfo = blockInfo else {
                return cell
            }
            
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = blockInfo.blockHash
            case 1:
                cell.detailTextLabel?.text = "\(blockInfo.height)"
            case 2:
                cell.detailTextLabel?.text = "\(Date(timeIntervalSince1970: blockInfo.timeStamp/1000000.0))"
            case 3:
                cell.detailTextLabel?.text = blockInfo.peerId
            default:
                cell.detailTextLabel?.text = blockInfo.signature
                
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2") as! BlockDetailTableViewCell
            if let transaction = blockInfo?.confirmedTransactionList[indexPath.row] {
                cell.txHashLabel?.text = transaction.txHash
                cell.dateLabel?.text = "\(transaction.timestamp.hexToDate()!)"
                cell.valueLabel?.text = "\(transaction.value?.hexToBigUInt()?.convertToICX() ?? "0")" + "ICX"
            }
            return cell
            
        }
    }
    
    // transactions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let transaction = self.blockInfo?.confirmedTransactionList[indexPath.row]
        
        let storyboard: UIStoryboard = UIStoryboard(name: "BlockInfo", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "BlockInfo")
        let vc = nextView as! BlockInfoViewController
        vc.blockInfo = transaction
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 1 ? CGFloat(80) : CGFloat(44)
    }
}
