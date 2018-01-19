//
//  NoAccountViewController.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 05/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

class NoAccountViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupView()
    }
    
    private func setupView() {
        self.title = "Tidak Ada Akun Terhubung"
    }
    
    @IBAction func loginWithOtherMethod() {
        self.navigationController?.popToRootViewController(animated: true)
    }

}
