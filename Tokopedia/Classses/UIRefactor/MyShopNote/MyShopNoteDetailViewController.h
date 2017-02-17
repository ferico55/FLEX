//
//  MyShopNoteDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NotesList;

@protocol MyShopNoteDetailDelegate <NSObject>

- (void)successEditNote:(NotesList *)noteList;

@optional
- (void)successCreateNewNote;

@end

@interface MyShopNoteDetailViewController : UIViewController

@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic, weak) id<MyShopNoteDetailDelegate> delegate;
@property (nonatomic, strong) NotesList *noteList;
@property (nonatomic, strong) NSString* shopDomain;


@end
