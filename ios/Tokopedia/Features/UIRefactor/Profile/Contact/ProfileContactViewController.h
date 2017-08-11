//
//  ProfileContactView.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileInfo.h"

@interface ProfileContactViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *labelemail;
@property (strong, nonatomic) IBOutlet UILabel *labelmesseger;
@property (strong, nonatomic) IBOutlet UILabel *labelmobile;

@property (strong, nonatomic) NSDictionary *data;
-(void) setHeaderData:(ProfileInfo*) profile;

@end
