//
//  PulsaViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation

class PulsaViewController: UIViewController {
    var _networkManager : TokopediaNetworkManager!
    var _viewsCollection = [PulsaCategoryView]()

    @IBOutlet weak var pulsaCategoryControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _networkManager = TokopediaNetworkManager()
        self.pulsaCategoryControl.hidden = true
        self.pulsaCategoryControl .addTarget(self, action: #selector(didSelectSegmentControl), forControlEvents: .ValueChanged)
        
        _networkManager .
            requestWithBaseUrl("http://private-c3816-digitalcategory.apiary-mock.com",
                               path: "/categories",
                               method: .GET,
                               parameter: nil,
                               mapping: PulsaCategoryRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let category = mappingResult.dictionary()[""] as! PulsaCategoryRoot
                                self .didReceiveCategory(category)
                },
                               onFailure: { (errors) -> Void in
                                
            });
    }

    func didSelectSegmentControl(sender : UISegmentedControl) {
        
    }
    
    func didReceiveCategory(category : PulsaCategoryRoot) {
        self.pulsaCategoryControl.removeAllSegments()
        var i = 0;
        for category in category.data {
            self.pulsaCategoryControl.insertSegmentWithTitle(category.attributes.name, atIndex: i, animated: false)
            i += 1
        }
        self.pulsaCategoryControl.hidden = false
        self.pulsaCategoryControl.selectedSegmentIndex = 0
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
