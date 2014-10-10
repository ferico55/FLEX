//
//  ShopNotesCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSHOPNOTESCELL_IDENTIFIER @"ShopNotesCellIdentifier"

@protocol ShopNotesCellDelegate <NSObject>
@required
-(void)ShopNotesCellDelegate:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface ShopNotesCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ShopNotesCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ShopNotesCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) NSIndexPath *indexpath;

+ (id)newcell;
@end
