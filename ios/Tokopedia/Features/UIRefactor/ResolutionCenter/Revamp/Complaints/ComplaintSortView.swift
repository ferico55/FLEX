//
//  ComplaintSortView.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 01/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal protocol ComplaintSortViewDelegate: class {
    func complaintSortView(_ complaintSortView: ComplaintSortView, didSelectItemAt index: Int)
}

internal class ComplaintSortView: UIView {

    fileprivate let backgroundView = UIView()
    fileprivate let mainView = UIView()
    fileprivate let tableView = UITableView()
    fileprivate let rowHeight: CGFloat = 65
    fileprivate let titleHeight: CGFloat = 48
    fileprivate let separatorHeight: CGFloat = 1
    
    fileprivate var title: String = "Urutkan"
    fileprivate var data: [SimpleOnOffListObject]
    fileprivate var allowMultipleSelection: Bool = false
    
    internal weak var delegate: ComplaintSortViewDelegate?
    
    internal init(title: String, data: [SimpleOnOffListObject], allowMultipleSelection: Bool) {
        self.title = title
        self.data = data
        self.allowMultipleSelection = allowMultipleSelection
        
        super.init(frame: UIScreen.main.bounds)
        
        let frame = UIScreen.main.bounds
        
        // prepare things
        tableView.delegate = self
        tableView.dataSource = self
        
        // background view
        backgroundView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        self.addSubview(backgroundView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundDidTapped))
        backgroundView.addGestureRecognizer(tap)
        
        // main view
        mainView.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: frame.height)
        mainView.backgroundColor = .white
        mainView.layer.shadowColor = UIColor.tpBorder().cgColor
        mainView.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        mainView.layer.shadowRadius = 2.0
        mainView.layer.shadowOpacity = 1.0
        mainView.layer.masksToBounds = false

        self.addSubview(mainView)
        
        // title view
        let titleView = UILabel(frame: CGRect(x: 48, y: 0, width: frame.width - 32, height: titleHeight))
        titleView.text = title
        titleView.font = UIFont.systemFont(ofSize: 16)
        titleView.textColor = .tpSecondaryBlackText()
        mainView.addSubview(titleView)
        
        // btn close
        let btnClose = UIButton(type: .system)
        btnClose.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        btnClose.setImage(#imageLiteral(resourceName: "icon_close"), for: .normal)
        btnClose.imageView?.contentMode = .center
        btnClose.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        btnClose.addTarget(self, action: #selector(backgroundDidTapped), for: .touchUpInside)
        mainView.addSubview(btnClose)
        
        // separator
        let separator = UIView(frame: CGRect(x: 0, y: titleHeight, width: frame.width, height: separatorHeight))
        separator.backgroundColor = .tpBorder()
        mainView.addSubview(separator)
        
        // table view
        let tableViewHeight = min(rowHeight * CGFloat(data.count), (frame.height / 2) - (titleHeight + separatorHeight))
        tableView.frame = CGRect(x: 0, y: titleHeight + separatorHeight, width: frame.width, height: tableViewHeight)
        tableView.allowsMultipleSelection = allowMultipleSelection
        mainView.addSubview(tableView)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func captureScreen() -> UIImage? {
        guard let layer = UIApplication.shared.keyWindow?.layer else { return nil }
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }

    internal func show(animated: Bool) {
        guard let superView = UIApplication.shared.delegate?.window ?? UIApplication.shared.keyWindow else {
            return
        }
        
        superView.addSubview(self)
        
        if let backgroundImage = captureScreen() {
            backgroundView.backgroundColor = UIColor(patternImage: backgroundImage.applyBlur(withRadius: 5, tintColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil))
        }
        else {
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.66)
        }
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 1
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
                self.mainView.frame.origin.y = UIScreen.main.bounds.height - self.tableView.frame.height - self.titleHeight - self.separatorHeight
                if #available(iOS 11, *) {
                    self.mainView.frame.origin.y -= self.safeAreaInsets.bottom
                }
            }, completion: nil)
        }
        else {
            self.backgroundView.alpha = 1
            self.mainView.frame.origin.y = UIScreen.main.bounds.height - self.tableView.frame.height - self.titleHeight - self.separatorHeight
            if #available(iOS 11, *) {
                self.mainView.frame.origin.y -= self.safeAreaInsets.bottom
            }
        }
    }
    
    internal func dismiss(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
                self.mainView.frame.origin = CGPoint(x: self.mainView.frame.origin.x, y: self.frame.height)
                self.mainView.alpha = 0
            }, completion: { (completed) in
                self.removeFromSuperview()
            })
        }
        else {
            self.removeFromSuperview()
        }
    }
    
    internal func backgroundDidTapped() {
        self.dismiss(animated: true)
    }
}

extension ComplaintSortView: UITableViewDelegate {
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.complaintSortView(self, didSelectItemAt: indexPath.row)
        
        self.dismiss(animated: true)
    }
}

extension ComplaintSortView: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "tableViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "tableViewCell")
        }
        
        let row = indexPath.row
        
        cell?.tintColor = UIColor.tpGreen()
        cell?.textLabel?.text = data[row].title
        cell?.textLabel?.textColor = UIColor.tpPrimaryBlackText()
        if data[row].isSelected {
            cell?.accessoryView = UIImageView(image: #imageLiteral(resourceName: "radioselected"))
        }
        else {
            cell?.accessoryView = UIImageView(image: #imageLiteral(resourceName: "radionotselected"))
        }
        
        return cell!
    }
}
