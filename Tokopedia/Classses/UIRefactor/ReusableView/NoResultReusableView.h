//
//  NoResultViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 11/9/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#define NO_RESULT_ICON @"icon_no_data_grey.png"
#define NO_RESULT_TITLE_SIZE (IS_IPHONE ? 14.0f : 20.0f);
#define NO_RESULT_DESC_SIZE (IS_IPHONE ? 11.0f : 18.0f);
#define NO_RESULT_BUTTON_TITLE_SIZE (IS_IPHONE ? 14.0f : 18.0f);
#define NO_RESULT_LINE_SPACING (IS_IPHONE ? 10.0f : 20.0f);

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
-(void)hideButton:(bool)hide;
@end


