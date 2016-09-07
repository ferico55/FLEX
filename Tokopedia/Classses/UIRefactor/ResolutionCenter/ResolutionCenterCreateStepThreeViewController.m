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
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <OAStackView/OAStackView.h>
#import <Masonry/Masonry.h>


@interface ResolutionCenterCreateStepThreeViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ResolutionCenterChooseSolutionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *solutionCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *refundCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *photoCell;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *uploadButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cancelButtons;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewUploadPhoto;
@property (strong, nonatomic) NSArray<EditSolution*>* formSolutions;
@property (strong, nonatomic) EditSolution *selectedSolution;
@property (strong, nonatomic) IBOutlet UITextField *refundTextField;
@property (strong, nonatomic) IBOutlet UIButton *solutionButton;
@property (strong, nonatomic) IBOutlet OAStackView *photoStackView;
@property (strong, nonatomic) IBOutlet UILabel *maxRefundLabel;
@property (strong, nonatomic) IBOutlet UIButton *addImageButton;
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
    
    _photoStackView.alignment = OAStackViewAlignmentCenter;
    [_photoStackView addArrangedSubview:_addImageButton];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [RequestResolutionData fetchPossibleSolutionWithPossibleTroubleObject:_result.postObject
//                                                                troubleId:_result.troubleId
//                                                                    success:^(NSArray<EditSolution*>* list) {
//                                                                        _formSolutions = list;
//                                                                        
//                                                                    } failure:^(NSError *error) {
//                                                                        
//                                                                    }];
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
        lbl.font = [UIFont systemFontOfSize:12];
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
- (IBAction)uploadButtonTapped:(UIButton*)button {
    
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
//    for (UIButton *button in _uploadButtons) {
//        button.hidden = YES;
//        [button setBackgroundImage:[UIImage imageNamed:@"icon_upload_image.png"] forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(uploadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    for (UIButton *button in _cancelButtons) { button.hidden = YES; }
//    for (int i = 0; i<_selectedImages.count; i++) {
//        ((UIButton*)_uploadButtons[i]).hidden = NO;
//        ((UIButton*)_cancelButtons[i]).hidden = NO;
//        [_uploadButtons[i] setBackgroundImage:_selectedImages[i].thumbnailImage forState:UIControlStateNormal];
//        [_uploadButtons[i] removeTarget:self action:@selector(uploadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        
//    }
//    if (_selectedImages.count<_uploadButtons.count) {
//        UIButton *uploadedButton = (UIButton*)_uploadButtons[_selectedImages.count];
//        uploadedButton.hidden = NO;
//        
//        
//        _scrollViewUploadPhoto.contentSize = CGSizeMake(uploadedButton.frame.origin.x+uploadedButton.frame.size.width*_selectedImages.count, 0);
//    }
    
//    UIButton *lala = [UIButton buttonWithType:UIButtonTypeSystem];
//    lala.backgroundColor = [UIColor redColor];
//    lala.frame = CGRectMake(0, 0, 60, 60);
//    [lala mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(@30);
//        make.width.equalTo(@30);
//    }];
//    
//    [_photoStackView addArrangedSubview:lala];
    [_photoStackView removeAllSubviews];
    
    [_selectedImages bk_each:^(DKAsset *asset) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setBackgroundImage:asset.thumbnailImage forState:UIControlStateNormal];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@90);
            make.width.equalTo(@90);
        }];
        
        [_photoStackView addArrangedSubview:button];
    }];
    
    [_photoStackView addArrangedSubview:_addImageButton];
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
-(void)didSelectSolution:(EditSolution *)selectedSolution{
    _selectedSolution = selectedSolution;
    _maxRefundLabel.text = _selectedSolution.max_refund_idr;
    [_solutionButton setTitle:_selectedSolution.solution_text forState:UIControlStateNormal];
    [_tableView reloadData];
}

#pragma mark - Submit Create Resolution
-(void)submitCreateResolution{
    if(!_selectedSolution) {
        [StickyAlertView showErrorMessage:@[@"Mohon pilih solusi yang Anda inginkan terlebih dahulu"]];
    } else if(_selectedImages.count == 0) {
        [StickyAlertView showErrorMessage:@[@"Mohon lampirkan foto sebagai barang bukti"]];
    } else {
        [RequestResolutionAction fetchCreateNewResolutionOrderID:_result.postObject.order_id
                                                    flagReceived:(_product_is_received)?@"1":@"0"
                                                       troubleId:_result.troubleId?:@""
                                                        solution:_selectedSolution.solution_id
                                                    refundAmount:_refundTextField.text
                                                          remark:_result.remark?:@""
                                               categoryTroubleId:_result.postObject.category_trouble_id
                                           possibleTroubleObject:_result.postObject
                                                    imageObjects:_selectedImages
                                                         success:^(ResolutionActionResult *data) {
                                                             [_delegate didFinishCreateComplainInStepThree];
                                                         } failure:^(NSError *error) {

                                                         }];
        
        
    }
}
@end
