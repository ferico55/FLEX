//
//  RejectReasonCloseShopViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonCloseShopViewController.h"
#import "TKPDTextView.h"
#import "AlertDatePickerView.h"
#import "RejectReasonEmptyStockCell.h"
#import <BlocksKit/BlocksKit.h>
#import "NSArray+BlocksKit.h"

@interface RejectReasonCloseShopViewController ()<TKPDAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) IBOutlet UIButton *startDateButton;
@property (strong, nonatomic) IBOutlet UIButton *endDateButton;
@property (strong, nonatomic) IBOutlet TKPDTextView *textView;

@property (strong, nonatomic) IBOutlet UITableViewCell *closeShopFormCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *showEmptyStockToggleCell;
@property (strong, nonatomic) IBOutlet UISwitch *emptyStockSwitch;

@end

@implementation RejectReasonCloseShopViewController{
    NSDate* _startDate;
    NSDate* _endDate;
    BOOL _showEmptyStockSection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _startDate = [NSDate date];
    
    [_emptyStockSwitch setOn:NO];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsMultipleSelection = YES;
    [_tableView reloadData];
    
    [_startDateButton setTitle:[self stringFromNSDate:_startDate] forState:UIControlStateNormal];
    [_startDateButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)emptyStockSwitchValueChanged:(id)sender {
    if([_emptyStockSwitch isOn]){
        _showEmptyStockSection = YES;
    }else{
        _showEmptyStockSection = NO;
    }
    //TODO: reset empty stock state
    [_tableView reloadData];
}

#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (_showEmptyStockSection)? 3 : 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return 1;
    }else if(section == 2){
        return [_order.order_products count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        _closeShopFormCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return _closeShopFormCell;
    }else if(indexPath.section == 1){
        _showEmptyStockToggleCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return _showEmptyStockToggleCell;
    }else{
        static NSString *cellIdentifer = @"RejectReasonEmptyStockCell";
        
        RejectReasonEmptyStockCell *cell = (RejectReasonEmptyStockCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifer
                                                                     owner:self
                                                                   options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setSelected:NO animated:NO];
        OrderProduct *currentProduct = [_order.order_products objectAtIndex:indexPath.row];
        [cell setViewModel:currentProduct.viewModel];
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return _closeShopFormCell.frame.size.height;
    }else if(indexPath.section == 1){
        return 44;
    }else if (indexPath.section == 2){
        return 68;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view;
    if(section == 0){
        NSString *sectionTitle = @"Tutup Toko Sekarang";
        
        // Create label with section title
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(8, 0, 280, 40);
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@"GothamMedium" size:14];
        label.text = sectionTitle;
        label.backgroundColor = [UIColor clearColor];
        
        // Create header view and add label as a subview
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.window.frame.size.width, 40)];
        [view addSubview:label];
    }
    
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 40;
    }else{
        return 8;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderProduct *selected = [_order.order_products objectAtIndex:indexPath.row];
    selected.emptyStock = !selected.emptyStock;
}

#pragma mark - Button
- (IBAction)startDateButtonTapped:(id)sender {
}

- (IBAction)endDateButtonTapped:(id)sender {
    AlertDatePickerView *datePicker = [AlertDatePickerView newview];
    datePicker.data = @{kTKPDALERTVIEW_DATATYPEKEY:@(kTKPDALERT_DATAALERTTYPECLOSESHOPKEY)};
    datePicker.delegate = self;
    datePicker.isSetMinimumDate = YES;
    datePicker.startDate = [self addDays:1 toNSDate:_startDate];
    [datePicker show];
}

- (IBAction)confirmButtonTapped:(id)sender {
    
}

-(void)setDateButton{
    if(_startDate){
        [_startDateButton setTitle:[self stringFromNSDate:_startDate]
                          forState:UIControlStateNormal];
    }else{
        [_startDateButton setTitle:@"Pilih Tanggal"
                          forState:UIControlStateNormal];
    }
    if(_endDate){
        [_endDateButton setTitle:[self stringFromNSDate:_endDate]
                             forState:UIControlStateNormal];
    }else{
        [_endDateButton setTitle:@"Pilih Tanggal"
                             forState:UIControlStateNormal];
    }
}



#pragma mark - Date Picker Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDate *date = [alertView.data objectForKey:@"datepicker"];
    _endDate = date;
    [self setDateButton];
}

-(NSString*)stringFromNSDate:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/YYYY"];
    return [formatter stringFromDate:date];
}

-(NSDate*)NSDatefromString:(NSString*)date{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    }
    return [dateFormatter dateFromString:date];
}

-(NSDate*)addDays:(NSInteger)days toNSDate:(NSDate*)date{
    return [date dateByAddingTimeInterval:60*60*24*days];
}

#pragma mark - Scroll View Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self resignFirstResponder];
}

@end
