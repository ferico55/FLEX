//
//  DetailCatalogViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailCatalogViewController.h"

@interface DetailCatalogViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *continerscrollview;
@property (weak, nonatomic) IBOutlet UIScrollView *headerimagescrollview;
@property (weak, nonatomic) IBOutlet UIButton *imagebackbutton;

@end

@implementation DetailCatalogViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
