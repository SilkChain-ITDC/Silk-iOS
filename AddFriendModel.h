//
//  AddFriendModel.h
//  OSell
//
//  Created by OsellMobile on 15/6/4.
//  Copyright (c) 2015年 DZSOIN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddFriendModel : NSObject

@property (nonatomic, strong) NSString *UserID;
@property (nonatomic, strong) NSString *UserName;
@property (nonatomic, strong) NSString *Faceimage;
@property (nonatomic, strong) NSString *CountryCode;
@property (nonatomic, assign) int type;
@property (nonatomic, strong) NSString *sign;
@property (nonatomic, strong) NSString *NickName;
@property (nonatomic, assign) int authstatus;
@property (nonatomic, strong) NSString *MyCategoryApp;

@end
