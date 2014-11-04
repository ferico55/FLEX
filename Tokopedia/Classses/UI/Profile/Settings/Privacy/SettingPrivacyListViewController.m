//
//  SettingPrivacyListViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "SettingPrivacyListViewController.h"

#pragma mark - Setting Privacy List View Controller
@interface SettingPrivacyListViewController ()
{
    NSInteger _index;
}

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumb;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
- (IBAction)tap:(id)sender;

@end

@implementation SettingPrivacyListViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *title = [_data objectForKey:kTKPDPROFILESETTING_DATAPRIVACYTITILEKEY];
    self.title = title;
    
    _thumb = [NSArray sortViewsWithTagInArray:_thumb];
    _buttons = [NSArray sortViewsWithTagInArray:_buttons];
    
    for (UIImageView *img in _thumb) {
        img.hidden = YES;
    }
    
    UIBarButtonItem *barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor blackColor]];
    barbutton1.tag = 11;
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    _index = [[_data objectForKey:kTKPDPROFILESETTING_DATAPRIVACYKEY] boolValue];
    ((UIImageView*)_thumb[_index]).hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        for (UIImageView *img in _thumb) {
            img.hidden = YES;
        }
        ((UIImageView*)_thumb[btn.tag-10]).hidden = NO;
        _index = btn.tag - 10;
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 11:
            {
                [_delegate SettingPrivacyListType:[[_data objectForKey:kTKPDPROFILESETTING_DATAPRIVACYTYPEKEY] integerValue] withIndex:_index];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
    }
}

@end
