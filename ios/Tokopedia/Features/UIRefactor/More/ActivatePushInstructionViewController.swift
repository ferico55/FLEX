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
    
    @IBOutlet var aktifkanButton: UIButton? {
        didSet {
            aktifkanButton?.layer.borderColor = UIColor.white.cgColor
            aktifkanButton?.layer.borderWidth = 1
        }
    }
    
    fileprivate static var nibName: String {
        get {
            if #available(iOS 8, *) {
                return "ActivatePushInstructionViewController"
            }
            
            return "ActivatePushInstructionViewController7"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Just use init()")
    }

    init() {
        super.init(nibName: ActivatePushInstructionViewController.nibName, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCloseButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: viewControllerDidClosed)
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
