//
//  RCProofPhotosViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import DKImagePickerController
class RCProofPhotosViewController: UICollectionViewController {
    weak var parentController: RCProofTableController?
    fileprivate var selectedPhotos: [DKAsset] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if let photos = RCManager.shared.rcCreateStep1Data?.selectedPhotos {
            self.selectedPhotos.append(contentsOf: photos)
        }
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if let parent = parent as? RCProofTableController {
            self.parentController = parent
        }
    }
//    MARK:-
    func showImagePicker() {
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
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedPhotos.count + 1
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RCPhotosCollectionCell", for: indexPath) as? RCPhotosCollectionCell else {return UICollectionViewCell()}
        if indexPath.item >= self.selectedPhotos.count {
            cell.imageView.image = #imageLiteral(resourceName: "camera_reso")
        } else {
            let asset = self.selectedPhotos[indexPath.item]
            let size = CGSize(width: 160, height: 160)
            asset.fetchImageWithSize(size, completeBlock: { (image, info:[AnyHashable : Any]?) in
                cell.imageView.image = image
            })
        }
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item >= self.selectedPhotos.count {
            self.showImagePicker()
        }
    }
}
