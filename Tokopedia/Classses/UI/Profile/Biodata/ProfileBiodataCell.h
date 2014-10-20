//
//  ProfileBiodataCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDPROFILEBIODATACELLIDENTIFIER @"DetailProfileBiodataCellIdentifier"

@interface ProfileBiodataCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelgender;
@property (weak, nonatomic) IBOutlet UILabel *labelbirth;
@property (weak, nonatomic) IBOutlet UILabel *labelhobbies;

+(id)newcell;

@end
