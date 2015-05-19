//
//  ContainerViewController.m
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import "reputation_string.h"

#import "ReputationShopHeader.h"
#import "AlertReputation.h"

@interface ReputationShopHeader ()
<
    UIScrollViewDelegate,
    UISearchBarDelegate,
    TKPDAlertViewDelegate
>

@end


@implementation ReputationShopHeader

@synthesize data = _data;


#pragma mark - Initialization
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"ReputationShopHeader"
                                      owner:self
                                    options:nil];
        [self addSubview:self.view];
    }
    return self;
}

#pragma mark - Tap Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass: [UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        
        switch (btn.tag) {
            case 10 : {
                AlertReputation *alertInfo = [AlertReputation newview];
                [alertInfo show];
                
                break;
            }
        }
    }
}

#pragma mark - Alert Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}


@end
