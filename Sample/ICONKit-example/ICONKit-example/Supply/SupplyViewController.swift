//
//  SupplyViewController.swift
//  ICONKit-example
//
//  Created by Seungyeon Lee on 27/02/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import UIKit
import BigInt

class SupplyViewController: UIViewController {

    @IBOutlet weak var supplyLabel: UILabel!
    
    let example = ICONExample()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 26/255, green: 170/255, blue: 186/255, alpha: 1.0)
        
        // Request asynchronously
        self.example.asyncSupply ({ (supply) in
            DispatchQueue.main.async {
                self.supplyLabel.text = "\(supply / BigUInt(1000000000000000000))"
            }
        })
        supplyLabel.sizeToFit()

        // Do any additional setup after loading the view.
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
