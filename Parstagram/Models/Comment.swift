//
//  Comment.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/27/22.
//

import Parse

class Comment: IdentifiablePFObject {
    @NSManaged var text: String?
    @NSManaged var author: PFUser?
    @NSManaged var post: Post?
}

extension Comment: PFSubclassing {
    class func parseClassName() -> String {
        return "Comment"
    }
}
