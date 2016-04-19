//
//  CCData.h
//  
//
//  Created by Renny Runiawati on 7/7/15.
//
//

#import <Foundation/Foundation.h>

@interface CCData : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *postal_code;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *first_name;

@end
