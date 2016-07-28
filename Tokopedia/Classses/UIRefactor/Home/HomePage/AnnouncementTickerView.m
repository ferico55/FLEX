//
//  AnnouncementTickerView.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "AnnouncementTickerView.h"

@implementation AnnouncementTickerView

+ (id)newView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"AnnouncementTickerView" owner:nil options:nil];
    
    for (id view in views) {
        if ([view isKindOfClass:[self class]]) {
            return view;
        }
    }
    
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        return self;
    }
    
    return nil;
}

- (void)setTitle:(NSString *)text {
    _titleLabel.text = text;
}

- (void)setMessage:(NSString *)text {
    NSAttributedString *attString = [self attributedMessage:text];
    NSString *urlString = [NSString getLinkFromHTMLString:text];
    
    _messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    _messageLabel.attributedText = attString;
    _messageLabel.delegate = self;
    
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:attString.string options:0 range:NSMakeRange(0, [attString length])];
    
    for(NSTextCheckingResult* match in matches) {
        if (urlString) {
            NSURL *url = [NSURL URLWithString:urlString];
            [_messageLabel addLinkToURL:url withRange:match.range];
        }
    }
}

- (NSAttributedString *)attributedMessage:(NSString *)text {
    UIFont *font = [UIFont fontWithName:@"Gotham Book" size:14.0f];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                 NSFontAttributeName : font,
                                 NSParagraphStyleAttributeName : style};
    NSString *string = [NSString stringReplaceAhrefWithUrl:text];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    return attString;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *realUrl = [NSString stringWithFormat:@"https://tkp.me/r?url=%@", [url.absoluteString stringByReplacingOccurrencesOfString:@"*" withString:@"."]];
    self.onTapMessageWithUrl([NSURL URLWithString:[realUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);
}

@end
