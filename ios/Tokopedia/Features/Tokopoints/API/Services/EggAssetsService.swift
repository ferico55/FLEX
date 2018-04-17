//
//  EggAssetsService.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Moya
import RxSwift
import UIKit

internal struct EggAsset {
    internal var bottomImage: UIImage
    internal var topImage: UIImage
    internal var leftImage: UIImage
    internal var rightImage: UIImage
    internal var smallImage: UIImage
    internal var bgImage: UIImage
}

internal enum EggAssetType {
    case egg
    case background
    case reward
}

internal class EggAssetsService: NSObject {
    internal class func getAssets(token: TokopointsTokenQuery.Data.TokopointsToken.Home.TokensUser) -> Observable<EggAsset?> {

        guard let smallImageUrlString = token.tokenAsset?.smallImgUrl, URL(string: smallImageUrlString) != nil,
            let bgUrlString = token.backgroundAsset?.backgroundImgUrl, URL(string: bgUrlString) != nil,
            let imageUrls = token.tokenAsset?.imageUrls,
            imageUrls.count >= 7,
            let topImageUrlString = imageUrls[0], URL(string: topImageUrlString) != nil,
            let bottomImageUrlString = imageUrls[4], URL(string: bottomImageUrlString) != nil,
            let topLeftImageUrlString = imageUrls[5], URL(string: topLeftImageUrlString) != nil,
            let topRightImageUrlString = imageUrls[6], URL(string: topRightImageUrlString) != nil
        else {
            return .just(nil)
        }

        var requestArray: [Observable<Data?>] = [
            downloadFile(url: topImageUrlString, key: fileKeyForURL(topImageUrlString, token: token)),
            downloadFile(url: bottomImageUrlString, key: fileKeyForURL(bottomImageUrlString, token: token)),
            downloadFile(url: topLeftImageUrlString, key: fileKeyForURL(topLeftImageUrlString, token: token)),
            downloadFile(url: topRightImageUrlString, key: fileKeyForURL(topRightImageUrlString, token: token)),
            downloadFile(url: bgUrlString, key: fileKeyForURL(bgUrlString, type: .background, token: token)),
            downloadFile(url: smallImageUrlString, key: fileKeyForURL(smallImageUrlString, token: token))
        ]
        
        return Observable.zip(requestArray).map({_ -> EggAsset? in
            guard let topImage = UIImage(contentsOfFile: filePathForURL(topImageUrlString, token: token)),
                let bottomImage = UIImage(contentsOfFile: filePathForURL(bottomImageUrlString, token: token)),
                let leftImage = UIImage(contentsOfFile: filePathForURL(topLeftImageUrlString, token: token)),
                let rightImage = UIImage(contentsOfFile: filePathForURL(topRightImageUrlString, token: token)),
                let bgImage = UIImage(contentsOfFile: filePathForURL(bgUrlString, type: .background, token: token)),
                let smallImage = UIImage(contentsOfFile: filePathForURL(smallImageUrlString, token: token))
            else {
                return nil
            }
            
            return EggAsset(bottomImage: bottomImage, topImage: topImage, leftImage: leftImage, rightImage: rightImage, smallImage: smallImage, bgImage: bgImage)
        }).catchErrorJustReturn(nil)
    }
    
    internal class func getRewardAsset(crackResult: CrackResultMutation.Data.CrackResult) -> Observable<UIImage?> {
        guard let imageUrl = crackResult.imageUrl, URL(string: imageUrl) != nil else {
            return .just(nil)
        }
        
        return downloadFile(url: imageUrl, key: fileKeyForURL(imageUrl, type: .reward))
            .map({ _ -> UIImage? in
                guard let rewardImage = UIImage(contentsOfFile: filePathForURL(imageUrl, type: .reward)) else {
                    return nil
                }
                
                return rewardImage
            }).catchErrorJustReturn(nil)
    }
    
    private class func filePathForURL(_ url: String, type: EggAssetType = .egg, token: TokopointsTokenQuery.Data.TokopointsToken.Home.TokensUser? = nil) -> String {
        return FileSystem.downloadDirectory.appendingPathComponent(fileKeyForURL(url, type: type, token: token)).path
    }
    
    private class func fileKeyForURL(_ url: String, type: EggAssetType = .egg, token: TokopointsTokenQuery.Data.TokopointsToken.Home.TokensUser? = nil) -> String {
        var name = ""
        var version = 0
        if type == .egg,
            let tokenName = token?.tokenAsset?.name,
            let tokenVersion = token?.tokenAsset?.version
        {
            name = tokenName
            version = tokenVersion
        }
        else if type == .background,
            let tokenName = token?.backgroundAsset?.name,
            let tokenVersion = token?.backgroundAsset?.version
        {
            name = tokenName
            version = tokenVersion
        }
        
        return "TokoPointsAssets/\(type)-\(name)-\(version)/" + (url as NSString).lastPathComponent
    }
    
    private class func downloadFile(url: String, key: String?) -> Observable<Data?> {
        if let key = key, CacheTweaks.shouldCacheTokopointsAssets() && FileManager.default.fileExists(atPath: FileSystem.downloadDirectory.appendingPathComponent(key).path) {
            return .just(FileManager.default.contents(atPath: FileSystem.downloadDirectory.appendingPathComponent(key).path))
        }
        return RxMoyaProvider<TokopointsTarget>()
            .request(.downloadFile(url: url, key: key))
            .map({ response -> Data? in
                return response.data
            }).catchErrorJustReturn(nil)
    }
}
