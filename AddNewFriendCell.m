//
//  AddNewFriendCell.m
//  OSell
//
//  Created by OSellResuming on 15/11/19.
//  Copyright © 2015年 DZSOIN. All rights reserved.
//

#import "AddNewFriendCell.h"
#import "InternationalizationHelper.h"
#import "NotifyMessage.h"
#import "UIImageView+WebCache.h"

@implementation AddNewFriendCell

- (void)awakeFromNib {
    
    self.headImgView.layer.masksToBounds = YES;
    self.headImgView.layer.cornerRadius = self.headImgView.width/2;
    self.bottomLineHeightConstraint.constant = 0.6f;
    self.yesBtn.layer.masksToBounds = YES;
    self.yesBtn.layer.cornerRadius = 5.0f;
    
    //设置多语言
    self.contentLabel.text = [InternationalizationHelper getText:@"AddNewFriendVC_Requested to add you as a friend."];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
}

/**刷新Cell，根据当前消息Model和当前好友列表
 */
- (void)refreshCellData:(NotifyMessage *)curMsg{
    
    self.curNotifyMessage=curMsg;
    /// 将String转化为字典
    NSDictionary *dictUserInfo=[[OSellStringHelper shareInstance] convertToSystemDataTypeByContent:self.curNotifyMessage.Content];
    
    SilkLoginUserModel *userInfo=[SilkLoginUserModel convertUserByData:dictUserInfo];
    if (!userInfo) {
        return;
    }
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:userInfo.userFaceImg] placeholderImage:[UIImage imageNamed:@"chat_tab_defaut.png"]];
    [self.nickNameLabel setText:userInfo.userName];
    
    if (self.curNotifyMessage.State == 1){
        
        self.yesBtn.userInteractionEnabled = NO;
        self.yesBtn.backgroundColor = [UIColor whiteColor];
        [self.yesBtn setTitleColor:UIColorFromRGB(0X989898) forState:UIControlStateNormal];
        self.yesBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.yesBtn setTitle:[InternationalizationHelper getText:@"AddNewFriendVC_Added"] forState:UIControlStateNormal];
        
    }else{
        
        self.yesBtn.userInteractionEnabled = YES;
        [self.yesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.yesBtn.backgroundColor = UIColorFromRGB(0x17AAF6);
        self.yesBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [self.yesBtn setTitle:[InternationalizationHelper getText:@"AddNewFriendVC_Accept"] forState:UIControlStateNormal];
    
    }

}

@end
