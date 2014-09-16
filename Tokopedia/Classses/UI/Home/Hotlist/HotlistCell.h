//
//  HotListCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define kTKPDHOTLISTCELL_IDENTIFIER @"HotListCellIdentifier"

#import <UIKit/UIKit.h>

@protocol HotlistCellDelegate <NSObject>
@required
-(void)HotlistCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end


@interface HotlistCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<HotlistCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<HotlistCellDelegate> delegate;
#endif

@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;

@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic, setter = setImageUrl:) NSString *urlstring;
@property (weak, nonatomic) IBOutlet UIImageView *productimageview;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

//-(void)setImageURL:(NSString*)urlstring;


@end
