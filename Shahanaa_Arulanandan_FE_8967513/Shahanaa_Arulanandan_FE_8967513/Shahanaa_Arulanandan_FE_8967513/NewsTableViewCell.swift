//
//  NewsTableViewCell.swift
//  Shahanaa_Arulanandan_FE_8967513
//
//  Created by user239837 on 4/10/24.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
//connecting the labels and text view from the cell
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
