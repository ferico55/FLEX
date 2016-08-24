//
//  ResolutionCenterDetailCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterDetailCell.h"
#import "InboxTicketDetailAttachment.h"
#import "NavigationHelper.h"

@implementation ResolutionCenterDetailCell

#pragma mark - Factory methods
+ (id)newCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ResolutionCenterDetailCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

-(void)setIsMark:(BOOL)isMark {
}

- (void)awakeFromNib {

}

- (IBAction)tap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tapCellButton:atIndexPath:)]) {
        [_delegate tapCellButton:(UIButton*)sender atIndexPath:_indexPath];
    }
}

- (void)hideAllViews
{
    [_attachmentImages makeObjectsPerformSelector:@selector(setImage:) withObject:nil];
    _oneButtonView.hidden = YES;
    _twoButtonView.hidden = YES;
    _atachmentView.hidden = YES;
    _btnReputation.hidden = YES;
}

- (IBAction)gesture:(UITapGestureRecognizer*)sender {
    if (sender.view.tag == 15) {
        if ([NavigationHelper shouldDoDeepNavigation])
            [_delegate goToShopOrProfileIndexPath:_indexPath];
    } else {
        
        if (((UIImageView*)self.attachmentImages[sender.view.tag-10]).image == nil) {
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(goToImageViewerIndex:atIndexPath:)]) {
            [_delegate goToImageViewerIndex:sender.view.tag-10 atIndexPath:_indexPath];
        }
        if ([self.delegate respondsToSelector:@selector(goToImageViewerImages:atIndexImage:atIndexPath:)]) {
            
            NSMutableArray *images = [NSMutableArray new];
            for (UIImageView *imageView in self.attachmentImages) {
                if (imageView.image != nil) {
                    [images addObject:imageView];
                }
            }
            
            [_delegate goToImageViewerImages:[images copy] atIndexImage:sender.view.tag-10 atIndexPath:_indexPath];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.markLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.markLabel.frame);
}

- (void)setViewModel:(ConversationViewModel *)viewModel {
    
    [self hideAllViews];

    self.topMarginConstraint.constant = 5;
    self.twobuttonConstraintHeight.constant = 0;
    self.oneButtonConstraintHeight.constant = 0;

    if (viewModel.conversationPhotos.count > 0) {
        self.imageConstraintHeight.constant = 74;
        for (InboxTicketDetailAttachment *attachment in viewModel.conversationPhotos) {
            NSInteger index = [viewModel.conversationPhotos indexOfObject:attachment];
            if (index < 5)
            {
                UIImageView *imageView = [self.attachmentImages objectAtIndex:index];
                if (attachment.img) {
                    imageView.image = attachment.img;
                } else {
                    NSURL *url = [NSURL URLWithString:attachment.img_src];
                    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
                    [imageView setImageWithURLRequest:request
                                     placeholderImage:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                                  imageView.image = image;
                                              } failure:nil];
                }
            }
        }
    } else {
        self.imageConstraintHeight.constant = 0;
    }
    
    self.buyerNameLabel.text = viewModel.userName;

    NSURL *url = [NSURL URLWithString:viewModel.userProfilePicture];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImage *buyerDefaultImage = [UIImage imageNamed:@"icon_profile_picture.jpeg"];
    self.buyerProfileImageView.layer.cornerRadius = self.buyerProfileImageView.frame.size.width/2;
    [self.buyerProfileImageView setImageWithURLRequest:request
                                      placeholderImage:buyerDefaultImage
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.buyerProfileImageView setImage:image];
    } failure:nil];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0;

    UIFont *gothamBookFont = [UIFont largeTheme];
    UIFont *gothamMediumFont = [UIFont largeThemeMedium];

    if (![viewModel.conversationMessage isEqualToString:@"0"] && !viewModel.conversationNote) {

        NSDictionary *textAttributes = @{
                                         NSFontAttributeName            : gothamBookFont,
                                         NSParagraphStyleAttributeName  : style,
                                         NSForegroundColorAttributeName : [UIColor blackColor],
                                         };

        self.markLabel.attributedText = [[NSAttributedString alloc] initWithString:viewModel.conversationMessage?:@""
                                                                        attributes:textAttributes];

    } else if (![viewModel.conversationMessage isEqualToString:@"0"] && viewModel.conversationNote) {
        
        NSString *message = [NSString stringWithFormat:@"%@\n\n%@", viewModel.conversationMessage, viewModel.conversationNote];
        
        NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
        [attributedMessage addAttribute:NSFontAttributeName value:gothamBookFont range:NSMakeRange(0, viewModel.conversationMessage.length)];
        [attributedMessage addAttribute:NSFontAttributeName value:gothamMediumFont range:NSMakeRange(viewModel.conversationMessage.length+2,
                                                                                                     viewModel.conversationNote.length)];
        [attributedMessage addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, message.length)];
        [attributedMessage addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, message.length)];
        
        self.markLabel.attributedText = attributedMessage;

    } else if ([viewModel.conversationMessage isEqualToString:@"0"] && viewModel.conversationNote) {

        NSDictionary *textAttributes = @{
                                         NSFontAttributeName            : gothamMediumFont,
                                         NSParagraphStyleAttributeName  : style,
                                         NSForegroundColorAttributeName : [UIColor blackColor],
                                         };
        
        self.markLabel.attributedText = [[NSAttributedString alloc] initWithString:viewModel.conversationNote?:@""
                                                                        attributes:textAttributes];

    }
    
    self.buyerSellerLabel.text = viewModel.conversationOwner;
    self.buyerSellerLabel.layer.cornerRadius = 2;

    if ([viewModel.conversationOwner isEqualToString:@"Administrator"]) {
        self.buyerSellerLabel.backgroundColor = [UIColor colorWithRed:248.0/255.0
                                                                green:148.0/255.0
                                                                 blue:6.0/255.0
                                                                alpha:1];
    } else {
        self.buyerSellerLabel.backgroundColor = [UIColor colorWithRed:70.0/255.0
                                                                green:136.0/255.0
                                                                 blue:71.0/255.0
                                                                alpha:1];
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm'Z'"];
    NSDate *date = [dateFormatter dateFromString:viewModel.conversationDate];
    NSString *sinceDateString = [NSString timeLeftSinceDate:date];
    self.timeRemainingLabel.text =  sinceDateString;
    
}

@end
