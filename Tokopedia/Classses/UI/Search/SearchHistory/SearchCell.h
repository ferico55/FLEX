//
//  SearchCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDCATEGORYCELL_IDENTIFIER @"SearchCellIdentifier"

@protocol SearchCellDelegate <NSObject>
@required
-(void)SearchCellDelegate:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath withdata:(NSDictionary*)data;

@end

@interface SearchCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SearchCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SearchCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *lable;

@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;

@end
