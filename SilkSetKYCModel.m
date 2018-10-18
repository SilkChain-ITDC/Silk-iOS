//
//  SilkSetKYCModel.m
//  OSell
//
//  Created by xlg on 2018/6/21.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "SilkSetKYCModel.h"

@implementation SilkSetKYCModel

- (void)setupModelWithDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        self.AuthInt = [dict  stringForKey:@"AuthInt"];
        self.AuthMessage = [dict stringForKey:@"AuthMessage"];
        self.AuthName = [dict stringForKey:@"AuthName"];
        self.FirstName = [dict  stringForKey:@"FirstName"];
        self.IdentificationNumber = [dict stringForKey:@"IdentificationNumber"];
        self.IdentificationType = [dict stringForKey:@"IdentificationType"];
        self.LastName = [dict  stringForKey:@"LastName"];
        self.Nationality = [dict stringForKey:@"Nationality"];
        self.NationalityCode = [dict stringForKey:@"NationalityCode"];
        self.PhotoBackSide = [dict  stringForKey:@"PhotoBackSide"];
        self.PhotoFrontSide = [dict stringForKey:@"PhotoFrontSide"];
        self.PhotoSelfie = [dict stringForKey:@"PhotoSelfie"];
        self.UserID = [dict  stringForKey:@"UserID"];
    }
}

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    SilkSetKYCModel *model = [[SilkSetKYCModel alloc] init];
    [model setupModelWithDict:dict];
    return model;
}

@end
