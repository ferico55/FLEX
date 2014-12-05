//
//  GeneralTalkCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralTalkCell.h"
#import "ProductTalkDetailViewController.h"
#import "ProfileBiodataViewController.h"
#import "ProfileFavoriteShopViewController.h"
#import "ProfileContactViewController.h"
#import "TKPDTabProfileNavigationController.h"

#import "TalkList.h"
#import "TKPDSecureStorage.h"

#import "DetailProductViewController.h"

#import "detail.h"

@implementation GeneralTalkCell

#pragma mark - Factory Methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralTalkCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        NSIndexPath* indexpath = _indexpath;
        switch (btn.tag) {
            case 10:
            {
                [_delegate GeneralTalkCell:self withindexpath:indexpath];
                break;
            }
                
            case 11 :
            {
                [_delegate unfollowTalk:self withindexpath:indexpath withButton:_unfollowButton];
                NSLog(@"Running this");
                break;
            }
                
            case 12 :
            {
                [_delegate reportTalk:self withindexpath:indexpath];
                break;
            }
                
            case 13 :
            {
                [_delegate deleteTalk:self withindexpath:indexpath];
                break;
            }
            //click user
            case 14 :
            {
                TalkList *list = [_delegate clickUserId:self withindexpath:indexpath];
                TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                NSDictionary* auth = [secureStorage keychainDictionary];
                auth = [auth mutableCopy];

                NSMutableArray *viewcontrollers = [NSMutableArray new];
    
                /** create new view controller **/
                ProfileBiodataViewController *v = [ProfileBiodataViewController new];
                [viewcontrollers addObject:v];
                
                ProfileFavoriteShopViewController *v1 = [ProfileFavoriteShopViewController new];
                v1.data = @{kTKPDFAVORITED_APIUSERIDKEY:@(list.talk_user_id),
                            kTKPDDETAIL_APISHOPIDKEY:list.talk_shop_id,
                            kTKPD_AUTHKEY:auth};
                [viewcontrollers addObject:v1];
                
                ProfileContactViewController *v2 = [ProfileContactViewController new];
                [viewcontrollers addObject:v2];

                TKPDTabProfileNavigationController *tapnavcon = [TKPDTabProfileNavigationController new];
                tapnavcon.data = @{kTKPDFAVORITED_APIUSERIDKEY:@(list.talk_user_id),
                                   kTKPD_AUTHKEY:auth};
                [tapnavcon setViewControllers:viewcontrollers animated:YES];
                [tapnavcon setSelectedIndex:0];
                
                UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
                
                [nav.navigationController pushViewController:tapnavcon animated:YES];
                break;
            }
                
            //click product
            case 15 :
            {
                NSString *productId = [_delegate clickProductId:self withindexpath:indexpath];
                UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
                
                DetailProductViewController *vc = [DetailProductViewController new];
                vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : productId};
                [nav.navigationController pushViewController:vc animated:YES];
                
                break;
            }
        
            default:
                break;
        }
    }
}



@end
