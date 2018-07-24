//
//  AddPhoneBookCell.m
//  OSell
//
//  Created by OsellMobile on 15/5/11.
//  Copyright (c) 2015年 DZSOIN. All rights reserved.
//

#import "AddPhoneBookCell.h"

@implementation AddPhoneBookCell

- (void)awakeFromNib {
    
    self.bottomLineHeightConstraint.constant = 0.6f;
    self.headImgView.layer.masksToBounds = YES;
    self.headImgView.layer.cornerRadius = self.headImgView.width/2;
    self.addFriendBtn.layer.masksToBounds = YES;
    self.addFriendBtn.layer.cornerRadius = 6.0f;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
