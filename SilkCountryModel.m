//
//  SilkCountryModel.m
//  OSell
//
//  Created by xlg on 2018/9/17.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "SilkCountryModel.h"

@implementation SilkCountryModel

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    SilkCountryModel *model = [[SilkCountryModel alloc] init];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        model.AreaCode = [dict  stringForKey:@"AreaCode"];
        model.Code = [dict stringForKey:@"Code"];
        model.Name = [dict stringForKey:@"Name"];
    }
    return model;
}

@end
