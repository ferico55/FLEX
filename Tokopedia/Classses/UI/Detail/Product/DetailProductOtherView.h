//
//  DetailProductOtherView.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailProductOtherView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *thumb;
@property (strong, nonatomic) IBOutlet UILabel *namelabel;
@property (strong, nonatomic) IBOutlet UILabel *pricelabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *act;

+(id)newview;

@end
