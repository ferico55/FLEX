//
//  ActivatePushInstructionViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 5/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(ActivatePushInstructionViewController)
class ActivatePushInstructionViewController: UIViewController {

    var viewControllerDidClosed: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCloseButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: viewControllerDidClosed)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
