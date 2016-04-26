//
//  ProductTalkDetailViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 10/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TalkList;

#pragma mark - Detail Product Talk Detail View Controller
@interface ProductTalkDetailViewController : UIViewController
{
    IBOutlet UIButton *btnReputation;
}

- (IBAction)actionSmiley:(id)sender;
@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) TalkList *talk;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) BOOL enableDeepNavigation;

-(void)replaceDataSelected:(NSDictionary *)data;
-(id) initByMarkingOpenedTalkAsRead:(BOOL) marksOpenedTalkAsRead;

@end
