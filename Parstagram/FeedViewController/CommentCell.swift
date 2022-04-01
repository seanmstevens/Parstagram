//
//  CommentCell.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/27/22.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var comment: Comment! {
        didSet {
            usernameLabel.text = comment.author?.username
            commentLabel.text = comment.text
        }
    }
}
