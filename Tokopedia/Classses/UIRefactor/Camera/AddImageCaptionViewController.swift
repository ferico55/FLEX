//
//  AddImageCaptionViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class AddImageCaptionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var attachedImages : NSMutableArray!
    var isEdit : Bool = false
    var collectionView : UICollectionView!
    
    let reuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = isEdit ? "Ubah Gambar" : "Tambah Gambar"
        
        let cancelBarButton = UIBarButtonItem(title: "Batal", style: .Bordered, target: self, action: nil)
        cancelBarButton.tag = 10
        self.navigationItem.rightBarButtonItem = cancelBarButton
        
        let doneBarButton = UIBarButtonItem(title: "Simpan", style: .Bordered, target: self, action: nil)
        doneBarButton.tag = 11
        self.navigationItem.rightBarButtonItem = doneBarButton
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.view.addSubview(collectionView)
        
        // Keyboard Notification
        let notification = NSNotificationCenter.defaultCenter()
//        notification.addObserver(self, selector: Selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
//        notification.addObserver(self, selector: Selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return attachedImages.count
        } else if (section == 1) {
            return 1
        } else if (section == 2) {
            return attachedImages.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (indexPath.section == 0) {
            
        } else if (indexPath.section == 1) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AddCaptionTextFieldCell
            cell.addCaptionTextField.placeholder = "Keterangan Gambar"
        } else if (indexPath.section == 2) {
            
        }
        
        return UICollectionViewCell()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var itemSize = CGSizeZero
        if (indexPath.section == 0) {
            itemSize = CGSize(width: self.view.frame.width, height: 329)
        } else if (indexPath.section == 1) {
            itemSize = CGSize(width: self.view.frame.width, height: 42)
        } else if (indexPath.section == 2) {
            itemSize = CGSize(width: 50, height: 50)
        }
        
        return itemSize
    }
}
