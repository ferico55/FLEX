//
//  RCManager.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 31/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON
import RxSwift
import DKImagePickerController
import Photos
class RCManager: NSObject {
    static let shared = RCManager()
    var rcCreateStep1Data: RCCreateStep1ResponseData?
    var uploadedImages: [ImageResult] = []
    var isProlaticItemsLoaded = false
    var order: TxOrderStatusList!
    var isRecieved: Bool {
        return (self.order.order_button.button_open_complaint_not_received == 1)
    }
    var provider = RCServiceProvider()
    //    MARK:- Public services
    func fetchCreateStep1(onCompletion: @escaping ((_ error:Swift.Error?) -> Void)) {
        if let id = self.order.order_detail.detail_order_id {
            _ = self.provider.request(.getStep1(orderId: id), completion: { (result) in
                    switch result {
                    case let .success(response):
                        let json = JSON(data: response.data)
                        let response = RCCreateStep1Response(json: json)
                        if response.message_error.count > 0 {
                            StickyAlertView.showErrorMessage(response.message_error)
                        } else {
                            self.rcCreateStep1Data = response.data
                        }
                        onCompletion(nil)
                        break
                    case let .failure(error):
                        onCompletion(error)
                        break
                    }
                })
        }
    }
    func fetchSolutions(onCompletion: @escaping ((_ response:RCCreateSolutionData?,_ error:Swift.Error?) -> Void)) {
        guard let data = self.rcCreateStep1Data else {return}
        if let id = self.order.order_detail.detail_order_id {
            _ = self.provider.request(.getSolutions(orderId: id, rcStep1Data: data), completion: { (result) in
                switch result {
                case let .success(response):
                    let json = JSON(data: response.data)
                    let solution = RCCreateSolutionResponse(json: json)
                    if solution.message_error.count > 0 {
                        StickyAlertView.showErrorMessage(solution.message_error)
                    }
                    onCompletion(solution.data, nil)
                    break
                case let .failure(error):
                    onCompletion(nil, error)
                    break
                }
            })
        }
    }
    func createComplaint(onCompletion: @escaping ((_ response:RCCreateComplaintResponse?,_ error:Swift.Error?) -> Void)) {
        guard let orderId = self.order.order_detail.detail_order_id else {
            onCompletion(nil,NSError(domain: "", code: 999, userInfo: nil))
            return
        }
        guard let data = self.rcCreateStep1Data else {
            onCompletion(nil,NSError(domain: "", code: 999, userInfo: nil))
            return
        }
        self.cacheKeyToCreateComplaint(orderId: orderId, rcCreateStep1Data: data, onCompletion: { (response, error) in
            if let error = error {
                StickyAlertView.showErrorMessage([error.localizedDescription])
                onCompletion(nil, error)
            } else {
                if data.isProofSubmissionRequired {
                    _ = GenerateHostObservable.getGeneratedHost()
                        .subscribe(onNext: { (host) in
                            self.uploadedImages.removeAll()
                            self.uploadPhotos(host: host, token: response?.data?.token, index: 0, onCompletion: { (error1) in
                                if let error = error {
                                    StickyAlertView.showErrorMessage([error.localizedDescription])
                                    onCompletion(nil, error)
                                } else {
                                    self.createComplaint(orderId: orderId, cacheKey: response?.data?.cacheKey, images: self.uploadedImages, onCompletion: { (response1, error2) in
                                        onCompletion(response1,error2)
                                    })
                                }
                            })
                        }, onError: { (error) in
                            onCompletion(nil, error)
                        })
                } else {
                    onCompletion(response,nil)
                }
            }
        })
    }
    //    MARK:- Private
    private func createComplaint(orderId: String, cacheKey: String?, images: [ImageResult],  onCompletion: @escaping ((_ response:RCCreateComplaintResponse?,_ error:Swift.Error?) -> Void)) {
        guard let key = cacheKey else {
            onCompletion(nil,NSError(domain: "", code: 999, userInfo: nil))
            return
        }
        _ = self.provider.request(.createComplaint(orderId: orderId, cacheKey: key, imageObjects: images), completion: { (result) in
            switch result {
            case let .success(response):
                let json = JSON(data: response.data)
                let createData = RCCreateComplaintResponse(json: json)
                onCompletion(createData,nil)
                break
            case let .failure(error):
                onCompletion(nil,error)
                break
            }
        })
    }
    private func cacheKeyToCreateComplaint(orderId: String, rcCreateStep1Data: RCCreateStep1ResponseData, onCompletion: @escaping ((_ response:RCCreateComplaintResponse?,_ error:Swift.Error?) -> Void)) {
        _ = self.provider.request(.cacheKeyToCreateComplaint(orderId: orderId, rcStep1Data: rcCreateStep1Data), completion: { (result) in
            switch result {
            case let .success(response):
                let json = JSON(data: response.data)
                let createData = RCCreateComplaintResponse(json: json)
                onCompletion(createData,nil)
                break
            case let .failure(error):
                onCompletion(nil,error)
                break
            }
        })
    }
    private func uploadPhotos(host: GeneratedHost?, token:String?, index: Int, onCompletion: @escaping ((_ error:Swift.Error?)->Void)) {
        guard let photos = self.rcCreateStep1Data?.selectedPhotos else {
            onCompletion(nil)
            return
        }
        let asset = photos[index]
        guard !asset.isVideo else {
            self.uploadVideo(host: host, token: token, index: index, onCompletion: onCompletion)
            return
        }
        asset.fetchOriginalImageWithCompleteBlock { (image: UIImage?, info) in
            let auth : UserAuthentificationManager = UserAuthentificationManager()
            let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
            postObject.user_id = auth.getUserId()
            postObject.server_id = host?.server_id
            postObject.token = token
            postObject.image_id = String(arc4random())
            let baseURLString = String(format:"https://%@",host?.upload_host ?? "")
            RequestUploadImage.requestUploadImageResolution(image,
                                                            withUploadHost: baseURLString,
                                                            path: "/upload/attachment",
                                                            name: "fileToUpload",
                                                            fileName: "Image",
                                                            request: postObject,
                                                            onSuccess: { (imageResult) in
                                                                if let result = imageResult {
                                                                    result.isVideo = false
                                                                    self.uploadedImages.append(result)
                                                                    if index+1 < photos.count {
                                                                        self.uploadPhotos(host: host, token: token, index: index+1, onCompletion: onCompletion)
                                                                    } else {
                                                                        onCompletion(nil)
                                                                    }
                                                                } else {
                                                                    onCompletion(nil)
                                                                }
            }, onFailure: { (error) in
                onCompletion(error)
            })
        }
    }
    private func uploadVideo(host: GeneratedHost?, token:String?, index: Int, onCompletion: @escaping ((_ error:Swift.Error?)->Void)) {
        guard let photos = self.rcCreateStep1Data?.selectedPhotos else {
            onCompletion(nil)
            return
        }
        let asset = photos[index]
        guard asset.isVideo else {
            self.uploadPhotos(host: host, token: token, index: index, onCompletion: onCompletion)
            return
        }
        guard let videoAsset = asset.originalAsset else {onCompletion(nil); return}
        self.getVideoUrlFrom(asset: videoAsset, index: index) { (url) in
            let auth : UserAuthentificationManager = UserAuthentificationManager()
            let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
            postObject.user_id = auth.getUserId()
            postObject.server_id = host?.server_id
            postObject.token = token
            postObject.image_id = String(arc4random())
            let baseURLString = String(format:"https://%@",host?.upload_host ?? "")
            RequestUploadImage.requestUploadVideo(url,
                                                            withUploadHost: baseURLString,
                                                            path: "/upload/video",
                                                            name: "fileToUpload",
                                                            fileName: "video",
                                                            request: postObject,
                                                            onSuccess: { (imageResult) in
                                                                do {
                                                                    if let url = url {
                                                                        try FileManager.default.removeItem(at: url)
                                                                    }
                                                                } catch {
                                                                }
                                                                if let result = imageResult {
                                                                    result.isVideo = true
                                                                    self.uploadedImages.append(result)
                                                                    if index+1 < photos.count {
                                                                        self.uploadPhotos(host: host, token: token, index: index+1, onCompletion: onCompletion)
                                                                    } else {
                                                                        onCompletion(nil)
                                                                    }
                                                                } else {
                                                                    onCompletion(nil)
                                                                }
            }, onFailure: { (error) in
                onCompletion(error)
            })
        }
    }
    private func getVideoUrlFrom(asset: PHAsset, index:Int, completion: @escaping ((URL?)->Void)) {
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .fastFormat
        PHImageManager.default().requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetLowQuality) { (exportSession, info) in
            if let urlAsset = exportSession?.asset as? AVURLAsset {
                exportSession?.outputFileType = self.fileType(fileExtension: urlAsset.url.pathExtension)
                exportSession?.outputURL = self.videoCacheUrl(filename: String(format:"video%d.%@",index,urlAsset.url.pathExtension))
            } else {
                exportSession?.outputFileType = AVFileTypeQuickTimeMovie
                exportSession?.outputURL = self.videoCacheUrl(filename: String(format:"video%d.mov",index))
            }
            exportSession?.exportAsynchronously {
                if let url = exportSession?.outputURL {
                    completion(url)
                }
            }
        }
    }
    private func videoCacheUrl(filename: String)->URL? {
        if let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let finalUrl = url.appendingPathComponent(filename.lowercased())
            do {
                try FileManager.default.removeItem(at: finalUrl)
            } catch {}
            return finalUrl
        }
        return nil
    }
    private func fileType(fileExtension: String)->String {
        switch fileExtension {
        case "mp4": return AVFileTypeMPEG4
        case "mov": return AVFileTypeQuickTimeMovie
        default: return AVFileTypeQuickTimeMovie
        }
    }
}
