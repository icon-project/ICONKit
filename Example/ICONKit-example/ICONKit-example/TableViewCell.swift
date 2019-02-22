//
//  TableViewCell.swift
//  ICONKit-example
//
//  Created by Seungyeon Lee on 21/02/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var blockHashLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
