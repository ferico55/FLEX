//
//  SearchFilterLocationViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSEARCHFILTERLOCATIONVIEWCELL_IDENTIFIER @"SearchFilterLocationViewCellIdentifier"

@protocol SearchFilterLocationViewCellDelegate <NSObject>
@required
-(void)SearchFilterLocationViewCell:(UITableViewCell*)cell withdata:(NSDictionary*)data;

@end

@interface SearchFilterLocationViewCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SearchFilterLocationViewCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SearchFilterLocationViewCellDelegate> delegate;
#endif

@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;

@property (weak, nonatomic) IBOutlet UILabel *label;

@end
