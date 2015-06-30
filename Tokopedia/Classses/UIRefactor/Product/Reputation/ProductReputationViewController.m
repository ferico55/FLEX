//
//  ProductReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "CMPopTipView.h"
#import "ProductReputationCell.h"
#import "ProductDetailReputationViewController.h"
#import "ProductReputationViewController.h"
#import "String_Reputation.h"
#define CCellIdentifier @"cell"

@interface ProductReputationViewController ()<TTTAttributedLabelDelegate, productReputationDelegate, CMPopTipViewDelegate, UIActionSheetDelegate>
@end

@implementation ProductReputationViewController
{
    NSMutableParagraphStyle *style;
    CMPopTipView *popTipView;
    UIRefreshControl *refreshControl;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    [self initTable];
    [self setRateStar:0 withAnimate:NO];
    tableContent.allowsSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    tableContent.backgroundColor = [UIColor clearColor];
    tableContent.delegate = self;
    tableContent.dataSource = self;
    [tableContent reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Method View
- (id)initButtonContentPopUp:(NSString *)strTitle withImage:(UIImage *)image withFrame:(CGRect)rectFrame withTextColor:(UIColor *)textColor
{
    int spacing = 3;
    
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.frame = rectFrame;
    [tempBtn setImage:image forState:UIControlStateNormal];
    [tempBtn setTitle:strTitle forState:UIControlStateNormal];
    [tempBtn setTitleColor:textColor forState:UIControlStateNormal];
    
    CGSize imageSize = tempBtn.imageView.bounds.size;
    CGSize titleSize = tempBtn.titleLabel.bounds.size;
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    tempBtn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    tempBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
    
    return (id)tempBtn;
}

- (void)initNavigation {
    self.navigationController.title = @"Reputasi";
    [self.navigationController.navigationBar sizeToFit];
}

- (void)setRateStar:(int)tag withAnimate:(BOOL)isAnimate {
    //Set Progress
    switch (tag) {
        case 0:
        {
            //Set Progress
            float totalCount = 100000.0f;
            [progress1 setProgress:80000/totalCount animated:isAnimate];
            [progress2 setProgress:20000/totalCount animated:isAnimate];
            [progress3 setProgress:0/totalCount animated:isAnimate];
            [progress4 setProgress:0/totalCount animated:isAnimate];
            [progress5 setProgress:0/totalCount animated:isAnimate];
            
            lblTotal1Rate.text = [NSString stringWithFormat:@"(%d)", 80000];
            lblTotal2Rate.text = [NSString stringWithFormat:@"(%d)", 20000];
            lblTotal3Rate.text = [NSString stringWithFormat:@"(%d)", 0];
            lblTotal4Rate.text = [NSString stringWithFormat:@"(%d)", 0];
            lblTotal5Rate.text = [NSString stringWithFormat:@"(%d)", 0];
            
            //Calculate widht total rate
            UILabel *tempLabel = [UILabel new];
            tempLabel.text = lblTotal1Rate.text;
            tempLabel.font = lblTotal1Rate.font;
            tempLabel.textColor = lblTotal1Rate.textColor;
            tempLabel.numberOfLines = 0;
            CGSize tempSize = [tempLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)];
            constWidthLblRate1.constant = constWidthLblRate2.constant = constWidthLblRate3.constant = constWidthLblRate4.constant = constWidthLblRate5.constant = tempSize.width;
            
            
            
            //Set header rate
            for(int i=0;i<arrImageHeaderRating.count;i++) {
                UIImageView *tempImageView = arrImageHeaderRating[i];
                tempImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<3)?@"icon_star_active":@"icon_star" ofType:@"png"]];
            }
            
            lblTotalHeaderRating.text = [NSString stringWithFormat:@"%d Out of %d", 3, 6];
            lblDescTotalHeaderRating.text = [NSString stringWithFormat:@"Based on %d ratings in the post %d months", 3, 6];
        }
            break;
        case 1:
        {
            //Set Progress
            float totalCount = 200000.0f;
            [progress1 setProgress:80000/totalCount animated:isAnimate];
            [progress2 setProgress:20000/totalCount animated:isAnimate];
            [progress3 setProgress:60000/totalCount animated:isAnimate];
            [progress4 setProgress:40000/totalCount animated:isAnimate];
            [progress5 setProgress:0/totalCount animated:isAnimate];
            
            
            lblTotal1Rate.text = [NSString stringWithFormat:@"(%d)", 80000];
            lblTotal2Rate.text = [NSString stringWithFormat:@"(%d)", 20000];
            lblTotal3Rate.text = [NSString stringWithFormat:@"(%d)", 60000];
            lblTotal4Rate.text = [NSString stringWithFormat:@"(%d)", 40000];
            lblTotal5Rate.text = [NSString stringWithFormat:@"(%d)", 0];
            
            //Calculate widht total rate
            UILabel *tempLabel = [UILabel new];
            tempLabel.text = lblTotal1Rate.text;
            tempLabel.font = lblTotal1Rate.font;
            tempLabel.textColor = lblTotal1Rate.textColor;
            tempLabel.numberOfLines = 0;
            CGSize tempSize = [tempLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)];
            constWidthLblRate1.constant = constWidthLblRate2.constant = constWidthLblRate3.constant = constWidthLblRate4.constant = constWidthLblRate5.constant = tempSize.width;
            
            
            
            //Set header rate
            for(int i=0;i<4;i++) {
                UIImageView *tempImageView = arrImageHeaderRating[i];
                tempImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<4)?@"icon_star_active":@"icon_star" ofType:@"png"]];
            }
            
            lblTotalHeaderRating.text = [NSString stringWithFormat:@"%d Out of %d", 4, 6];
            lblDescTotalHeaderRating.text = [NSString stringWithFormat:@"Based on %d ratings in the post %d months", 4, 6];
        }
            break;
    }
}


- (void)initTable {
    //Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [tableContent addSubview:refreshControl];
    tableContent.tableHeaderView = viewHeader;
}



#pragma mark - UITableView Delegate and DataSource 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTTAttributedLabel *tempLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [self setPropertyLabelDesc:tempLabel];
    [self initLabelDesc:tempLabel withText:@"pasjk pdlf klksa jflj asldf jsadj flkjsalkdf jask jdflksa jdlkf jaslkdj flkas jdfl ajslkdf jsakl jflkasj dlfk jaslk jflksd"];

    CGSize tempSizeDesc = [tempLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width-(CPaddingTopBottom*4), 9999)];//4 padding left and right of label description
    return tempSizeDesc.height + (CPaddingTopBottom*8) + 2 + CPaddingTopBottom + CHeightDate + CHeightViewStar + CHeightButton + CheightImage; //9 is total padding of each row component
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = viewFooter;
    [footerActIndicator startAnimating];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductReputationCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductReputationCell" owner:nil options:0];
        cell = [tempArr objectAtIndex:0];
        cell.delegate = self;
        [self setPropertyLabelDesc:cell.getLabelDesc];
    }
    
    cell.getBtnRateEmoji.tag = cell.getBtnChat.tag = cell.getBtnDisLike.tag = cell.getBtnLike.tag = cell.getBtnMore.tag = indexPath.row;
    
    cell.getImageProfile.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_no_data" ofType:@"png"]];
    [cell setLabelUser:@"Andre" withTag:0];
    [cell setPercentage:@"35"];
    [cell setLabelDate:@"3 hari yang lalu"];
    [cell setDescription:@"pasjk pdlf klksa jflj asldf jsadj flkjsalkdf jask jdflksa jdlkf jaslkdj flkas jdfl ajslkdf jsakl jflkasj dlfk jaslk jflksd"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


#pragma mark - TTTAttributeLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point
{
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    NSLog(@"test");
}


#pragma mark - Action
- (void)refreshView:(UIRefreshControl*)refresh
{
    NSLog(@"sdf");
    [refresh endRefreshing];
}

- (IBAction)actionSegmentedValueChange:(id)sender {
    switch (((UISegmentedControl *) sender).selectedSegmentIndex) {
        case 0:
        {
            [self setRateStar:0 withAnimate:YES];
        }
            break;
        case 1:
        {
            [self setRateStar:1 withAnimate:YES];
        }
            break;
    }
}

- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}


#pragma mark - Method
- (void)dismissAllPopTipViews
{
    [popTipView dismissAnimated:YES];
    popTipView = nil;
}

- (void)setPropertyLabelDesc:(TTTAttributedLabel *)lblDesc {
    lblDesc.backgroundColor = [UIColor clearColor];
    lblDesc.textAlignment = NSTextAlignmentLeft;
    lblDesc.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    lblDesc.textColor = [UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f];
    lblDesc.lineBreakMode = NSLineBreakByWordWrapping;
    lblDesc.numberOfLines = 0;
}


#pragma mark - ProductReputation Delegate
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription {
    NSString *strLihatSelengkapnya = @"Lihat Selengkapnya";
    if(strDescription.length > 100) {
        strDescription = [NSString stringWithFormat:@"%@... %@", [strDescription substringToIndex:100], strLihatSelengkapnya];
        
        NSRange range = [strDescription rangeOfString:strLihatSelengkapnya];
        lblDesc.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        lblDesc.delegate = self;
        lblDesc.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor lightGrayColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        lblDesc.linkAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:range];
        
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(strDescription.length-strLihatSelengkapnya.length, strLihatSelengkapnya.length)];
        lblDesc.attributedText = str;
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        lblDesc.delegate = nil;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
    }
}

- (void)actionLike:(id)sender {
    
}
- (void)actionDisLike:(id)sender {
    
}
- (void)actionChat:(id)sender {
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}

- (void)actionMore:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CStringBatal destructiveButtonTitle:nil otherButtonTitles:CStringLapor, nil];
    actionSheet.tag = ((UIButton *) sender).tag;
    [actionSheet showInView:self.view];
}


- (void)actionRate:(id)sender {
    int paddingRightLeftContent = 10;
    UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent+paddingRightLeftContent, CHeightItemPopUp)];
    viewContentPopUp.backgroundColor = [UIColor clearColor];
    
    UIButton *btnMerah = (UIButton *)[self initButtonContentPopUp:@"35" withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_home" ofType:@"png"]] withFrame:CGRectMake(paddingRightLeftContent, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor redColor]];
    UIButton *btnKuning = (UIButton *)[self initButtonContentPopUp:@"36" withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_home" ofType:@"png"]] withFrame:CGRectMake(btnMerah.frame.origin.x+btnMerah.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor yellowColor]];
    UIButton *btnHijau = (UIButton *)[self initButtonContentPopUp:@"37" withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_home" ofType:@"png"]] withFrame:CGRectMake(btnKuning.frame.origin.x+btnKuning.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor greenColor]];
    
    btnMerah.tag = CTagMerah;
    btnKuning.tag = CTagKuning;
    btnHijau.tag = CTagHijau;
    
    [btnMerah addTarget:self action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    [btnKuning addTarget:self action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    [btnHijau addTarget:self action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    
    [viewContentPopUp addSubview:btnMerah];
    [viewContentPopUp addSubview:btnKuning];
    [viewContentPopUp addSubview:btnHijau];
    
    
    //Init pop up
    popTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor whiteColor];
    popTipView.animation = CMPopTipAnimationSlide;
    popTipView.has3DStyle = YES;
    popTipView.dismissTapAnywhere = YES;
    
    UIButton *button = (UIButton *)sender;
    [popTipView presentPointingAtView:button inView:self.view animated:YES];
}


#pragma mark - PopUp
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}


#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%d", (int)buttonIndex);
}
@end
