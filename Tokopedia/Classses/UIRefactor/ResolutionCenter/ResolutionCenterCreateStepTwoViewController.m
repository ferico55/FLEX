//
//  ResolutionCenterCreateStepTwoViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateStepTwoViewController.h"
#import "ResolutionCenterCreateStepTwoCell.h"
#import "DownPicker.h"
#import <BlocksKit/BlocksKit.h>

@interface ResolutionCenterCreateStepTwoViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UIScrollViewDelegate
>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ResolutionCenterCreateStepTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsSelection = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_shouldFlushOptions){
        [self copyProductToJSONObject];
    }
}

-(void)copyProductToJSONObject{
    [_result.postObject.product_list removeAllObjects];
    [_result.selectedProduct enumerateObjectsUsingBlock:^(ResolutionProductList * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ResolutionCenterCreatePOSTProduct* postProduct = [ResolutionCenterCreatePOSTProduct new];
        postProduct.order_dtl_id = obj.order_dtl_id;
        postProduct.product_id = obj.product_id;
        postProduct.quantity = obj.quantity;
        postProduct.trouble_id = nil;
        [_result.postObject.product_list addObject:postProduct];
    }];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //cell untuk product
    ResolutionProductList* currentProduct = [_result.selectedProduct objectAtIndex:indexPath.row];
    ResolutionCenterCreatePOSTProduct *postProduct = [_result.postObject.product_list objectAtIndex:indexPath.row];
    
    ResolutionCenterCreateStepTwoCell *cell = nil;
    NSString *cellid = @"ResolutionCenterCreateStepTwoCell";
    cell = (ResolutionCenterCreateStepTwoCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if(cell == nil){
        cell = [ResolutionCenterCreateStepTwoCell newcell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.productName setTitle:currentProduct.product_name forState:UIControlStateNormal];
    [cell.productImage setImageWithURL:[NSURL URLWithString:currentProduct.primary_photo]];
    cell.quantityLabel.text = postProduct.quantity;
    cell.quantityStepper.value = [postProduct.quantity integerValue];
    cell.quantityStepper.stepValue = 1.0f;
    cell.quantityStepper.minimumValue = 0;
    cell.quantityStepper.maximumValue = [postProduct.quantity integerValue];
    
    cell.troublePicker  = [[DownPicker alloc] initWithTextField:cell.troublePicker withData:[self generateDownPickerChoices]];
    cell.troublePicker.tag = indexPath.row;
    [cell.troublePicker addTarget:self action:@selector(troublePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

-(NSMutableArray*)generateDownPickerChoices{
    return [_result generatePossibleTroubleTextListWithCategoryTroubleId:_result.postObject.category_trouble_id];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _result.selectedProduct.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 280;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - Method
-(void)troublePickerValueChanged:(id)picker{
    DownPicker* downPicker = (DownPicker*)picker;
    ResolutionCenterCreatePOSTProduct *postProduct = [_result.postObject.product_list objectAtIndex:downPicker.tag];
    NSMutableArray* possibleTroubles = [_result generatePossibleTroubleListWithCategoryTroubleId:_result.postObject.category_trouble_id];
    ResolutionCenterCreateTroubleList *selectedTrouble = [possibleTroubles objectAtIndex:[downPicker selectedIndex]];
    
    postProduct.trouble_id = selectedTrouble.trouble_id;
}
@end
