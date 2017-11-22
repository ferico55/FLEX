//
//  ReactPopoverOptionViewController.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 10/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReactPopoverOptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet private var tableView: UITableView!
    var overlayView:UIView
    var options:[String] = ["Bagikan", "Laporkan"]
    var callback:((_ selectedIndex:Int) -> Void)? = nil
    var superViewController: UIViewController
    
    init(options: [String], anchorView: UIView, presentingViewController: UIViewController, callback: ((_ selectedIndex:Int) -> Void)?) {
        self.options = options
        self.superViewController = presentingViewController
        
        self.overlayView = UIView(frame: presentingViewController.view.frame)
        self.overlayView.backgroundColor = UIColor.black
        self.overlayView.alpha = 0.5
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .popover
        self.popoverPresentationController?.delegate = self
        self.popoverPresentationController?.sourceView = anchorView
        self.popoverPresentationController?.sourceRect = CGRect(x: anchorView.bounds.origin.x - 8, y: anchorView.bounds.origin.y - 8, width: anchorView.bounds.size.width + 16, height: anchorView.bounds.size.height + 16)
        self.popoverPresentationController?.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showPopover() {
        self.superViewController.view.addSubview(self.overlayView)
        self.superViewController.present(self, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        let width = UIDevice.current.userInterfaceIdiom == .pad ? 320 : self.superViewController.view.frame.width
        self.view.frame = CGRect(x: 0, y: 0, width: Int(width), height: 54 * options.count)
        self.view.superview?.layer.cornerRadius = 8;

        self.preferredContentSize = CGSize(width: Int(width), height: 54 * options.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib.init(nibName: "OptionCell", bundle: nil), forCellReuseIdentifier: "optionCell")

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.overlayView.removeFromSuperview()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else {
                return
            }
            self.callback?(indexPath.row)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}
