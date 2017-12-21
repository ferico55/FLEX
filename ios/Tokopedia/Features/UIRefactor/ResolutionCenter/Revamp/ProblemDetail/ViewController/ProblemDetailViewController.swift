//
//  ProblemDetailViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProblemDetailViewController: UIViewController {
    var problemItem: RCProblemItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.problemItem.problem.name
        AnalyticsManager.trackScreenName("Resolution Center Create Detail Problem Page")
    }
}
