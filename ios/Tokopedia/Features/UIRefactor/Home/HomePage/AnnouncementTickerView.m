//
//  AnnouncementTickerView.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "AnnouncementTickerView.h"
#import "Tokopedia-Swift.h"
#import "NSURL+TKPURL.h"

@interface AnnouncementTickerView()

@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end


@implementation AnnouncementTickerView

-(instancetype)initWithMessage:(NSString *)message colorHexString:(NSString *)colorHexString{
    
    self = [AnnouncementTickerView newView];
    [self setMessage:message withContentColorHexString:colorHexString];
    
    return self;
}

+ (id)newView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"AnnouncementTickerView" owner:nil options:nil];
    
    for (id view in views) {
        if ([view isKindOfClass:[self class]]) {
            return view;
        }
    }
    
    return nil;
}

- (void)resetMessageAttributedLabel{
    _messageLabel.text = nil;
    _messageLabel.linkAttributes = nil;
    _messageLabel.attributedText = nil;
    _messageLabel.attributedTruncationToken = nil;
}

- (void)setMessage:(NSString *)text withContentColorHexString:(NSString *)contentColorHexString{
    
    [self resetMessageAttributedLabel];
    
    NSString *tickerMessage = [NSString convertHTML:text];
    NSAttributedString *attString = [self attributedMessage:tickerMessage];
    NSArray *matches = [NSString getStringsBetweenAhrefTagWithString:text];
    NSArray <NSString *> *links = [NSString getLinksBetweenAhrefTagWithString:text];
    NSMutableArray *mutArray = [NSMutableArray new];
    
    _messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    _messageLabel.attributedText = attString;
    _messageLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    _messageLabel.delegate = self;
    _messageLabel.linkAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:49/255.0 green:140/255.0 blue:47/255.0 alpha:1.0],
                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone),
                                     NSFontAttributeName : [UIFont microTheme]};
    
    for (NSTextCheckingResult* match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        [mutArray addObject:[text substringWithRange:matchRange]];
    }
    
    for (NSInteger ii = 0; ii < [links count]; ii++) {
        NSURL *url = [NSURL URLWithString:links[ii]];
        NSRange range = [attString.string rangeOfString:mutArray[ii]];
        [_messageLabel addLinkToURL:url withRange:range];
    }
    
    [self setContentColorHexString:contentColorHexString];
}

-(void)setContentColorHexString:(NSString *)contentColorHexString{
    
    UIColor *themeColor = [UIColor fromHexString:contentColorHexString];
    _contentView.layer.borderColor = themeColor.CGColor;
    
    UIImage *origImage = _closeButton.imageView.image;
    UIImage *tintImage = [origImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_closeButton setImage:tintImage forState:UIControlStateNormal];
    _closeButton.tintColor = themeColor;
    
}

- (NSAttributedString *)attributedMessage:(NSString *)text {
    UIFont *font = [UIFont microTheme];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [[UIColor alloc] initWithRed:67/255.0 green:66/255.0 blue:66/255.0 alpha:1],
                                 NSFontAttributeName : font,
                                 NSParagraphStyleAttributeName : style};
    NSString *string = [NSString extracTKPMEUrl:text];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    return attString;
}

- (IBAction)tapClose:(id)sender {
    
    if(_onTapCloseButton){
        self.onTapCloseButton();
    }
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    self.onTapMessageWithUrl([url TKPMeUrl]);
}

@end
