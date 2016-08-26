//
//  ResolutionCenterCreateStepThreeViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateStepThreeViewController.h"
#import "Tokopedia-Swift.h"
#import "ResolutionCenterChooseSolutionViewController.h"
#import "RequestResolutionData.h"
#import "ResolutionCenterCreatePOSTResponse.h"
#import "RequestResolutionAction.h"

@interface ResolutionCenterCreateStepThreeViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ResolutionCenterChooseSolutionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *solutionCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *refundCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *photoCell;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *uploadButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cancelButtons;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewUploadPhoto;
@property (strong, nonatomic) NSArray<ResolutionCenterCreatePOSTFormSolution*>* formSolutions;
@property (strong, nonatomic) ResolutionCenterCreatePOSTFormSolution *selectedSolution;
@property (strong, nonatomic) IBOutlet UITextField *refundTextField;
@property (strong, nonatomic) IBOutlet UILabel *maxRefundLabel;
@end

@implementation ResolutionCenterCreateStepThreeViewController{
    NSMutableArray <DKAsset *>*_selectedImages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _cancelButtons = [NSArray sortViewsWithTagInArray:_cancelButtons];
    _uploadButtons = [NSArray sortViewsWithTagInArray:_uploadButtons];
    _selectedImages = [NSMutableArray new];
    
    for(UIButton *btn in _cancelButtons) {
        btn.hidden = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [RequestResolutionData fetchPossibleSolutionWithPossibleTroubleObject:_result.postObject
                                                                    success:^(ResolutionCenterCreatePOSTResponse* data) {
                                                                        _formSolutions = data.data.form_solution;
                                                                    } failure:^(NSError *error) {
                                                                        
                                                                    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return _solutionCell;
        }else{
            return _refundCell;
        }
    }else{
        return _photoCell;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 2;
    }else{
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return _solutionCell.frame.size.height;
        }else{
            if(_selectedSolution && [_selectedSolution.show_refund_box isEqualToString:@"1"]){
                return 120;
            }else{
                return 0;
            }
        }
    }else{
        return _photoCell.frame.size.height;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = nil;
    if(section == 0){
        header = [[UIView alloc]initWithFrame:CGRectMake(16, 28, 320, 40)];
        header.backgroundColor = [UIColor clearColor];
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:header.frame];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = @"Masalah pada barang yang Anda terima";
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.font = [UIFont fontWithName:@"Gotham Book" size:12.0];
        [lbl setNumberOfLines:0];
        [lbl sizeToFit];
        [header addSubview:lbl];
    }
    return header;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        ResolutionCenterChooseSolutionViewController *vc = [ResolutionCenterChooseSolutionViewController new];
        vc.formSolutions = _formSolutions;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 50;
    }
    return 0;
}

#pragma mark - Methods
- (IBAction)uploadButtonTapped:(id)sender {
    [self navigateToPhotoPicker];
}

-(void)navigateToPhotoPicker{
    __weak typeof(self) wself = self;
    [ImagePickerController showImagePicker:self
                                 assetType:DKImagePickerControllerAssetTypeallPhotos
                       allowMultipleSelect:YES
                                showCancel:YES
                                showCamera:YES
                               maxSelected:5
                            selectedAssets:_selectedImages completion:^(NSArray<DKAsset *> * images) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (wself != nil) {
                                        typeof(self) sself = wself;
                                        [sself->_selectedImages removeAllObjects];
                                        [sself->_selectedImages addObjectsFromArray:images];
                                        [sself setSelectedImages];
                                    }
                                });
                            }];
}

-(void)setSelectedImages{
    for (UIButton *button in _uploadButtons) {
        button.hidden = YES;
        [button setBackgroundImage:[UIImage imageNamed:@"icon_upload_image.png"] forState:UIControlStateNormal];
    }
    for (UIButton *button in _cancelButtons) { button.hidden = YES; }
    for (int i = 0; i<_selectedImages.count; i++) {
        ((UIButton*)_uploadButtons[i]).hidden = NO;
        ((UIButton*)_cancelButtons[i]).hidden = NO;
        [_uploadButtons[i] setBackgroundImage:_selectedImages[i].thumbnailImage forState:UIControlStateNormal];
    }
    if (_selectedImages.count<_uploadButtons.count) {
        UIButton *uploadedButton = (UIButton*)_uploadButtons[_selectedImages.count];
        uploadedButton.hidden = NO;
        _scrollViewUploadPhoto.contentSize = CGSizeMake(uploadedButton.frame.origin.x+uploadedButton.frame.size.width*_selectedImages.count, 0);
    }
}
- (IBAction)cancelButtonTapped:(id)sender {
    UIButton* button = (UIButton*)sender;
    [_selectedImages removeObjectAtIndex:button.tag];
    [self setSelectedImages];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - Choose Solution Delegate
-(void)didSelectSolution:(ResolutionCenterCreatePOSTFormSolution *)selectedSolution{
    _selectedSolution = selectedSolution;
    _maxRefundLabel.text = _selectedSolution.max_refund_idr;
    [_tableView reloadData];
}

#pragma mark - Submit Create Resolution
-(void)submitCreateResolution{
    
    [RequestResolutionAction fetchCreateNewResolutionOrderID:_result.postObject.order_id
                                                flagReceived:(_product_is_received)?@"1":@"0"
                                                   troubleId:@"1"
                                                    solution:_selectedSolution.solution_id
                                                refundAmount:_refundTextField.text
                                                      remark:@"asdasd"
                                           categoryTroubleId:_result.postObject.category_trouble_id
                                       possibleTroubleObject:_result.postObject
                                                imageObjects:_selectedImages
                                                     success:^(ResolutionActionResult *data) {
                                                         
                                                     } failure:^(NSError *error) {
                                                         
                                                     }];
}
@end
