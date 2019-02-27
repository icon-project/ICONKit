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
    
    public var blockInfo: Response.Block.ResultInfo.ConfirmedTransactionList?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // tableView xib
        let nibName = UINib(nibName: "BlockInfoTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "infoCell")
    }
    

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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! BlockInfoTableViewCell
        
        if let list = blockInfo {
            cell.titleLabel.text = "signature"
            cell.contentLabel.text = list.signature
            cell.titleLabel.sizeToFit()
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
