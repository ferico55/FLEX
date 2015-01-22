//
//  DetailProductOtherView.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailProductOtherViewDelegate <NSObject>
@required
-(void)DetailProductOtherView:(UIView*)view withindex:(NSInteger)index;

@end

@interface DetailProductOtherView : UIView

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<DetailProductOtherViewDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<DetailProductOtherViewDelegate> delegate;
#endif

@property (strong, nonatomic) IBOutlet UIImageView *thumb;
@property (strong, nonatomic) IBOutlet UILabel *namelabel;
@property (strong, nonatomic) IBOutlet UILabel *pricelabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (nonatomic) NSInteger index;

+(id)newview;

@end
