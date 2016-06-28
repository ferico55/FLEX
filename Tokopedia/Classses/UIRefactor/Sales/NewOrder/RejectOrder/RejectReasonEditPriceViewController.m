//
//  RejectReasonEditPriceViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonEditPriceViewController.h"
#import "AlertPickerView.h"
#import "string_product.h"
#define CURRENCY_PICKER 11
#define WEIGHT_PICKER 12

@interface RejectReasonEditPriceViewController ()<UITableViewDelegate, UITableViewDataSource, TKPDAlertViewDelegate>

@property (strong, nonatomic) NSString *priceKey;
@property (strong, nonatomic) NSString *weightKey;

@property (strong, nonatomic) IBOutlet UITextField *priceTextField;
@property (strong, nonatomic) IBOutlet UITextField *weightTextField;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UIButton *emptyStockButton;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *productInfoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *priceInfoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *priceInputCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *weightInfoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *weightInputCell;

@end

@implementation RejectReasonEditPriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _priceTextField.text = _orderProduct.product_price;
    _weightTextField.text = _orderProduct.product_weight;
    
    if(_orderProduct.emptyStock){
        [_emptyStockButton setBackgroundColor:[UIColor colorWithRed:0.699 green:0.699 blue:0.699 alpha:1]];
        [_emptyStockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [_emptyStockButton setBackgroundColor:[UIColor whiteColor]];
        [_emptyStockButton setTitleColor:[UIColor colorWithRed:0.699 green:0.699 blue:0.699 alpha:1] forState:UIControlStateNormal];
    }
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_orderProduct.product_picture] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_productImage setContentMode:UIViewContentModeScaleAspectFill];
    [_productImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.productImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.productImage setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.productImage setImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View
#pragma mark - Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else{
        return 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return _productInfoCell;
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){
            return _priceInfoCell;
        }else{
            return _priceInputCell;
        }
    }else if(indexPath.section == 2){
        if(indexPath.row == 0){
            return _weightInfoCell;
        }else{
            return _weightInputCell;
        }
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 66;
    }else{
        return 44;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (IBAction)currencyButtonTapped:(id)sender {
    AlertPickerView *v = [AlertPickerView newview];
    v.pickerData = ARRAY_PRICE_CURRENCY;
    v.tag = CURRENCY_PICKER;
    v.delegate = self;
    [v show];
}

- (IBAction)weightButtonTapped:(id)sender {
    AlertPickerView *v = [AlertPickerView newview];
    v.pickerData = ARRAY_WEIGHT_UNIT;
    v.tag = WEIGHT_PICKER;
    v.delegate = self;
    [v show];
}

- (IBAction)emptyStockButtonTapped:(id)sender {
    if(!_orderProduct.emptyStock){
        [_emptyStockButton setBackgroundColor:[UIColor colorWithRed:0.699 green:0.699 blue:0.699 alpha:1]];
        [_emptyStockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _orderProduct.emptyStock = YES;
    }else{
        [_emptyStockButton setBackgroundColor:[UIColor whiteColor]];
        [_emptyStockButton setTitleColor:[UIColor colorWithRed:0.699 green:0.699 blue:0.699 alpha:1] forState:UIControlStateNormal];
        _orderProduct.emptyStock = NO;
    }
}

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == CURRENCY_PICKER){
        NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
        _priceKey = [ARRAY_PRICE_CURRENCY[index] objectForKey:DATA_VALUE_KEY];
        NSString *name = [ARRAY_PRICE_CURRENCY[index] objectForKey:DATA_NAME_KEY];
        
    }else if(alertView.tag == WEIGHT_PICKER){
        NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
        _weightKey = [ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_VALUE_KEY];
        NSString *name = [ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_NAME_KEY];
    }
}

@end
