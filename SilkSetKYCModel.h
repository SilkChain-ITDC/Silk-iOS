//
//  SilkSetKYCModel.h
//  OSell
//
//  Created by xlg on 2018/6/21.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SilkSetKYCModel : NSObject

@property (copy, nonatomic) NSString *AuthInt;
@property (copy, nonatomic) NSString *AuthMessage;
@property (copy, nonatomic) NSString *AuthName;
@property (copy, nonatomic) NSString *FirstName;
@property (copy, nonatomic) NSString *IdentificationNumber;
@property (copy, nonatomic) NSString *IdentificationType;
@property (copy, nonatomic) NSString *LastName;
@property (copy, nonatomic) NSString *Nationality;
@property (copy, nonatomic) NSString *NationalityCode;
@property (copy, nonatomic) NSString *PhotoBackSide;
@property (copy, nonatomic) NSString *PhotoFrontSide;
@property (copy, nonatomic) NSString *PhotoSelfie;
@property (copy, nonatomic) NSString *UserID;

@property (strong, nonatomic) UIImage *imageFrontSide;
@property (strong, nonatomic) UIImage *imageBackSide;
@property (strong, nonatomic) UIImage *imageSelfie;

- (void)setupModelWithDict:(NSDictionary *)dict;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
