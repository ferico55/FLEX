//
//  ResolutionCenterCreateStepOneViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateStepOneViewController.h"
#import "ResolutionCenterCreateStepOneCell.h"
#import "RequestResolutionData.h"
#import "ResolutionCenterCreateData.h"
#import "ResolutionCenterChooseProblemViewController.h"
#import "ResolutionProductData.h"
#import "Tokopedia-Swift.h"

@interface ResolutionCenterCreateStepOneViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UIScrollViewDelegate,
ResolutionCenterChooseProblemDelegate
>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemCell;
@property (weak, nonatomic) IBOutlet UILabel *problemLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSArray<ProductTrouble*>* listProducts;
@end

@implementation ResolutionCenterCreateStepOneViewController{
    BOOL _shouldShowProblematicProduct;
    ResolutionCenterChooseProblemViewController *_problemViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsMultipleSelection = YES;
    [_problemLabel setHidden:YES];
    [_activityIndicator startAnimating];
    
    [self fetchForm];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Resolution Center Create Problem Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table View Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return _problemCell;
    }else{
        //cell untuk product
        ProductTrouble* currentProduct = [_listProducts objectAtIndex:indexPath.row];
        
        ResolutionCenterCreateStepOneCell *cell = nil;
        NSString *cellid = @"ResolutionCenterCreateStepOneCell";
        cell = (ResolutionCenterCreateStepOneCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if(cell == nil){
            cell = [ResolutionCenterCreateStepOneCell newcell];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.productName.text = currentProduct.pt_product_name;
        
        if([currentProduct.pt_free_return isEqualToString:@"3"]) {
            cell.badgeProsecure.hidden = false;
            cell.labelProsecure.hidden = false;
        } else {
            cell.badgeProsecure.hidden = true;
            cell.labelProsecure.hidden = true;
        }
        
        cell.productImage.contentMode = UIViewContentModeScaleToFill;
        [cell.productImage setImageWithURL:[NSURL URLWithString:currentProduct.pt_primary_photo]];
        return cell;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else{
        return _shouldShowProblematicProduct?_listProducts.count:0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return _problemCell.frame.size.height;
    }else{
        return _shouldShowProblematicProduct?70:0;
    }
}

- (UIViewController *)problemViewController {
    if (_problemViewController == nil) {
        _problemViewController = [ResolutionCenterChooseProblemViewController new];
        _problemViewController.delegate = self;
        _problemViewController.list_ts = _result.formData.list_ts;
    }
    
    return _problemViewController;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && _result.formData){
        [self.navigationController pushViewController:[self problemViewController] animated:YES];
    }else if(indexPath.section == 1){
        ProductTrouble *selectedProduct = [_listProducts objectAtIndex:indexPath.row];
        [_result.selectedProduct addObject:selectedProduct];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        [_result.selectedProduct removeObject:[_listProducts objectAtIndex:indexPath.row]];
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = nil;
    header = [[UIView alloc]initWithFrame:CGRectMake(16, 28, 320, 40)];
    header.backgroundColor = [UIColor clearColor];
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:header.frame];
    lbl.backgroundColor = [UIColor clearColor];
    if(section == 0){
        lbl.text = @"MASALAH PADA BARANG YANG ANDA TERIMA";
    }else{
        if(_shouldShowProblematicProduct){
            lbl.text = @"PILIH DAN ISI DATA PRODUK YANG BERMASALAH";
        }
    }
    lbl.textAlignment = NSTextAlignmentLeft;
    lbl.font = [UIFont systemFontOfSize:12.0];
    [lbl setNumberOfLines:0];
    [lbl sizeToFit];
    [header addSubview:lbl];
    
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 50;
    }else if(section == 1 && _shouldShowProblematicProduct){
        return 50;
    }
    return 0;
}

#pragma mark - Choose Problem Delegate
-(void)didSelectProblem:(ResolutionCenterCreateList *)selectedProblem{
    _result.postObject.category_trouble_id = selectedProblem.category_trouble_id;
    if([selectedProblem.product_related isEqualToString:@"1"]){
        _shouldShowProblematicProduct = YES;
        _result.troubleId = nil;
        [_result.selectedProduct removeAllObjects];
        _problemLabel.text = selectedProblem.category_trouble_text?:@"";
        [_tableView reloadData];
    }else{
        _shouldShowProblematicProduct = NO;
        [_result.selectedProduct removeAllObjects];
        _problemLabel.text = selectedProblem.category_trouble_text?:@"";
        [_tableView reloadData];
    }
}

#pragma mark - Methods
-(void)fetchForm{
    [RequestResolutionData fetchCreateResolutionDataWithOrderId:_order.order_detail.detail_order_id
                                                        success:^(ResolutionCenterCreateResponse *data) {
                                                            _result.formData = data.data;
                                                            
                                                            NSArray* appropriateCategoryTrouble = [NSMutableArray new];
                                                            NSString* boolStr = _product_is_received?@"1":@"0";
                                                            appropriateCategoryTrouble = [_result.formData.list_ts bk_select:^(ResolutionCenterCreateList* obj) {
                                                                return [obj.product_is_received isEqualToString:boolStr];
                                                            }];
                                                            
                                                            _result.formData.list_ts = appropriateCategoryTrouble;
                                                            [self fetchProduct];

                                                            [_problemLabel setHidden:NO];
                                                            [_activityIndicator setHidden:YES];
                                                        } failure:^(NSError *error) {
                                                            [_problemLabel setHidden:NO];
                                                            [_activityIndicator setHidden:YES];
                                                        }];
}
-(void)fetchProduct{
    [RequestResolutionData fetchAllProductsInTransactionWithOrderId:_result.formData.form.order_id?:@""
                                                            success:^(NSArray <ProductTrouble*> *list) {
                                                                _listProducts = list;
                                                                
                                                                [_tableView reloadData];
                                                            } failure:^(NSError *error) {
                                                                [StickyAlertView showErrorMessage:@[@"Kendala koneksi internet"]];
                                                            }];
}
@end
