//
//  PostSectionHeaderView.swift
//  Parstagram
//
//  Created by Sean Stevens on 4/1/22.
//

import UIKit

class PostSectionHeaderView: UITableViewHeaderFooterView {
    let usernameLabel = UILabel()
    let dateTimeString = UILabel()
    
    var post: Post! {
        didSet {
            usernameLabel.text = post.author?.username
            dateTimeString.text = post.getRelativeDateTimeString()
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureHeaderView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHeaderView() {
        let horizontalStackView = UIStackView(arrangedSubviews: [usernameLabel, dateTimeString])
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.spacing = 8
        horizontalStackView.distribution = .fill
        
        usernameLabel.text = "Test"
        dateTimeString.text = "One month ago"
        
        contentView.addSubview(horizontalStackView)
        NSLayoutConstraint.activate([
            
        ])
    }
}
