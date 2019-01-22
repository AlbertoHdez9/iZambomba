//
//  StatsTableViewCell.swift
//  iZambomba
//
//  Created by SingularNet on 22/1/19.
//  Copyright © 2019 SingularNet. All rights reserved.
//

import UIKit

class StatsTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
