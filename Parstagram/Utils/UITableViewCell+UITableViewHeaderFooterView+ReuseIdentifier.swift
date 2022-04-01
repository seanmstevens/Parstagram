//
//  UITableViewCell+UITableViewHeaderFooterView+ReuseIdentifier.swift
//  Parstagram
//
//  Created by Sean Stevens on 4/1/22.
//

import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewHeaderFooterView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
