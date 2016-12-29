//
//  JasonSpaceComponent.m
//  Jasonette
//
//  Copyright © 2016 gliechtenstein. All rights reserved.
//
#import "JasonSpaceComponent.h"

@implementation JasonSpaceComponent
+ (UIView *)build:(NSDictionary *)json withOptions:(NSDictionary *)options{
    UIView *component = [[UIView alloc] init];
    if([options[@"parent"] isEqualToString:@"vertical"]){
        [component setContentHuggingPriority:1 forAxis:UILayoutConstraintAxisVertical];
    }else if([options[@"parent"] isEqualToString:@"horizontal"]){
        [component setContentHuggingPriority:1 forAxis:UILayoutConstraintAxisHorizontal];
    }
    component.translatesAutoresizingMaskIntoConstraints = false;
    
    // Apply Common Style
    [self stylize:json component:component];
    
    return component;
}

@end
