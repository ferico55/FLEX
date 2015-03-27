//
//  TransactionCartHeaderView.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TransactionCartHeaderView;

#pragma mark - General Talk Cell Delegate
@protocol TransactionCartHeaderViewDelegate <NSObject>
@required
- (void)deleteTransactionCartHeaderView:(TransactionCartHeaderView*)view atSection:(NSInteger)section;
- (void)didTapShopAtSection:(NSInteger)section;
@end

@interface TransactionCartHeaderView : UIView

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TransactionCartHeaderViewDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TransactionCartHeaderViewDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (nonatomic) NSInteger section;

+(id)newview;

@end
