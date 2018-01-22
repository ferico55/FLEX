//
//  MaintenanceViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/18/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

class MaintenanceViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var additionalLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setupView() {
        self.view.accessibilityLabel = "maintenanceView"

        self.titleLabel.font = UI_USER_INTERFACE_IDIOM() == .pad ? .semiboldSystemFont(ofSize: 19) : .title1ThemeSemibold()
        self.subtitleLabel.font = UI_USER_INTERFACE_IDIOM() == .pad ? .systemFont(ofSize: 16) : .largeTheme()
        self.additionalLabel.font = UI_USER_INTERFACE_IDIOM() == .pad ? .systemFont(ofSize: 16) : .largeTheme()
    }
}
