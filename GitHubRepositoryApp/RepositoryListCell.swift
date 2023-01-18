//
//  RepositoryListCell.swift
//  GitHubRepositoryApp
//
//  Created by wons on 2023/01/18.
//

import UIKit

class RepositoryListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    var repository: Repository?
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let starImageView = UIImageView()
    let starLabel = UILabel()
    let languageLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [
         nameLabel,
         descriptionLabel,
         starImageView,
         starLabel,
         languageLabel
        ].forEach {
            contentView.addSubview($0)
        }
    }
    
}
