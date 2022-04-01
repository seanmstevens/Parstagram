//
//  PFObject+RelativeDateTime.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/27/22.
//

import Parse

extension PFObject {
    func getRelativeDateTimeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: createdAt ?? Date(), relativeTo: Date())
    }
}
