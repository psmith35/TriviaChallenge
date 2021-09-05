//
//  UILabel+Customize.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/29/21.
//

import Foundation
import UIKit

extension UILabel {
    func underline() {
        guard let text = self.text else { return }
        let textRange = NSRange(location: 0, length: text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: textRange)
        // Add other attributes if needed
        self.attributedText = attributedText
    }
}
