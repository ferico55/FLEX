//
//  MyShopNoteDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Tokopedia-Swift.h"

@protocol MyShopNoteDetailDelegate <NSObject>

- (void)successCreateNewNote;
- (void)successEditNote:(NotesListSwift *)noteList;

@end

@interface MyShopNoteDetailViewController : UIViewController

@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic, weak) id<MyShopNoteDetailDelegate> delegate;
@property (nonatomic, strong) NotesListSwift *noteList;

@end
