//
//  TwitterFollowTableViewCell.swift
//  trySwift
//
//  Created by Natasha Murashev on 2/12/16.
//  Copyright © 2016 NatashaTheRobot. All rights reserved.
//

import UIKit

protocol FavoriteDelegate: class {
    func favoritePresentation(presentation: Presentation)
}

class FavoriteTableViewCell: UITableViewCell {

	@IBOutlet weak var favoriteButton: UIButton!

	private var presentation: Presentation?
	private weak var delegate: FavoriteDelegate?

	override func awakeFromNib() {
		super.awakeFromNib()

		favoriteButton.layer.borderWidth = 1.0
		favoriteButton.layer.borderColor = UIColor.trySwiftMainColor().CGColor
		favoriteButton.tintColor = .trySwiftMainColor()
		favoriteButton.layer.cornerRadius = 3.0
	}

	func configure(withPresentation presentation: Presentation, delegate: FavoriteDelegate) {
		self.presentation = presentation
		self.delegate = delegate

		favoriteButton.setTitle("Favorite", forState: .Normal)

		setNeedsUpdateConstraints()
		layoutIfNeeded()
	}

	@IBAction func onFavoriteButtonTap(sender: AnyObject) {
		if let presentation = presentation {
			delegate?.favoritePresentation(presentation)
		}
	}
}
