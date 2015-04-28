//
//  MyShopNoteDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyShopNoteDetailDelegate <NSObject>

- (void)successEditNote:(NSString *)title text:(NSString *)text;

@end

@interface MyShopNoteDetailViewController : UIViewController

@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic, retain) id<MyShopNoteDetailDelegate> delegate;

@end
