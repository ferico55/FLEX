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
    [_problemLabel setHidden:YES];
    [_activityIndicator startAnimating];
    
    [self fetchForm];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        ResolutionProductList* currentProduct = [_productData.list objectAtIndex:indexPath.row];

        for (ProductTrouble *trouble in _result.formEdit.resolution_last.last_product_trouble) {
            if ([currentProduct.product_id integerValue] == [trouble.pt_product_id integerValue] && ![_result.selectedProduct containsObject:currentProduct]) {
                currentProduct.productTrouble = trouble;
                [self adjustSelectedProduct:currentProduct formProductTrouble:trouble];
                [_result.selectedProduct addObject:currentProduct];
                [cell setSelected:YES animated:NO];
            }
        }
    }
}

-(void)adjustSelectedProduct:(ResolutionProductList*)selectedProduct formProductTrouble:(ProductTrouble*)productTrouble{
    selectedProduct.show_input_quantity = productTrouble.pt_show_input_quantity;
    selectedProduct.trouble_id = productTrouble.pt_trouble_id;
    selectedProduct.solution_remark = productTrouble.pt_solution_remark;
    selectedProduct.trouble_name = productTrouble.pt_trouble_name;
}

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
                                               ResolutionCenterCreateData *form = [ResolutionCenterCreateData new];
                                               _result.formData = form;
                                               _result.formData.list_ts = data.list_ts;
                                               _result.formEdit = data.form;
                                               _result.formData.form = data.form.resolution_order;
                                               for (ResolutionCenterCreateList *categoryProblemType in _result.formData.list_ts) {
                                                   if ([categoryProblemType.category_trouble_id integerValue] == [_result.formEdit.resolution_last.last_category_trouble_type integerValue]) {
                                                       [self didSelectProblem:categoryProblemType];
                                                   }
                                               }
                                               [self fetchProduct];

                                               [_problemLabel setHidden:NO];
                                               [_activityIndicator setHidden:YES];
        
    } onFailure:^(NSError *error) {
        [_problemLabel setHidden:NO];
        [_activityIndicator setHidden:YES];
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
                                                            success:^(ResolutionProductResponse *data) {
                                                                _productData = data.data;
                                                                
                                                                [_tableView reloadData];
                                                            } failure:^(NSError *error) {
                                                                [StickyAlertView showErrorMessage:@[@"Kendala koneksi internet"]];
                                                            }];
}
@end
