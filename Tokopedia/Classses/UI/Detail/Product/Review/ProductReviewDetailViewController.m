//
//  ProductReviewDetailViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 10/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductReviewDetailViewController.h"
#import "detail.h"
#import "StarsRateView.h"
#import "ReviewProductOwner.h"
#import "ReviewResponse.h"

@interface ProductReviewDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    BOOL _isnodata;
    NSMutableArray *_list;
}

@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UIView *responseView;

@property (weak, nonatomic) IBOutlet UILabel *productnamelabel;
@property (weak, nonatomic) IBOutlet UIImageView *productimage;

@property (weak, nonatomic) IBOutlet UILabel *reviewmessagelabel;
@property (weak, nonatomic) IBOutlet UILabel *usernamelabel;
@property (weak, nonatomic) IBOutlet UILabel *createtimelabel;
@property (weak, nonatomic) IBOutlet UIImageView *userimage;
@property (weak, nonatomic) IBOutlet UILabel *commentbutton;


@property (weak, nonatomic) IBOutlet UILabel *productownername;
@property (weak, nonatomic) IBOutlet UIImageView *productownerimage;
@property (weak, nonatomic) IBOutlet UILabel *responsecreatetime;
@property (weak, nonatomic) IBOutlet UILabel *responsemessage;

@property (weak, nonatomic) IBOutlet StarsRateView *qualityrate;
@property (weak, nonatomic) IBOutlet StarsRateView *speedrate;
@property (weak, nonatomic) IBOutlet StarsRateView *servicerate;
@property (weak, nonatomic) IBOutlet StarsRateView *accuracyrate;


@end

@implementation ProductReviewDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _list = [NSMutableArray new];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    [barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    [self setHeaderData:_data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    
    return cell;
}

-(void) setHeaderData:(NSDictionary*)data{
    _productnamelabel.text = [data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY];
    _reviewmessagelabel.text = [data objectForKey:kTKPDREVIEW_APIREVIEWMESSAGEKEY];
    _usernamelabel.text = [data objectForKey:kTKPDREVIEW_APIREVIEWUSERNAMEKEY];
    _createtimelabel.text = [data objectForKey:kTKPDREVIEW_APIREVIEWCREATETIMEKEY];
    
    _qualityrate.starscount = [[data objectForKey:kTKPDREVIEW_APIREVIEWRATEQUALITY] integerValue];
    _accuracyrate.starscount = [[data objectForKey:kTKPDREVIEW_APIREVIEWRATEACCURACYKEY] integerValue];
    _servicerate.starscount = [[data objectForKey:kTKPDREVIEW_APIREVIEWRATESERVICEKEY]integerValue];
    _speedrate.starscount = [[data objectForKey:kTKPDREVIEW_APIREVIEWRATESPEEDKEY]integerValue];
    
    
    ReviewResponse *response = [data objectForKey:kTKPDREVIEW_APIREVIEWRESPONSEKEY];
    
    NSURL * imageURL = [NSURL URLWithString:[data objectForKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY]];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage * image = [UIImage imageWithData:imageData];
    
    _productimage.image = image;
    NSURL * imageUserURL = [NSURL URLWithString:[data objectForKey:kTKPDREVIEW_APIREVIEWUSERIMAGEKEY]];
    NSData * imageUserData = [NSData dataWithContentsOfURL:imageUserURL];
    UIImage * imageUser = [UIImage imageWithData:imageUserData];
    _userimage.image = imageUser;
    
    _commentbutton.text = [response.response_message isEqualToString:@"0"] ? @"0 Comment" : @"1 Comment";

    if([response.response_message isEqualToString:@"0"]) {
        _responseView.hidden = YES;
    } else {
        ReviewProductOwner *po = [data objectForKey:kTKPDREVIEW_APIREVIEWPRODUCTOWNERKEY];
        _productownername.text = po.user_name;
        NSURL * imagePoUrl = [[NSURL alloc] initWithString:po.user_image];
        
        NSData * imagePoData = [NSData dataWithContentsOfURL:imagePoUrl];
        UIImage * imagePo = [UIImage imageWithData:imagePoData];
        _productownerimage.image = imagePo;
        
        _responsecreatetime.text = response.response_create_time;
        _responsemessage.text = response.response_message;
    }

}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

#pragma mark - View Action
-(IBAction)tap:(id)sender {
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 10:
            {
                
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
                
            default:
                break;
        }
    }
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
