//
//  AlertInfoView.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertInfoView.h"

@implementation AlertInfoView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
}

- (void)setText:(NSString *)text
{
    text = text?:@"";
    _text = text;
    self.textLabel.text = text;
}

- (void)setDetailText:(NSString *)detailText
{
    detailText = detailText?:@"";
    _detailText = detailText;
    _detailTextLabel.text = _detailText?:@"";
    [_detailTextLabel sizeToFit];
    
    CGRect frame = self.frame;
    frame.size.height = _detailTextLabel.frame.origin.y + _detailTextLabel.frame.size.height + 40;
    self.frame = frame;

}

@end
