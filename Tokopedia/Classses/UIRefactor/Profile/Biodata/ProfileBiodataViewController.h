//
//  ProfileBiodataViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileBiodataViewController: UIViewController

@property (weak, nonatomic) IBOutlet UILabel *labelgender;
@property (weak, nonatomic) IBOutlet UILabel *labelbirth;
@property (weak, nonatomic) IBOutlet UILabel *labelhobbies;
@property (nonatomic) BOOL isNotMyBiodata;

@end
