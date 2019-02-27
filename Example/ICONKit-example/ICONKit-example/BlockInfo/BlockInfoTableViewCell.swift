//
//  BlockInfoTableViewCell.swift
//  ICONKit-example
//
//  Created by Seungyeon Lee on 22/02/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import UIKit

class BlockInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
