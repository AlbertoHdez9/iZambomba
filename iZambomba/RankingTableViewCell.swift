//
//  RankingTableViewCell.swift
//  iZambomba
//
//  Created by SingularNet on 22/1/19.
//  Copyright © 2019 SingularNet. All rights reserved.
//

import UIKit

class RankingTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var zambsLabel: UILabel!
    @IBOutlet weak var index: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
