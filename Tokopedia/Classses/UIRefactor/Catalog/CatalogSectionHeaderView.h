//
//  CatalogSectionHeaderView.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatalogSectionHeaderView : UIView
{
    IBOutlet UIView *viewContent;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
