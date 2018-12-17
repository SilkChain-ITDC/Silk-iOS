//
//  OSilkReferralViewController.h
//  OSell
//
//  Created by xlg on 2018/5/29.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "Base.h"

#import "OSilkInfoModel.h"

@interface OSilkReferralViewController : Base

@property (strong, nonatomic) OSilkInfoModel *silkInfo;


@property (weak, nonatomic) IBOutlet UIScrollView *bGView;

@property (weak, nonatomic) IBOutlet UILabel *lblCodeTips;    //邀请码提示语
@property (weak, nonatomic) IBOutlet UILabel *lblReferralCode;//邀请码
@property (weak, nonatomic) IBOutlet UIButton *btnCopy;       //复制按钮
@property (weak, nonatomic) IBOutlet UITableView *tabReferral;//已经邀请的好友列表

@property (weak, nonatomic) IBOutlet UILabel *lblReferralTips;//邀请好友说明

@property (weak, nonatomic) IBOutlet UIButton *btnInvite;     //立刻邀请按钮

@property (weak, nonatomic) IBOutlet UIView *emptyView;       //空白view


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabReferralHeight;//已邀请好友列表高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyViewHeight;  //空白view高度


//点击复制邀请码到系统剪切板
- (IBAction)buttonToCopyCodeAction:(UIButton *)sender;
//点击立刻邀请好友
- (IBAction)buttonToInviteNowAction:(UIButton *)sender;


@end
