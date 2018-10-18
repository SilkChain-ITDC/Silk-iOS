//
//  SilkCountryModel.h
//  OSell
//
//  Created by xlg on 2018/9/17.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SilkCountryModel : NSObject

@property (copy, nonatomic) NSString *AreaCode;//国家编号
@property (copy, nonatomic) NSString *Code;    //简称
@property (copy, nonatomic) NSString *Name;    //全称

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
