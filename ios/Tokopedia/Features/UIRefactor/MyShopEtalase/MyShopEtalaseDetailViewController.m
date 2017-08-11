//
//  MyShopEtalaseDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "EtalaseList.h"
#import "MyShopEtalaseDetailViewController.h"
#import "MyShopEtalaseEditViewController.h"

#pragma mark - Setting Etalase Detail View Controller
@interface MyShopEtalaseDetailViewController () <MyShopEtalaseEditViewControllerDelegate>
{
    EtalaseList *_etalase;
}

@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UILabel *labeltotal;

- (IBAction)tap:(id)sender;

@end

@implementation MyShopEtalaseDetailViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _etalase = [_data objectForKey:DATA_ETALASE_KEY];
    self.title = _etalase.etalase_name;
    [self setDefaultData:_data];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:nil];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Ubah"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:(self)
                                                                     action:@selector(tap:)];
    editBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = editBarButton;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 11:
            {
                //Edit
                NSIndexPath *indexpath = [_data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                MyShopEtalaseEditViewController *vc = [MyShopEtalaseEditViewController new];
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                vc.delegate = self;
                vc.data = @{
                            DATA_ETALASE_KEY : [_data objectForKey:DATA_ETALASE_KEY]?:[NSNull null],
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                            kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY),
                            kTKPDDETAIL_DATAINDEXPATHKEY : indexpath
                            };

                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 11:
            {
                //delete etalase
                if ([_etalase.etalase_total_product isEqualToString:@"0"]) {
                    [_delegate DidTapButton:btn withdata:_data];
                    [self.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRemoveEtalase" object:nil];
                } else {
                    NSArray *errorMessages = @[@"Anda tidak dapat menghapus etalase.\nSilahkan pindahkan produk ke etalase lain terlebih dahulu."];

                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                }
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        _labelname.text = _etalase.etalase_name;
        _labeltotal.text = _etalase.etalase_total_product;
    }
}

#pragma mark - Etalase edit delegate

- (void)successEditEtalase:(NSString *)etalaseName
{
    self.labelname.text = etalaseName;
    
    EtalaseList *tempEtalase = [_data objectForKey:DATA_ETALASE_KEY];
    if(tempEtalase != nil) {
        tempEtalase.etalase_name = self.labelname.text;
    }
}

@end
