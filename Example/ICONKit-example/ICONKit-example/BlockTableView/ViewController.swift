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
    public static var blockList = [Response.Block.ResultInfo.ConfirmedTransactionList]()
    
    let example = ICONExample()
    
    public static var lastHeight: UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Transactions"
        // tableView xib
        let nibName = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "cell")
        
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = 80
        example.getLastBlock()
        
        loadBlocks()

    }
    
    func loadBlocks() {
        for _ in 1...10 {
            example.getBlockByHeight(height: UInt64(ViewController.lastHeight - 1))
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.blockList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let data = ViewController.blockList[indexPath.row]
        
        cell.statusLabel.text = "success"
        cell.txHashLabel.text = data.txHash
        cell.amountLabel.text = data.value
        cell.feeLabel.text = data.stepLimit

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
        let result = ViewController.blockList[indexPath.row]
        
        let storyboard: UIStoryboard = UIStoryboard(name: "BlockInfo", bundle: nil)
        let nextView = storyboard.instantiateInitialViewController()
        let vc = nextView as? BlockInfoViewController
        vc?.blockInfo = result
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

extension ViewController {
    func calculateAge(timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000000.0)
        let now = Date()
        do {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
            formatter.unitsStyle = .short
            formatter.maximumUnitCount = 1
            if let daysString = formatter.string(from: date, to: now) {
                return daysString + " ago"
            }
            return "unknown"
            
        }
    }
}
