//
//  UISearchBar+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import UIKit

extension UISearchBar {
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            // Fallback on earlier versions
            for view: UIView in subviews[0].subviews {
                if let textField = view as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}
