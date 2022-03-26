//
//  Post.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/25/22.
//

import Parse

class Post: PFObject, Identifiable {
    var id = UUID()

    @NSManaged var caption: String?
    @NSManaged var media: PFFileObject?
    @NSManaged var author: PFUser?
}

extension Post: PFSubclassing {
    class func parseClassName() -> String {
        return "Post"
    }
}
