//
//  CreateShopViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 4/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "AddShop.h"
#import "AddShopResult.h"
#import "camera.h"
#import "CreateShopCell.h"
#import "CreateShopViewController.h"
#import "MyShopShipmentTableViewController.h"
#import "RequestUploadImage.h"
#import "string_create_shop.h"
#import "TKPDPhotoPicker.h"

@implementation CustomTxtView
@synthesize createShopViewController;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        self.delegate = self;
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }

    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
        return;
    
    if([[self text] length] == 0)
        [[self viewWithTag:999] setAlpha:1];
    else
        [[self viewWithTag:999] setAlpha:0];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return [createShopViewController textViewShouldBeginEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return [createShopViewController textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if (_placeHolderLabel == nil )
        {
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, self.bounds.size.width - 16, 0)];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.textColor = [UIColor colorWithRed:200/255.0f green:200/255.0f blue:206/255.0f alpha:1.0f];
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            [self addSubview:_placeHolderLabel];
        }
        
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

@end


@implementation CustomHeaderFooterTable
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    id result = [super initWithReuseIdentifier:reuseIdentifier];
    if(result)
    {
    }
    
    return result;
}

- (void)initLbl:(UIFont *)font andColor:(UIColor *)color andFrame:(CGRect)rect isHeader:(BOOL)isHeader
{
    if(isHeader)
    {
        lblHeader = [[UILabel alloc] initWithFrame:rect];
        lblHeader.backgroundColor = [UIColor clearColor];
        lblHeader.textColor = color;
        lblHeader.numberOfLines = 0;
        lblHeader.font = font;
        [self.contentView addSubview:lblHeader];
    }
    else
    {
        lblFooter = [[UILabel alloc] initWithFrame:rect];
        lblFooter.backgroundColor = [UIColor clearColor];
        lblFooter.textColor = color;
        lblFooter.numberOfLines = 0;
        lblFooter.font = font;
        [self.contentView addSubview:lblFooter];
    }
}

- (void)initBtn:(UIFont *)font andColor:(UIColor *)color andFrame:(CGRect)rect
{
    btnCheckDomain = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCheckDomain.backgroundColor = CBackgroundBtnCheckDomain;
    btnCheckDomain.titleLabel.font = font;
    [btnCheckDomain setTitleColor:color forState:UIControlStateNormal];
    [self.contentView addSubview:btnCheckDomain];
}

- (void)setBtnFrame:(CGRect)rect
{
    btnCheckDomain.frame = rect;
}

- (void)setLblFrame:(CGRect)rect isHeader:(BOOL)isHeader
{
    if(isHeader)
        lblHeader.frame = rect;
    else
        lblFooter.frame = rect;
}

- (UILabel *)getLblHeader
{
    return lblHeader;
}

- (UILabel *)getLblFooter
{
    return lblFooter;
}

- (UIButton *)getBtnCheckDomain
{
    return btnCheckDomain;
}
@end










@interface CreateShopViewController ()<TKPDPhotoPickerDelegate>
@end

@implementation CreateShopViewController
{
    TKPDPhotoPicker *tkpdPicker;
    BOOL hasLoadViewWillAppear, isValidDomain, hasSetImgGambar;
    RKObjectManager *objectManager;
    TokopediaNetworkManager *tokopediaNetworkManager;
    NSDictionary *dictContentPhoto;
    MyShopShipmentTableViewController *controller;
    
    UIImageView *tempImage;
    UIActivityIndicatorView *loadViewCheckDomain;
    UIView *viewImgGambar;
    UIImageView *imgGambar, *imageCheckList;
    UITextField *txtDomain, *txtNamaToko, *activeTextField;
    CustomTxtView *txtSlogan, *txtDesc;
    UITextView *activeTextView;
    UILabel *lblCountSlogan, *lblCountDescripsi;
    UIBarButtonItem *btnLanjut;
}
@synthesize moreViewController;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    
    btnLanjut = [[UIBarButtonItem alloc] initWithTitle:CStringLanjut style:UIBarButtonItemStylePlain target:self action:@selector(lanjut:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardDidHideNotification object:nil];
    self.navigationItem.rightBarButtonItem = btnLanjut;
    self.hidesBottomBarWhenPushed = YES;
    [self enableLanjut:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [tokopediaNetworkManager requestCancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if(! hasLoadViewWillAppear)
    {
        hasLoadViewWillAppear = !hasLoadViewWillAppear;
        tblCreateShop.allowsSelection = NO;
        tblCreateShop.userInteractionEnabled = YES;
        [tblCreateShop addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard:)]];
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


#pragma mark - View
- (void)initNavigation
{
    // Add logo in navigation bar
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
}

- (void)enableLanjut:(BOOL)isEnable
{
    self.navigationItem.rightBarButtonItem.enabled = isEnable;
}


#pragma mark - Method
- (UIImage *)resizeImage:(UIImage *)chosenImage
{
    float actualHeight = chosenImage.size.height;
    float actualWidth = chosenImage.size.width;
    float imgRatio = actualWidth/actualHeight;
    float widthView = self.view.bounds.size.width;
    float heightView = widthView;
    float maxRatio = widthView/heightView;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = heightView / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = heightView;
        }
        else{
            imgRatio = widthView / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = widthView;
        }
    }
    
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [chosenImage drawInRect:rect];
    chosenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return chosenImage;
}

- (NSString *)getNamaDomain
{
    return txtDomain.text;
}

- (NSDictionary *)getDictContentPhoto
{
    return dictContentPhoto;
}

- (NSString *)getSlogan
{
    return txtSlogan.text==nil? @"":txtSlogan.text;
}

- (NSString *)getDesc
{
    return txtDesc.text==nil? @"":txtDesc.text;
}

- (NSString *)getNamaToko
{
    NSString *rawString = txtNamaToko.text;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    return [rawString stringByTrimmingCharactersInSet:whitespace];
}

- (void)checkValidation:(NSString *)strNamaToko withSlogan:(NSString *)strSlogan withDesc:(NSString *)strDesc
{
    if(isValidDomain)
    {
        if(strNamaToko == nil)
            strNamaToko = [self getNamaToko];
        if(strSlogan == nil)
            strSlogan = txtSlogan.text;
        if(strDesc == nil)
            strDesc = txtDesc.text;
        
        if(strNamaToko.length==0 || strSlogan.length==0 || strDesc.length==0)
            [self enableLanjut:NO];
        else
            [self enableLanjut:YES];
    }
    else
        [self enableLanjut:NO];
}

- (void)isCheckingDomain:(BOOL)isCheckingDomain
{
    CustomHeaderFooterTable *tempCustomHeaderFooterTable = ((CustomHeaderFooterTable *) [tblCreateShop footerViewForSection:0]);
    if(isCheckingDomain)
    {
        loadViewCheckDomain = [UIActivityIndicatorView new];
        loadViewCheckDomain.frame = CGRectMake((self.view.bounds.size.width-[tempCustomHeaderFooterTable getBtnCheckDomain].bounds.size.height)/2.0f, [tempCustomHeaderFooterTable getBtnCheckDomain].frame.origin.y, [tempCustomHeaderFooterTable getBtnCheckDomain].bounds.size.height, [tempCustomHeaderFooterTable getBtnCheckDomain].bounds.size.height);
        [loadViewCheckDomain startAnimating];
        loadViewCheckDomain.color = [UIColor lightGrayColor];
        
        //Add activity indicator
        [tempCustomHeaderFooterTable.contentView addSubview:loadViewCheckDomain];
        [tempCustomHeaderFooterTable getBtnCheckDomain].hidden = YES;
    }
    else
    {
        [loadViewCheckDomain stopAnimating];
        [loadViewCheckDomain removeFromSuperview];
        loadViewCheckDomain = nil;
        
        [tempCustomHeaderFooterTable getBtnCheckDomain].hidden = NO;
    }
}

- (TokopediaNetworkManager *)getNetworkManager
{
    if(tokopediaNetworkManager == nil)
    {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    
    return tokopediaNetworkManager;
}

- (void)resignKeyboard:(id)sender
{
    [activeTextField resignFirstResponder];
    activeTextField = nil;
    
    [activeTextView resignFirstResponder];
    activeTextView = nil;
}

- (void)showKeyboard:(id)sender
{
    CGSize keyboardSize = [[[sender userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    int height = MIN(keyboardSize.height,keyboardSize.width);
    
    BOOL scroll = NO;
    CGRect tblRect = tblCreateShop.frame;
    if(self.view.bounds.size.height-height != tblRect.size.height) {
        scroll = YES;
    }
    tblRect.size.height = self.view.bounds.size.height-height;
    tblCreateShop.frame = tblRect;
    

    if(scroll && activeTextView!=nil) {
        [tblCreateShop scrollRectToVisible:CGRectMake(0, 500, tblRect.size.width, tblRect.size.height) animated:YES];
    }
}

- (void)hideKeyboard:(id)sender
{
    CGRect tblRect = tblCreateShop.frame;
    tblRect.size.height = self.view.bounds.size.height;
    tblCreateShop.frame = tblRect;
}

- (void)initAttributeText:(UILabel *)lblDesc withStrText:(NSString *)strText withFont:(UIFont *)fontDesc withColor:(UIColor *)color
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8.0;
    style.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName:color,
                                 NSFontAttributeName: fontDesc,
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:strText attributes:attributes];
    lblDesc.attributedText = attributedText;
}

- (float)calculateHeight:(NSString *)strText withFont:(UIFont *)font andSize:(CGSize)size withColor:(UIColor *)color
{
    UILabel *lblMeasure = [UILabel new];
    [self initAttributeText:lblMeasure withStrText:strText withFont:font withColor:color];
    lblMeasure.numberOfLines = 0;
    return [lblMeasure sizeThatFits:size].height;
}


#pragma mark - Action View
- (void)lanjut:(id)sender
{
    if(txtNamaToko.text.length > 24) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringLimitNamaToko] delegate:self];
        [stickyAlertView show];
    }
    else {
        if(controller == nil) {
            controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyShopShipmentTableViewController"];
            controller.createShopViewController = self;
        }
        else if([controller getAvailShipment] == nil) {
            [controller loadData];
        }
        
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)showImage:(id)sender
{
    tkpdPicker = [[TKPDPhotoPicker alloc] initWithParentViewController:self pickerTransistionStyle:UIModalTransitionStyleCoverVertical];
    tkpdPicker.delegate = self;
    tkpdPicker.tag = 123;
}


- (void)checkDomain:(UIButton *)sender
{
    if(txtDomain.text.length == 0)
    {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringValidationFillDomain] delegate:self];
        [stickyAlertView show];
    }
    else
    {
        [txtDomain resignFirstResponder];
        txtDomain.enabled = NO;
        [self isCheckingDomain:YES];
        [[self getNetworkManager] doRequest];
    }
}


#pragma mark - UITableView Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CustomHeaderFooterTable *customHeaderFooterTable = [tableView dequeueReusableHeaderFooterViewWithIdentifier:CTagFooterCell];
    if(customHeaderFooterTable == nil)
    {
        customHeaderFooterTable = [[CustomHeaderFooterTable alloc] initWithReuseIdentifier:CTagFooterCell];
        customHeaderFooterTable.contentView.tag = CTagContentViewHeader;
        [customHeaderFooterTable initLbl:[UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter] andColor:CHeaderFooterCell andFrame:CGRectZero isHeader:NO];
        [customHeaderFooterTable initBtn:[UIFont fontWithName:CFont_Gotham_Book size:CFontSizeHeader] andColor:[UIColor whiteColor] andFrame:CGRectZero];
    }
    
    float widhtItem = tableView.bounds.size.width-(CPaddingLeft*2);
    switch (section) {
        case 0:
        {
            float heightLblFooter = [self calculateHeight:CStringDescCheckDomain withFont:[customHeaderFooterTable getLblFooter].font andSize:CGSizeMake(widhtItem, 9999) withColor:[customHeaderFooterTable getLblFooter].textColor];
            [customHeaderFooterTable setBtnFrame:CGRectMake(CPaddingLeft, CPaddingLeft/2.0f, widhtItem, CHeightHeaderCell-((CPaddingLeft/2.0f)*2))];
            [customHeaderFooterTable setLblFrame:CGRectMake([customHeaderFooterTable getBtnCheckDomain].frame.origin.x, [customHeaderFooterTable getBtnCheckDomain].bounds.size.height+[customHeaderFooterTable getBtnCheckDomain].frame.origin.y+CPaddingLeft, widhtItem, heightLblFooter) isHeader:NO];

            //Btn Check Domain
            [customHeaderFooterTable getBtnCheckDomain].hidden = NO;
            [self initAttributeText:[customHeaderFooterTable getLblFooter] withStrText:CStringDescCheckDomain withFont:[customHeaderFooterTable getLblFooter].font withColor:[UIColor lightGrayColor]];
            [[customHeaderFooterTable getBtnCheckDomain] setTitle:CStringCekDomain forState:UIControlStateNormal];
            [[customHeaderFooterTable getBtnCheckDomain] addTarget:self action:@selector(checkDomain:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 1:
        {
            float heightLblFooter = [self calculateHeight:CStringDescGambarFoto withFont:[customHeaderFooterTable getLblFooter].font andSize:CGSizeMake(widhtItem, 9999) withColor:[customHeaderFooterTable getLblFooter].textColor];
            [customHeaderFooterTable setLblFrame:CGRectMake(CPaddingLeft, CPaddingLeft, widhtItem, heightLblFooter) isHeader:NO];
            [self initAttributeText:[customHeaderFooterTable getLblFooter] withStrText:CStringDescGambarFoto withFont:[customHeaderFooterTable getLblFooter].font withColor:[UIColor lightGrayColor]];
            [customHeaderFooterTable getBtnCheckDomain].hidden = YES;
        }
            break;
        case 2:
            return nil;
    }
    
    return customHeaderFooterTable;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CustomHeaderFooterTable *customHeaderFooterTable = [tableView dequeueReusableHeaderFooterViewWithIdentifier:CTagHeaderCell];
    if(customHeaderFooterTable == nil)
    {
        customHeaderFooterTable = [[CustomHeaderFooterTable alloc] initWithReuseIdentifier:CTagHeaderCell];
        [customHeaderFooterTable initLbl:[UIFont fontWithName:CFont_Gotham_Book size:CFontSizeHeader] andColor:CHeaderFooterCell andFrame:CGRectMake(CPaddingLeft, CHeightHeaderCell/5.0f, tableView.bounds.size.width-(CPaddingLeft*2), CHeightHeaderCell-((CHeightHeaderCell/5.0f)*2)) isHeader:YES];
    }
    
    switch (section) {
        case 0:
            [customHeaderFooterTable getLblHeader].text = CStringDomain;
            break;
        case 1:
            [customHeaderFooterTable getLblHeader].text = CStringGambarToko;
            break;
        default:
            [customHeaderFooterTable getLblHeader].text = CStringInfoToko;
            break;
    }
    
    return customHeaderFooterTable;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        [cell setSeparatorInset:UIEdgeInsetsZero];
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
        [cell setPreservesSuperviewLayoutMargins:NO];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CreateShopCell *cell = [tableView dequeueReusableCellWithIdentifier:CTagCell];
    if(cell == nil)
        cell = [[CreateShopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CTagCell];
    
    if(indexPath.section == 0)
    {
        UIView *tempView = [cell.contentView viewWithTag:CTagUnggahImage];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagSlogan];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagDeskripsi];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagNamaToko];
        [tempView removeFromSuperview];
        [lblCountSlogan removeFromSuperview];
        [lblCountDescripsi removeFromSuperview];
        
        [cell getLblDomain].hidden = NO;
        if(txtDomain == nil)
        {
            int widthCheckList = 20;
            txtDomain = [[UITextField alloc] initWithFrame:CGRectMake([cell getLblDomain].frame.origin.x + [cell getLblDomain].bounds.size.width, 0, cell.bounds.size.width-CPaddingLeft-([cell getLblDomain].frame.origin.x+[cell getLblDomain].bounds.size.width)-widthCheckList, cell.bounds.size.height)];
            txtDomain.backgroundColor = [UIColor clearColor];
            txtDomain.tag = CTagDomain;
            txtDomain.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
            txtDomain.delegate = self;
            txtDomain.placeholder = CStringDomain;
            imageCheckList = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width-widthCheckList-15, (txtDomain.bounds.size.height-20)/2.0f, widthCheckList, txtDomain.bounds.size.height-(((txtDomain.bounds.size.height-20)/2.0f)*2))];
            imageCheckList.tag = CTagCheckList;
            imageCheckList.image = nil;
        }
        
        [cell.contentView addSubview:imageCheckList];
        [cell.contentView addSubview:txtDomain];
    }
    else if(indexPath.section == 1)
    {
        [cell getLblDomain].hidden = YES;
        UIView *tempView = [cell.contentView viewWithTag:CTagDomain];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagSlogan];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagDeskripsi];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagNamaToko];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagCheckList];
        [tempView removeFromSuperview];
        
        if(viewImgGambar == nil)
        {
            int diameterImage = 100;

            viewImgGambar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.height, CHeightHeaderCell*3)];
            viewImgGambar.tag = CTagUnggahImage;
            UILabel *lblUnggahGambar = [[UILabel alloc] initWithFrame:CGRectMake((tableView.frame.size.width)/2.0f-cell.bounds.size.width/2, (CHeightHeaderCell*3)-20, cell.bounds.size.width, 20)];
            lblUnggahGambar.text = CStringUnggahGambar;
            lblUnggahGambar.textAlignment = NSTextAlignmentCenter;
            lblUnggahGambar.font = [UIFont fontWithName:CFont_Gotham_Medium size:CFontSizeFooter];
            lblUnggahGambar.backgroundColor = [UIColor clearColor];
            lblUnggahGambar.textColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
            lblUnggahGambar.userInteractionEnabled = YES;
            [viewImgGambar addSubview:lblUnggahGambar];
            
            imgGambar = [[UIImageView alloc] initWithFrame:CGRectMake((tableView.bounds.size.width)/2.0f-diameterImage/2.0f, 10, diameterImage, diameterImage)];
            imgGambar.layer.cornerRadius = imgGambar.bounds.size.width/2.0f;
            imgGambar.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            imgGambar.layer.borderWidth = 0.5f;
            imgGambar.layer.masksToBounds = YES;
            imgGambar.contentMode = UIViewContentModeScaleAspectFit;
            imgGambar.userInteractionEnabled = YES;
            
            if(! hasSetImgGambar)
            {
                tempImage = [UIImageView new];
                tempImage.frame = CGRectMake((diameterImage-60)/2.0f, (diameterImage-60)/2.0f, 60, 60);
                tempImage.image = [UIImage imageNamed:@"icon_default_shop@2x.jpg"];
                [imgGambar addSubview:tempImage];
            }
            
            
            [imgGambar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)]];
            [lblUnggahGambar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)]];
            [viewImgGambar addSubview:imgGambar];
            viewImgGambar.userInteractionEnabled = YES;
        }
        
        [cell.contentView addSubview:viewImgGambar];
    }
    else if(indexPath.section == 2)
    {
        [cell getLblDomain].hidden = YES;        
        switch (indexPath.row) {
            case 0:
            {
                UIView *tempView = [cell.contentView viewWithTag:CTagUnggahImage];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagDomain];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagSlogan];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagDeskripsi];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagCheckList];
                [tempView removeFromSuperview];
                
                if(txtNamaToko == nil)
                {
                    txtNamaToko = [[UITextField alloc] initWithFrame:CGRectMake(CPaddingLeft, 0, tableView.bounds.size.width-(CPaddingLeft*2), CHeightHeaderCell)];
                    txtNamaToko.placeholder = CStringPlaceHolderNamaToko;
                    txtNamaToko.tag = CTagNamaToko;
                    txtNamaToko.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
                    txtNamaToko.delegate = self;
                }
                
                [cell.contentView addSubview:txtNamaToko];
            }
                break;
            case 1:
            {
                UIView *tempView = [cell.contentView viewWithTag:CTagUnggahImage];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagDomain];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagNamaToko];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagDeskripsi];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagCheckList];
                [tempView removeFromSuperview];
                
                if(txtSlogan == nil)
                {
                    txtSlogan = [[CustomTxtView alloc] initWithFrame:CGRectMake(CPaddingLeft, 0, tableView.bounds.size.width-(CPaddingLeft*2), CHeightHeaderCell*2)];
                    txtSlogan.placeholder = CStringPlaceHolderSlogan;
                    txtSlogan.createShopViewController = self;
                    txtSlogan.tag = CTagSlogan;
                    txtSlogan.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
                    
                    if([txtSlogan respondsToSelector:@selector(textContainerInset)]) {
                        txtSlogan.textContainerInset = UIEdgeInsetsMake(txtSlogan.textContainerInset.top, 0, 0, txtSlogan.textContainerInset.top);
                        txtSlogan.textContainer.lineFragmentPadding = 0;
                    }
                    
                    
                    int diameter = 30;
                    lblCountSlogan = [[UILabel alloc] initWithFrame:CGRectMake(txtSlogan.frame.origin.x+txtSlogan.bounds.size.width-diameter, txtSlogan.frame.origin.y+txtSlogan.bounds.size.height-diameter, diameter, diameter)];
                    lblCountSlogan.backgroundColor = [UIColor clearColor];
                    lblCountSlogan.font = [UIFont fontWithName:CFont_Gotham_Book size:10.0f];
                    lblCountSlogan.text = [NSString stringWithFormat:@"%d", (int)(CMaxSlogan-lblCountSlogan.text.length)];
                }

                [cell.contentView addSubview:txtSlogan];
                [cell.contentView addSubview:lblCountSlogan];
            }
                break;
            case 2:
            {
                UIView *tempView = [cell.contentView viewWithTag:CTagUnggahImage];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagDomain];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagSlogan];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagNamaToko];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagCheckList];
                [tempView removeFromSuperview];
                
                if(txtDesc == nil)
                {
                    txtDesc = [[CustomTxtView alloc] initWithFrame:CGRectMake(CPaddingLeft, 0, tableView.bounds.size.width-(CPaddingLeft*2), CHeightHeaderCell*2)];
                    txtDesc.placeholder = CstringPlaceHolderDesc;
                    txtDesc.tag = CTagDeskripsi;
                    txtDesc.createShopViewController = self;
                    txtDesc.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
                    
                    if([txtDesc respondsToSelector:@selector(textContainerInset)]) {
                        txtDesc.textContainerInset = UIEdgeInsetsMake(txtDesc.textContainerInset.top, 0, 0, txtDesc.textContainerInset.top);
                        txtDesc.textContainer.lineFragmentPadding = 0;
                    }
                    
                    
                    int diameter = 30;
                    lblCountDescripsi = [[UILabel alloc] initWithFrame:CGRectMake(txtDesc.frame.origin.x+txtDesc.bounds.size.width-diameter, txtDesc.frame.origin.y+txtDesc.bounds.size.height-diameter, diameter, diameter)];
                    lblCountDescripsi.font = [UIFont fontWithName:CFont_Gotham_Book size:10.0f];
                    lblCountDescripsi.backgroundColor = [UIColor clearColor];
                    lblCountDescripsi.text = [NSString stringWithFormat:@"%d", (int)(CMaxDesc-lblCountDescripsi.text.length)];
                }
                
                [cell.contentView addSubview:txtDesc];
                [cell.contentView addSubview:lblCountDescripsi];
            }
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return CHeightHeaderCell;
    else if(indexPath.section == 1)
        return CHeightHeaderCell*3;
    else
    {
        switch (indexPath.row) {
            case 0:
                return CHeightHeaderCell;
            case 1:
                return CHeightHeaderCell*2;
            default:
                return CHeightHeaderCell*2;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0 || section==1)
        return 1;
    else
        return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    float height = 0.0f;
    switch (section) {
        case 0:
        {
            height += [self calculateHeight:CStringDescCheckDomain withFont:[UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter] andSize:CGSizeMake(tableView.bounds.size.width-(CPaddingLeft*2), 9999) withColor:[UIColor blackColor]];
            height += CHeightHeaderCell + CPaddingLeft;
        }
            break;
        case 1:
        {
            height += [self calculateHeight:CStringDescGambarFoto withFont:[UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter] andSize:CGSizeMake(tableView.bounds.size.width-(CPaddingLeft*2), 9999) withColor:[UIColor blackColor]];
            height += CPaddingLeft+(CPaddingLeft/2.0f);
        }
            break;
        case 2:
            return 0;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CHeightHeaderCell;
}


#pragma mark - UIImagePicker Delegate
- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo
{
    NSDictionary *dict = [userInfo objectForKey:@"photo"];
    NSString *strImageName = [dict objectForKey:DATA_CAMERA_IMAGENAME];
    hasSetImgGambar = YES;
    imgGambar.image = [dict objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    [self checkValidation:nil withSlogan:nil withDesc:nil];

    NSDictionary *dictContent = @{
        @"photo": @{
            @"cameraimagedata": [dict objectForKey:DATA_CAMERA_IMAGEDATA],
            @"cameraimagename": strImageName
        }
    };

    dictContentPhoto = @{
        @"data_selected_photo": @{
            @"photo": @{
                @"cameraimagedata": [dict objectForKey:@"cameraimagedata"],
                @"cameraimagename": strImageName
            }
        }
    };

    [tempImage removeFromSuperview];
    tempImage = nil;
}



- (void)photoPicker:(TKPDPhotoPicker *)picker didFinishPickingImage:(UIImage *)image
{
    
}

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
//}



#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
    return YES;
}


- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length==0 && theTextField.tag!=CTagDomain && theTextField.tag!=CTagNamaToko)
        return YES;
    
    if(theTextField.tag == CTagDomain)
    {
        if(isValidDomain)
        {
            isValidDomain = NO;
            [self enableLanjut:NO];
        }
        else if(string.length == 0)
            return YES;
        
        if(theTextField.text.length >= CMaxCharDomain)
            return NO;
        
        NSCharacterSet *myCharSet = [NSCharacterSet alphanumericCharacterSet];
        for(int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if ([myCharSet characterIsMember:c])
                return YES;
        }
    }
    else if(theTextField.tag == CTagNamaToko)
    {
        [self checkValidation:[[theTextField text] stringByReplacingCharactersInRange:range withString:string] withSlogan:nil withDesc:nil];
        return YES;
    }
    

    return NO;
}


#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.view.tag = 0;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:nil];
        }
            break;
        case 1:
        {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
            imagePickerController.view.tag = 1;
            imagePickerController.delegate = self;
            imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
            break;
    }
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    return @{@"shop_domain":txtDomain.text, kTKPD_APIACTIONKEY:kTKPD_CHECK_DOMAIN};
}

- (NSString*)getPath:(int)tag
{
    return [NSString stringWithFormat:@"action/%@", kTKPMYSHOP_APIPATH];
}

- (id)getObjectManager:(int)tag
{
    objectManager =  [RKObjectManager sharedClient];
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[AddShop class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[AddShopResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{CStatusDomain:CStatusDomain}];
    
        
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:[self getPath:0] keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptorStatus];
    
    return objectManager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];

    return ((AddShop *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    txtDomain.enabled = YES;
    [self isCheckingDomain:NO];
    AddShop *addShop = [((RKMappingResult *) successResult).dictionary objectForKey:@""];

    if(addShop!=nil && [addShop.result.status_domain isEqualToString:@"1"])
    {
        isValidDomain = YES;
        [self checkValidation:nil withSlogan:nil withDesc:nil];
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringValidDomain] delegate:self];
        [stickyAlertView show];
        imageCheckList.image = [UIImage imageNamed:@"icon_correct.png"];
    }
    else
    {
        isValidDomain = NO;
        if(addShop.message_error==nil || addShop.message_error.count==0)
            addShop.message_error = @[CStringNotValidDomainName];
        
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:addShop.message_error delegate:self];
        [stickyAlertView show];
        imageCheckList.image = [UIImage imageNamed:@"icon_incorrect.png"];
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    isValidDomain = NO;
}

- (void)actionBeforeRequest:(int)tag
{
}

- (void)actionRequestAsync:(int)tag
{

}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    isValidDomain = NO;
    [self isCheckingDomain:NO];
    txtDomain.enabled = YES;
}



#pragma mark - CustomTextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *strText = [[textView text] stringByReplacingCharactersInRange:range withString:text];
    if(textView.tag == CTagSlogan)
    {
        [self checkValidation:nil withSlogan:strText withDesc:nil];
        
        if((int)(CMaxSlogan-strText.length) != -1)
            lblCountSlogan.text = [NSString stringWithFormat:@"%d", (int)(CMaxSlogan-strText.length)];
        if (text.length == 0)
            return YES;
        else if(textView.text.length >= CMaxSlogan)
            return NO;
        return YES;
    }
    else if(textView.tag == CTagDeskripsi)
    {
        [self checkValidation:nil withSlogan:nil withDesc:strText];
        
        if((int)(CMaxDesc-strText.length) != -1)
            lblCountDescripsi.text = [NSString stringWithFormat:@"%d", (int)(CMaxDesc-strText.length)];
        if (text.length == 0)
            return YES;
        else if(textView.text.length >= CMaxDesc)
            return NO;
        return YES;
    }
    
    
    return NO;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    activeTextView = textView;
    return YES;
}
@end
