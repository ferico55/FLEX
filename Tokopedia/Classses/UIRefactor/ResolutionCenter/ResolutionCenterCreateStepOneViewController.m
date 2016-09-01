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
@property (strong, nonatomic) IBOutlet UIButton *problemButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) ResolutionProductData* productData;
@end

@implementation ResolutionCenterCreateStepOneViewController{
    BOOL _shouldShowProblematicProduct;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsMultipleSelection = YES;
    [_problemButton setHidden:YES];
    [_activityIndicator startAnimating];
    
    [self fetchForm];
    [self fetchProduct];
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
        ResolutionProductList* currentProduct = [_productData.list objectAtIndex:indexPath.row];
        
        ResolutionCenterCreateStepOneCell *cell = nil;
        NSString *cellid = @"ResolutionCenterCreateStepOneCell";
        cell = (ResolutionCenterCreateStepOneCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if(cell == nil){
            cell = [ResolutionCenterCreateStepOneCell newcell];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.productName.text = currentProduct.product_name;
        cell.productImage.contentMode = UIViewContentModeScaleToFill;
        [cell.productImage setImageWithURL:[NSURL URLWithString:currentProduct.primary_photo]];
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
        return _shouldShowProblematicProduct?_productData.list.count:0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return _problemCell.frame.size.height;
    }else{
        return _shouldShowProblematicProduct?70:0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && _result.formData){
        ResolutionCenterChooseProblemViewController *vc = [ResolutionCenterChooseProblemViewController new];
        vc.delegate = self;
        vc.list_ts = _result.formData.list_ts;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.section == 1){
        ResolutionProductList *selectedProduct = [_productData.list objectAtIndex:indexPath.row];
        [_result.selectedProduct addObject:selectedProduct];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        [_result.selectedProduct removeObject:[_productData.list objectAtIndex:indexPath.row]];
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = nil;
    header = [[UIView alloc]initWithFrame:CGRectMake(16, 28, 320, 40)];
    header.backgroundColor = [UIColor clearColor];
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:header.frame];
    lbl.backgroundColor = [UIColor clearColor];
    if(section == 0){
        lbl.text = @"Masalah pada barang yang Anda terima";
    }else{
        if(_shouldShowProblematicProduct){
            lbl.text = @"Pilih dan isi data produk yang bermasalah";
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
        [_problemButton setTitle:selectedProblem.category_trouble_text forState:UIControlStateNormal];
        [_tableView reloadData];
    }else{
        _shouldShowProblematicProduct = NO;
        [_result.selectedProduct removeAllObjects];
        [_problemButton setTitle:selectedProblem.category_trouble_text forState:UIControlStateNormal];
        [_tableView reloadData];
    }
}

#pragma mark - Methods
-(void)fetchForm{
    if (_type == TypeResoCreate) {
        [self fetchFormCreate];
    } else {
        [self fetchFormEdit];
    }
}

-(void)fetchFormEdit{
    [RequestResolutionData fetchformEditResolutionID:_resolutionID
                                        isGetProduct:_isGotOrder
                                           onSuccess:^(EditResolutionFormData *data) {
        
    } onFailure:^(NSError *error) {
        
    }];
}

-(void)fetchFormCreate{
    [RequestResolutionData fetchCreateResolutionDataWithOrderId:_order.order_detail.detail_order_id
                                                        success:^(ResolutionCenterCreateResponse *data) {
                                                            _result.formData = data.data;
                                                            
                                                            NSArray* appropriateCategoryTrouble = [NSMutableArray new];
                                                            NSString* boolStr = _product_is_received?@"1":@"0";
                                                            appropriateCategoryTrouble = [_result.formData.list_ts bk_select:^(ResolutionCenterCreateList* obj) {
                                                                return [obj.product_is_received isEqualToString:boolStr];
                                                            }];
                                                            
                                                            _result.formData.list_ts = appropriateCategoryTrouble;
                                                            
                                                            [_problemButton setHidden:NO];
                                                            [_activityIndicator setHidden:YES];
                                                        } failure:^(NSError *error) {
                                                            
                                                        }];
}
-(void)fetchProduct{
    [RequestResolutionData fetchAllProductsInTransactionWithOrderId:_order.order_detail.detail_order_id
                                                            success:^(ResolutionProductResponse *data) {
                                                                _productData = data.data;
                                                                [_tableView reloadData];
                                                            } failure:^(NSError *error) {
                                                                [StickyAlertView showErrorMessage:@[@"Kendala koneksi internet"]];
                                                            }];
}
@end
