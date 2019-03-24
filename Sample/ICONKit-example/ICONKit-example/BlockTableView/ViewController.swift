//
//  ViewController.swift
//  ICONKit-example
//
//  Created by a1ahn on 01/11/2018.
//  Copyright © 2018 ICON Foundation. All rights reserved.
//

import UIKit
import ICONKit
import Result
import BigInt

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    public var blockList = [Response.Block.ConfirmedTransactionList]()
    
    let example = ICONExample()
    
    public var lastHeight: UInt64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Transactions"
        // tableView xib
        let nibName = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "cell")
        
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = 80
        example.getLastBlock { (block) in
            
            self.lastHeight = block.height
            if let list = block.confirmedTransactionList.first {
                self.blockList.append(list)
            }
            
        }
        loadBlocks()
    }
    
    func loadBlocks() {
        for _ in 1...10 {
            example.getBlockByHeight(height: self.lastHeight - 1) { (block) in
                if let list = block.confirmedTransactionList.first {
                    self.blockList.append(list)
                    self.lastHeight = block.height
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blockList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let data = self.blockList[indexPath.row]
        
        cell.statusLabel.text = "success"
        cell.txHashLabel.text = data.txHash
        let amount: String = String(data.value?.hexToBigUInt() ?? 0)
        let fee: String = String(data.stepLimit?.hexToBigUInt() ?? 0)
        cell.amountLabel.text = amount
        cell.feeLabel.text = fee

        cell.statusLabel.sizeToFit()
        cell.txHashLabel.sizeToFit()
        cell.amountLabel.sizeToFit()
        cell.feeLabel.sizeToFit()

        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = self.blockList[indexPath.row]
        
        let storyboard: UIStoryboard = UIStoryboard(name: "BlockInfo", bundle: nil)
        let nextView = storyboard.instantiateInitialViewController()
        let vc = nextView as? BlockInfoViewController
        vc?.blockInfo = result
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
