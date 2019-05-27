//
//  BlockDetailTableViewCell.swift
//  ICONKit-example
//
//  Created by Seungyeon Lee on 27/05/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import UIKit

class BlockDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var txHashLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
