//
//  ShopInfoViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopInfoViewController : UIViewController
{
    IBOutlet UIButton *btnLihatDetailStat;
    IBOutlet UILabel *lblReputasi, *lblKecepatan;
    IBOutlet UIImageView *imageSpeed, *imageReputasi;
}

@property (strong, nonatomic) NSDictionary *data;
- (IBAction)actionLihatDetailStatistik:(id)sender;
@end
