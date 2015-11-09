//
//  NoResultViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 11/9/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoResultDelegate <NSObject>
-(void)buttonDidTapped:(id)sender;
@end

@interface NoResultReusableView : UIView
@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, weak) id<NoResultDelegate> delegate;
-(void)setNoResultImage:(NSString *)fileName;
-(void)setNoResultTitle:(NSString *)title;
-(void)setNoResultDesc:(NSString *)desc;
-(void)setNoResultButtonTitle:(NSString *)btnTitle;
-(void)generateAllElements:(NSString *)fileName title:(NSString *)title desc:(NSString *)desc btnTitle:(NSString *)btnTitle;
@end


