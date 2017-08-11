//
//  ProfileFavoriteShopViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileInfo.h"

@interface ProfileFavoriteShopViewController : GAITrackedViewController

@property (strong, nonatomic) NSDictionary *data;
@property (nonatomic) NSString *profileUserID;
-(void) setHeaderData:(ProfileInfo*) profile;

@end
