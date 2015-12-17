//
//  FeedAnyImagesCell.swift
//  Yep
//
//  Created by nixzhu on 15/9/30.
//  Copyright © 2015年 Catch Inc. All rights reserved.
//

import UIKit

let feedAttachmentImageSize = YepConfig.FeedNormalImagesCell.imageSize
let feedAttachmentBiggerImageSize = YepConfig.FeedBiggerImageCell.imageSize

private let feedMediaCellID = "FeedMediaCell"
private let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width

typealias FeedTapMediaAction = (transitionView: UIView, image: UIImage?, attachments: [DiscoveredAttachment], index: Int) -> Void

class FeedAnyImagesCell: FeedBasicCell {

    lazy var mediaCollectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .Horizontal

        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.scrollsToTop = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15 + 40 + 10, bottom: 0, right: 15)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.registerNib(UINib(nibName: feedMediaCellID, bundle: nil), forCellWithReuseIdentifier: feedMediaCellID)
        collectionView.dataSource = self
        collectionView.delegate = self

        let backgroundView = TouchClosuresView(frame: collectionView.bounds)
        backgroundView.touchesBeganAction = { [weak self] in
            if let strongSelf = self {
                strongSelf.touchesBeganAction?(strongSelf)
            }
        }
        backgroundView.touchesEndedAction = { [weak self] in
            if let strongSelf = self {
                if strongSelf.editing {
                    return
                }
                strongSelf.touchesEndedAction?(strongSelf)
            }
        }
        backgroundView.touchesCancelledAction = { [weak self] in
            if let strongSelf = self {
                strongSelf.touchesCancelledAction?(strongSelf)
            }
        }
        collectionView.backgroundView = backgroundView

        return collectionView
    }()

    var tapMediaAction: FeedTapMediaAction?

    var attachments = [DiscoveredAttachment]() {
        didSet {

            mediaCollectionView.reloadData()
        }
    }

    override class func heightOfFeed(feed: DiscoveredFeed) -> CGFloat {

        let height = super.heightOfFeed(feed) + feedAttachmentImageSize.height + 15

        return ceil(height)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(mediaCollectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        attachments = []
    }

    override func configureWithFeed(feed: DiscoveredFeed, needShowSkill: Bool) {
        super.configureWithFeed(feed, needShowSkill: needShowSkill)

        var hasMedia = false

        if let attachment = feed.attachment, case let .Images(attachments) = attachment {
            hasMedia = !attachments.isEmpty

            mediaCollectionView.hidden = hasMedia ? false : true

            if !mediaCollectionView.hidden {
                let y = messageTextView.frame.origin.y + messageTextView.frame.height + 15
                let height = feedAttachmentImageSize.height
                mediaCollectionView.frame = CGRect(x: 0, y: y, width: screenWidth, height: height)

                self.attachments = attachments
            }

        } else {
            mediaCollectionView.hidden = true
        }
    }
}

extension FeedAnyImagesCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(feedMediaCellID, forIndexPath: indexPath) as! FeedMediaCell
        
        if let attachment = attachments[safe: indexPath.item] {

            //println("attachment imageURL: \(imageURL)")
            
            cell.configureWithAttachment(attachment, bigger: (attachments.count == 1))
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {

        return feedAttachmentImageSize
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FeedMediaCell

        let transitionView = cell.imageView
        tapMediaAction?(transitionView: transitionView, image: cell.imageView.image, attachments: attachments, index: indexPath.item)
    }
}
