//
//  PostCell.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/25/22.
//

import UIKit
import AlamofireImage

class PostCell: UICollectionViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    static let reuseIdentifier = "PostCell"
    var post: Post! {
        didSet {
            usernameLabel.text = post.author?.username
            commentLabel.text = post.caption
            
            let url = URL(string: (post.media?.url)!)
            postImageView.af.setImage(withURL: url!, placeholderImage: UIImage(named: "image_placeholder"), imageTransition: .crossDissolve(0.2))
        }
    }

}
