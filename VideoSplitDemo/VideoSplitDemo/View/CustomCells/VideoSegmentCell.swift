//
//  VideoSegmentCell.swift
//  VideoSplitDemo
//
//  Created by aakarshit on 19/09/23.
//

import UIKit

class VideoSegmentCell: UITableViewCell {

    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var urlLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var item: VideoSegment? {
        didSet {
            guard let segment = item?.segment, let url = item?.url?.absoluteString else {return}
            durationLbl.text = "\(segment + 1)"
            urlLbl.setTrailingEllipsisText(url, maxLength: 20)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
