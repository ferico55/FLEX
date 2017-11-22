//
//  FeedCardKOLPostState.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import ReSwift

struct FeedCardKOLPostState: Render.StateType, ReSwift.StateType {
    var cardID = 0
    var isFollowed = false
    var tempFollowing = false
    var isLiked = false
    var title = ""
    var commentCount = 0
    var likeCount = 0
    var imageURL = ""
    var description = ""
    var createTime = ""
    var tagType = ""
    var tagURL = ""
    var tagCaption = ""
    var userName = ""
    var userPhoto = ""
    var userInfo = ""
    var userID = 0
    var userURL = ""
    var descriptionShownAll = false
    var page = 0
    var row = 0
    var dictionary: [String: Any] {
        return [
            "cardID": cardID,
            "isFollowed": isFollowed,
            "tempFollowing": tempFollowing,
            "isLiked": isLiked,
            "title": title,
            "commentCount": commentCount,
            "likeCount": likeCount,
            "imageURL": imageURL,
            "description": description,
            "createTime": createTime,
            "tagType": tagType,
            "tagURL": tagURL,
            "tagCaption": tagCaption,
            "userName": userName,
            "userPhoto": userPhoto,
            "userInfo": userInfo,
            "userID": userID,
            "userURL": userURL,
            "descriptionShownAll": descriptionShownAll,
            "page": page,
            "row": row,
        ]
    }
    
    init() {}
    
    init(post: FeedsQuery.Data.Feed.Datum.Content.Kolpost, page: Int, row: Int) {
        self.cardID = post.id ?? 0
        self.title = post.headerTitle ?? ""
        self.isFollowed = post.isFollowed ?? false
        self.isLiked = post.isLiked ?? false
        self.commentCount = post.commentCount ?? 0
        self.likeCount = post.likeCount ?? 0
        self.description = post.description ?? ""
        self.userName = post.userName ?? ""
        self.userPhoto = post.userPhoto ?? ""
        self.userInfo = post.userInfo ?? ""
        self.userID = post.userId ?? 0
        self.createTime = post.createTime ?? ""
        self.userURL = post.userUrl ?? ""
        self.page = page
        self.row = row
        
        if self.description.characters.count > 150 {
            self.descriptionShownAll = false
        }
        
        if let postContent = post.content, postContent.count > 0, let mainContent = postContent[0] {
            self.imageURL = mainContent.imageurl ?? ""
            
            if let tags = mainContent.tags, tags.count > 0, let tag = tags[0] {
                self.tagType = tag.type ?? ""
                self.tagURL = tag.link ?? ""
                self.tagCaption = tag.caption ?? ""
            }
        }
    }
    
    init(post: FeedsQuery.Data.Feed.Datum.Content.Followedkolpost, page: Int, row: Int) {
        self.cardID = post.id ?? 0
        self.title = post.headerTitle ?? ""
        self.isFollowed = post.isFollowed ?? false
        self.isLiked = post.isLiked ?? false
        self.commentCount = post.commentCount ?? 0
        self.likeCount = post.likeCount ?? 0
        self.description = post.description ?? ""
        self.userName = post.userName ?? ""
        self.userPhoto = post.userPhoto ?? ""
        self.userInfo = post.userInfo ?? ""
        self.userID = post.userId ?? 0
        self.userURL = post.userUrl ?? ""
        self.createTime = post.createTime ?? ""
        self.page = page
        self.row = row
        
        if self.description.characters.count > 150 {
            self.descriptionShownAll = false
        }
        
        if let postContent = post.content, postContent.count > 0, let mainContent = postContent[0] {
            self.imageURL = mainContent.imageurl ?? ""
            
            if let tags = mainContent.tags, tags.count > 0, let tag = tags[0] {
                self.tagType = tag.type ?? ""
                self.tagURL = tag.link ?? ""
                self.tagCaption = tag.caption ?? ""
            }
        }
    }
    
    init(stateDict: [String: Any]) {
        self.cardID = stateDict["cardID"] as? Int ?? 0
        self.isFollowed = stateDict["isFollowed"] as? Bool ?? false
        self.tempFollowing = stateDict["tempFollowing"] as? Bool ?? false
        self.isLiked = stateDict["isLiked"] as? Bool ?? false
        self.title = stateDict["title"] as? String ?? ""
        self.commentCount = stateDict["commentCount"] as? Int ?? 0
        self.likeCount = stateDict["likeCount"] as? Int ?? 0
        self.imageURL = stateDict["imageURL"] as? String ?? ""
        self.description = stateDict["description"] as? String ?? ""
        self.createTime = stateDict["createTime"] as? String ?? ""
        self.tagType = stateDict["tagType"] as? String ?? ""
        self.tagURL = stateDict["tagURL"] as? String ?? ""
        self.tagCaption = stateDict["tagCaption"] as? String ?? ""
        self.userName = stateDict["userName"] as? String ?? ""
        self.userPhoto = stateDict["userPhoto"] as? String ?? ""
        self.userInfo = stateDict["userInfo"] as? String ?? ""
        self.userID = stateDict["userID"] as? Int ?? 0
        self.userURL = stateDict["userURL"] as? String ?? ""
        self.descriptionShownAll = stateDict["descriptionShownAll"] as? Bool ?? false
        self.page = stateDict["page"] as? Int ?? 0
        self.row = stateDict["row"] as? Int ?? 0
    }
}
