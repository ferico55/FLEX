//
//  ConversationModelView.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConversationViewModel : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userProfilePicture;
@property (strong, nonatomic) NSString *conversationOwner;
@property (strong, nonatomic) NSString *conversationMessage;
@property (strong, nonatomic) NSString *conversationNote;
@property (strong, nonatomic) NSArray *conversationPhotos;
@property (strong, nonatomic) NSString *conversationDate;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
