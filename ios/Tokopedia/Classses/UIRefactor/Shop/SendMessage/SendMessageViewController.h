//
//  SendMessageViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Shop;

@protocol CustomTxtViewProtocol <NSObject>
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
@end

@interface MessageTextView : UITextView<CustomTxtViewProtocol>
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, unsafe_unretained) id<CustomTxtViewProtocol> del;
- (void)textChanged:(NSNotification*)notification;
@end





@interface SendMessageViewController : UIViewController

@property (strong, nonatomic) NSDictionary* data;
@property (strong, nonatomic) NSString* subject;
@property (strong, nonatomic) NSString* message;

- (instancetype)initToShop:(nonnull Shop *)shop;
- (void)displayFromViewController:(UIViewController *)viewController;

@end
