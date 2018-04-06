//
//  RCProofPhotosViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import DKImagePickerController
import UIKit

internal class RCProofPhotosViewController: UICollectionViewController {
    weak internal var parentController: RCProofTableController?
    fileprivate var selectedPhotos: [DKAsset] = []
    internal override func viewDidLoad() {
        super.viewDidLoad()
        if let photos = RCManager.shared.rcCreateStep1Data?.selectedPhotos {
            self.selectedPhotos.append(contentsOf: photos)
        }
    }
    internal override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if let parent = parent as? RCProofTableController {
            self.parentController = parent
        }
    }
//    MARK:-
    internal func showImagePicker() {
        TKPImagePickerController.showImagePicker(
            self,
            assetType: .allAssets,
            allowMultipleSelect: true,
            showCancel: true,
            showCamera: true,
            maxSelected: 5,
            selectedAssets: self.selectedPhotos as NSArray?,
            completion: {[unowned self]  (assets) in
                self.selectedPhotos = assets
                if assets.count > 0 {
                    self.parentController?.parentController?.selectedPhotos = self.selectedPhotos
                } else {
                    self.parentController?.parentController?.selectedPhotos =  nil
                }
                self.collectionView?.reloadData()
                self.parentController?.parentController?.refreshUI()
        })
    }
// MARK:- UICollectionViewDataSource
    internal override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedPhotos.count + 1
    }
    internal override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RCPhotosCollectionCell", for: indexPath) as? RCPhotosCollectionCell else {return UICollectionViewCell()}
        if indexPath.item >= self.selectedPhotos.count {
            cell.imageView.image = #imageLiteral(resourceName: "camera_reso")
            cell.removeButton.isHidden = true
        } else {
            let asset = self.selectedPhotos[indexPath.item]
            let size = CGSize(width: 160, height: 160)
            asset.fetchImageWithSize(size, completeBlock: { (image, info:[AnyHashable : Any]?) in
                cell.imageView.image = image
            })
            cell.removeButton.isHidden = false
            cell.removeButtonHandler = {[weak self]()->Void in
                guard let `self` = self else { return }
                self.selectedPhotos.remove(at: indexPath.item)
                if self.selectedPhotos.count > 0 {
                    self.parentController?.parentController?.selectedPhotos = self.selectedPhotos
                } else {
                    self.parentController?.parentController?.selectedPhotos =  nil
                }
                self.collectionView?.reloadData()
                self.parentController?.parentController?.refreshUI()
            }
        }
        
        return cell
    }
    internal override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item >= self.selectedPhotos.count {
            self.showImagePicker()
        }
    }
}
