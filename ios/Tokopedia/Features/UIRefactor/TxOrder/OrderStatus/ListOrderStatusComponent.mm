//
//  ListOrderStatusComponent.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>

#import "ListOrderStatusComponent.h"
#import "TxOrderStatusList.h"
#import "UIColor+TextColor.h"
#import "UIColor+Theme.h"
#import "OrderCellContext.h"

@implementation ListOrderStatusComponent{
    TxOrderStatusList *_order;
    OrderCellContext *_context;
}

+ (instancetype)newWithOrder:(TxOrderStatusList *)order context:(OrderCellContext*)context{
    
    ListOrderStatusComponent * component =
    [super newWithComponent:
     [CKInsetComponent
      newWithView:{
          [UIView class],
          {
              {@selector(setBackgroundColor:), [UIColor whiteColor]},
          }
      }
      insets:{8,8,8,8}
      component:
          [CKStackLayoutComponent
           newWithView:{}
           size:{}
           style:{
               .direction = CKStackLayoutDirectionHorizontal,
               .alignItems = CKStackLayoutAlignItemsCenter,
               .spacing = 7,
           }
           children:{
                {
                   [self statusViewWithOrder:order context:context],
                   .alignSelf = CKStackLayoutAlignSelfStart,
                   .flexGrow = YES,
                   .flexShrink = YES
                },
                {
                  [self disclosureImageWithContext:context],
                  .alignSelf = CKStackLayoutAlignSelfCenter,
                }
           }]
     ]];
    component->_order = order;
    component->_context = context;
    return component;
}

+(CKComponent *)statusViewWithOrder:(TxOrderStatusList *)order context:(OrderCellContext*)context{
     return
      [CKStackLayoutComponent
       newWithView:{
           [UIView class],
           {
               {CKComponentTapGestureAttribute(@selector(tapDetail))},
           }
       }
       size:{}
       style:{
           .direction = CKStackLayoutDirectionVertical,
           .spacing = 10
       }
       children:{
           {[self labelLastStatus]},
           {[self labelWithStatusOrder:order.lastStatusString]},
           {[self driverInfoWithContext:context list:order],
               .alignSelf = CKStackLayoutAlignSelfStretch
           },
           {[self driverContactButtonWithList:order]}
       }];
}

+(CKComponent *)disclosureImageWithContext:(OrderCellContext*)context{
    return
    [CKImageComponent
     newWithImage:context.images[@"arrow"]
     size:{15,15}
     ];
}

+(CKLabelComponent *)labelLastStatus{
    return
    [CKLabelComponent
     newWithLabelAttributes:{
         .string = @"Status Terakhir",
         .color = [UIColor textDarkGrayTheme],
         .font = [UIFont microTheme]
     }
     viewAttributes:{
         {@selector(setBackgroundColor:), [UIColor clearColor]},
     }
     size:{}];
}

+(CKLabelComponent *)labelWithStatusOrder:(NSString *)statusOrder{
    CKLabelComponent *component =
    [CKLabelComponent
     newWithLabelAttributes:{
         .string = statusOrder,
         .font = [UIFont smallThemeMedium],
         .lineBreakMode = NSLineBreakByWordWrapping
     }
     viewAttributes:{
         {CKComponentTapGestureAttribute(@selector(tapDetail))},
         {@selector(setBackgroundColor:), [UIColor clearColor]},
     }
     size:{}];
    
    return component;
}

+(CKStackLayoutComponent *)driverInfoWithContext:(OrderCellContext*)context list:(TxOrderStatusList*)list{
    if (!([list.driver_info.driver_photo isEqualToString:@""] || list.driver_info == nil)) {
        return
        [CKStackLayoutComponent
         newWithView:{
             [UIView class],
         }
         size:{}
         style:{
             .direction = CKStackLayoutDirectionHorizontal,
             .alignItems = CKStackLayoutAlignItemsEnd,
             .spacing = 13
         }
         children:{
             {[self driverPhotoWithContext:context list:list]},
             {[self driverNamePhoneWithList:list],
                 .alignSelf = CKStackLayoutAlignSelfCenter
             }
         }];
    } else return nil;
}

+(CKNetworkImageComponent *)driverPhotoWithContext:(OrderCellContext*)context list:(TxOrderStatusList*)list{
    NSString *info = list.driver_info.driver_photo;
    CKNetworkImageComponent *component =
    [CKNetworkImageComponent newWithURL: [NSURL URLWithString:info]
                        imageDownloader: context.imageDownloader
                              scenePath: nil
                                   size: {34, 34}
                                options: {}
                             attributes: {
                                 {@selector(setCornerRadius:), @(17)},
                                 {@selector(setClipsToBounds:), @YES}
                             }
     ];
    
    return component;
}

+(CKLabelComponent *)driverNamePhoneWithList:(TxOrderStatusList*)list{
    NSString *name = list.driver_info.driver_name;
    NSString *phone = list.driver_info.driver_phone;
    NSString *license = list.driver_info.license_number;
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = rect.size.width - 180;
    CGFloat height = [license isEqualToString:@""] || license==nil ? 29 : 43;
    return
    [CKLabelComponent
     newWithLabelAttributes:{
         .string = [license isEqualToString:@""] || license==nil ? [NSString stringWithFormat:@"%@\n%@", name, phone] : [NSString stringWithFormat:@"%@\n%@\n%@", name, phone, license],
         .color = [UIColor textDarkGrayTheme],
         .font = [UIFont microTheme]
     }
     viewAttributes:{}
     size:{width, height}];
}

+(CKButtonComponent *)driverContactButtonWithList:(TxOrderStatusList*)list{
    if (!([list.driver_info.driver_photo isEqualToString:@""] || list.driver_info == nil)) {
        std::unordered_map<UIControlState, UIColor *> titleColors = {
            {UIControlStateNormal, [UIColor tpSecondaryBlackText]}
        };
        return
        [CKButtonComponent newWithTitles: {{UIControlStateNormal, @"Hubungi"}}
                             titleColors: titleColors
                                  images: {}
                        backgroundImages: {}
                               titleFont: [UIFont microTheme]
                                selected: {}
                                 enabled: YES
                                  action: @selector(contactDriver:)
                                    size: {80,28}
                              attributes: {
                                  {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 1.0},
                                  {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 3.0},
                                  {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[[UIColor colorWithWhite:224.0/255.0 alpha:1] CGColor]}
                              }
              accessibilityConfiguration: {}
         ];
    } else return nil;
}

- (void)contactDriver:(CKButtonComponent *)sender {
    NSString *phoneNumber = self->_order.driver_info.driver_phone;
    UIAlertController *popup = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *call = [UIAlertAction
                                  actionWithTitle:@"Telepon"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", phoneNumber]];
                                      if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
                                          [[UIApplication sharedApplication] openURL:phoneURL];
                                      }
                                  }];
    
    UIAlertAction *message = [UIAlertAction
                                  actionWithTitle:@"Kirim Pesan"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      NSString *message = [NSString stringWithFormat:@"sms://%@&body=%@", phoneNumber, @""];
                                      NSURL *messageURL = [NSURL URLWithString:[message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                      if ([[UIApplication sharedApplication] canOpenURL:messageURL]) {
                                          [[UIApplication sharedApplication] openURL:messageURL];
                                      }
                                  }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Batal"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action) {
                                [popup dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    [popup addAction: call];
    [popup addAction: message];
    [popup addAction: cancel];
    
    [_context.viewController presentViewController:popup animated:YES completion:nil];
}

-(void)tapDetail{
    if (_context.onTapDetail) {
        _context.onTapDetail(_order);
    }
}

@end
