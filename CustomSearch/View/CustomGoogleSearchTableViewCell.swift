//
//  CustomGoogleSearchTableViewCell.swift
//  CustomSearch
//
//  Created by Brotecs Mac Mini on 12/19/21.
//

import UIKit

class CustomGoogleSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var snippetLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
