//
//  SearchResultViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSEARCHRESULTCELL_IDENTIFIER @"SearchResultCellIdentifier"

@protocol SearchResultCellDelegate <NSObject>
@required
-(void)SearchResultCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface SearchResultCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SearchResultCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SearchResultCellDelegate> delegate;
#endif

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewcell;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumb;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelprice;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labeldescription;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelalbum;
@property (strong, nonatomic) IBOutletCollection(UIActivityIndicatorView) NSArray *act;
@property (strong, nonatomic) NSIndexPath *indexpath;

+ (id)newcell;


@end
