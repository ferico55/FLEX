//
//  LogoutViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "LogoutViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"
#import "ShopProductViewController.h"
#import "ShopTalkViewController.h"
#import "InboxMessageViewController.h"

@interface LogoutViewController ()
{

}

@end

@implementation LogoutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tap:(id)sender {
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 10:
        {
            // logout
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION object:nil userInfo:@{}];
            break;
        }
            
        case 11 : {
//            NSInteger index = indexpath.section+3*(indexpath.row);
//            
//            SearchResultViewController *vc = [SearchResultViewController new];
//            vc.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
//            SearchResultViewController *vc1 = [SearchResultViewController new];
//            vc1.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
//            SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
//            vc2.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
//            NSArray *viewcontrollers = @[vc,vc1,vc2];
//            
//            TKPDTabNavigationController *c = [TKPDTabNavigationController new];
//            [c setData:@{kTKPDCATEGORY_DATATYPEKEY: @(kTKPDCATEGORY_DATATYPECATEGORYKEY), kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"", }];
//            [c setSelectedIndex:0];
//            [c setViewControllers:viewcontrollers];
//            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
//            [nav.navigationBar setTranslucent:NO];
//            [self.navigationController presentViewController:nav animated:YES completion:nil];
            
            InboxMessageViewController *vc = [InboxMessageViewController new];
            vc.data=@{@"nav":@"inbox-message"};
            
            InboxMessageViewController *vc1 = [InboxMessageViewController new];
            vc1.data=@{@"nav":@"inbox-message-sent"};
            
            InboxMessageViewController *vc2 = [InboxMessageViewController new];
            vc2.data=@{@"nav":@"inbox-message-archive"};
            
            InboxMessageViewController *vc3 = [InboxMessageViewController new];
            vc3.data=@{@"nav":@"inbox-message-trash"};
            NSArray *vcs = @[vc,vc1, vc2, vc3];

            TKPDTabInboxMessageNavigationController *nc = [TKPDTabInboxMessageNavigationController new];
            [nc setSelectedIndex:2];
            [nc setViewControllers:vcs];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:nc];
            [nav.navigationBar setTranslucent:NO];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
