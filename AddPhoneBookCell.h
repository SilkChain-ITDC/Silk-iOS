//
//  AddPhoneBookCell.h
//  OSell
//
//  Created by OsellMobile on 15/5/11.
//  Copyright (c) 2015年 DZSOIN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPhoneBookCell : UITableViewCell

//本地电话本数据
@property (weak, nonatomic) IBOutlet UIView *LocationView;
@property (weak, nonatomic) IBOutlet UILabel *locationNickLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;

//网络数据
@property (weak, nonatomic) IBOutlet UIView *NetDataView;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UIImageView *authImgView;
@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;
@property (weak, nonatomic) IBOutlet UILabel *netNickLabel;

@property (weak, nonatomic) IBOutlet UILabel *bottomLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightConstraint;

@end
