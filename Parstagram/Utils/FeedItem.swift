//
//  FeedItem.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/28/22.
//

import Foundation

enum FeedItem: Hashable {
    case post(Post)
    case comment(Comment)
    case addComment(IdentifiablePFObject.ID)
}
