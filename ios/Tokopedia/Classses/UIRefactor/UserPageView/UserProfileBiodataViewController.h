//
//  UserProfileBiodataViewController.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileInfo.h"

@interface UserProfileBiodataViewController : GAITrackedViewController
{
    IBOutlet NSLayoutConstraint *constraintHeightTableView;
}
@property (nonatomic, strong) NSString *profileUserID;
-(void) setHeaderData:(ProfileInfo*) profile;

@end
