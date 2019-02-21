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
    public static var blockList = [Response.Block]()
    
    let example = ICONExample()
    
    public static var lastHeight: UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // tableView xib
        let nibName = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "cell")
        
        example.getLastBlock()
        loadBlocks()
        
        // Reload
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadBlocks() {
        for _ in 1...15 {
            example.getBlockByHeight(height: UInt64(ViewController.lastHeight - 1))
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.blockList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let data = ViewController.blockList[indexPath.row].result
        
        cell.heightLabel.text = "\(data.height)"
        cell.blockHashLabel.text = data.blockHash
        
        let date = calculateAge(timestamp: data.timeStamp)
        cell.timestampLabel.text = date + " ago"
        
        cell.heightLabel.sizeToFit()
        cell.blockHashLabel.sizeToFit()
        cell.timestampLabel.sizeToFit()
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let result = ViewController.blockList[indexPath.row]
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
            let daysString = formatter.string(from: date, to: now)
            return daysString!
        }
    }
}
