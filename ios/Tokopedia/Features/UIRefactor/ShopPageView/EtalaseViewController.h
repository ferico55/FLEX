//
//  EtalaseFilterViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 4/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Etalase.h"

@protocol EtalaseViewControllerDelegate <NSObject>
@optional
-(void)didSelectEtalase:(EtalaseList*)selectedEtalase;
-(void)didSelectEtalaseFilter:(EtalaseList*)selectedEtalase;
@end

@interface EtalaseViewController : UIViewController
@property (strong, nonatomic) NSString* shopId;
@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* shopDomain;

@property (nonatomic) BOOL showOtherEtalase;
@property (nonatomic) BOOL enableAddEtalase;
@property (nonatomic) BOOL isEditable;

@property (strong, nonatomic) EtalaseList *initialSelectedEtalase;

@property (nonatomic, weak) id<EtalaseViewControllerDelegate> delegate;
@end
