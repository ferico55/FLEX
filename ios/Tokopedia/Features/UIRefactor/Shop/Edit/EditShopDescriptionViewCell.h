//
//  EditShopDescriptionViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDTextView.h"

typedef NS_ENUM(NSInteger, ShopTextViewType) {
    ShopTextViewForTag = 1,
    ShopTextViewForDescription = 2,
};

@interface EditShopDescriptionViewCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet TKPDTextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

- (void)updateCountLabel;

@end
