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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //cell untuk product
    ResolutionProductList* currentProduct = [_result.selectedProduct objectAtIndex:indexPath.row];
    
    ResolutionCenterCreateStepTwoCell *cell = nil;
    NSString *cellid = @"ResolutionCenterCreateStepTwoCell";
    cell = (ResolutionCenterCreateStepTwoCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if(cell == nil){
        cell = [ResolutionCenterCreateStepTwoCell newcell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.productName setTitle:currentProduct.product_name forState:UIControlStateNormal];
    [cell.productImage setImageWithURL:[NSURL URLWithString:currentProduct.primary_photo]];
    cell.quantityLabel.text = currentProduct.quantity;
    cell.quantityStepper.value = [currentProduct.quantity integerValue];
    cell.quantityStepper.stepValue = 1.0f;
    cell.quantityStepper.minimumValue = 0;
    cell.quantityStepper.maximumValue = [currentProduct.quantity integerValue];
    
    
    cell.troublePicker  = [[DownPicker alloc] initWithTextField:cell.troublePicker withData:nil];
    return cell;
}

-(NSMutableArray*)generateDownPickerChoices{
    return nil;
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

@end
