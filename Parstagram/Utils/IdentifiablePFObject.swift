//
//  IdentifiablePFObject.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/27/22.
//

import Parse

class IdentifiablePFObject: PFObject, Identifiable {
    var id = UUID()
}
