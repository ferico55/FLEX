//
//  DetailShopViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Shop.h"

#import "detail.h"
#import "DetailShopViewController.h"

@interface DetailShopViewController ()
{
    BOOL _isnodata;
    NSInteger _requestcount;
    __weak RKObjectManager *_objectmanager;
    NSTimer *_timer;
}
@property (weak, nonatomic) IBOutlet UILabel *namelabel;

@end

@implementation DetailShopViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _requestcount = 0;
        _isnodata = YES;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
