//
//  Post.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/25/22.
//

import Parse

class Post: IdentifiablePFObject {
    @NSManaged var caption: String?
    @NSManaged var media: PFFileObject?
    @NSManaged var author: PFUser?
    @NSManaged var comments: [Comment]?
}

extension Post: PFSubclassing {
    class func parseClassName() -> String {
        return "Post"
    }
}
