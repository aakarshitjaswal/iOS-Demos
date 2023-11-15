//
//  String+Ex.swift
//  VideoSplitDemo
//
//  Created by aakarshit on 20/09/23.
//

import Foundation
import UIKit

extension UILabel {
    //Sets the ellipsis for text in the beginning for text in UILabel, helpful in getting the segment number displayed which is at the end of the video path being presented in the tableView cells
    func setTrailingEllipsisText(_ text: String?, maxLength: Int) {
        guard let text = text else {
            self.text = nil
            return
        }
        
        if text.count <= maxLength {
            self.text = text
        } else {
            let startIndex = text.index(text.endIndex, offsetBy: -maxLength)
            let truncatedText = "..." + text[startIndex...]
            self.text = String(truncatedText)
        }
    }
}
