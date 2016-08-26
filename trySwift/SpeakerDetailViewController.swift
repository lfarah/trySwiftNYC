//
//  SpeakerDetailViewController.swift
//  trySwift
//
//  Created by Natasha Murashev on 2/12/16.
//  Copyright © 2016 NatashaTheRobot. All rights reserved.
//

import UIKit

class SpeakerDetailViewController: UITableViewController {

	var speaker: Speaker!

	private enum SpeakerDetail: Int {
		case Header, Bio, Twitter, Favorite
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		title = speaker.name
		configureTableView()
	}
}

// MARK: - Table view data source
extension SpeakerDetailViewController {

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch SpeakerDetail(rawValue: indexPath.row)! {
		case .Header:
			let cell = tableView.dequeueReusableCellWithIdentifier(String(SpeakerTableViewCell), forIndexPath: indexPath) as! SpeakerTableViewCell
			cell.configure(withSpeaker: speaker, selectionEnabled: false, accessoryEnabled: false)
			return cell
		case .Bio:
			let cell = tableView.dequeueReusableCellWithIdentifier(String(TextTableViewCell), forIndexPath: indexPath) as! TextTableViewCell
			cell.configure(withText: speaker.bio)
			return cell
		case .Twitter:
			let cell = tableView.dequeueReusableCellWithIdentifier(String(TwitterFollowTableViewCell), forIndexPath: indexPath) as! TwitterFollowTableViewCell
			cell.configure(withUsername: speaker.twitter, delegate: self)
			return cell

		case .Favorite:
			let cell = tableView.dequeueReusableCellWithIdentifier(String(FavoriteTableViewCell), forIndexPath: indexPath) as! FavoriteTableViewCell

			let presentation = defaultPresentations.filter {
				$0.speaker == speaker }
			cell.configure(withPresentation: presentation.first!, delegate: self)
			return cell
		}
	}

}

extension SpeakerDetailViewController {

	func configureTableView() {
		tableView.registerNib(UINib(nibName: String(SpeakerTableViewCell), bundle: nil), forCellReuseIdentifier: String(SpeakerTableViewCell))
		tableView.registerNib(UINib(nibName: String(TextTableViewCell), bundle: nil), forCellReuseIdentifier: String(TextTableViewCell))
		tableView.registerNib(UINib(nibName: String(TwitterFollowTableViewCell), bundle: nil), forCellReuseIdentifier: String(TwitterFollowTableViewCell))
		tableView.registerNib(UINib(nibName: String(FavoriteTableViewCell), bundle: nil), forCellReuseIdentifier: String(FavoriteTableViewCell))

		tableView.estimatedRowHeight = 100
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.separatorStyle = .None
	}
}
