//
//  SilkNewReferralViewController.h
//  OSell
//
//  Created by xlg on 2018/8/28.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "Base.h"

@interface SilkNewReferralViewController : Base

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (weak, nonatomic) IBOutlet UIScrollView *bGView;//背景view
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *lblTopOneT;//邀请好友
@property (weak, nonatomic) IBOutlet UILabel *lblTopTwoT;//好友挖矿
@property (weak, nonatomic) IBOutlet UILabel *lblTopThreeT;//我拿奖励

@property (weak, nonatomic) IBOutlet UIView *topView2;
@property (weak, nonatomic) IBOutlet UILabel *lblTopOneT2;//邀请好友
@property (weak, nonatomic) IBOutlet UILabel *lblTopTwoT2;//好友挖矿
@property (weak, nonatomic) IBOutlet UILabel *lblTopThreeT2;//我拿奖励

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBViewHeight;


@property (weak, nonatomic) IBOutlet UIView *referralListView;//邀请榜单背景view
@property (weak, nonatomic) IBOutlet UILabel *lblThisWeekList;//本周榜单
@property (weak, nonatomic) IBOutlet UILabel *lblHighest;//最高获得
@property (weak, nonatomic) IBOutlet UIImageView *imgHighest;//最高倍数
@property (weak, nonatomic) IBOutlet UILabel *lblRewardT;//奖励
@property (weak, nonatomic) IBOutlet UILabel *lblReferralInfo;//用户本周邀请情况简述
@property (weak, nonatomic) IBOutlet UICollectionView *collList;//邀请好友榜单列表
@property (weak, nonatomic) IBOutlet UIView *totalRewardView;//已发放奖励背景view
@property (weak, nonatomic) IBOutlet UILabel *lblTotalReward;//已发放奖励
@property (weak, nonatomic) IBOutlet UILabel *lblRewardTips;//仅计入直接邀请的好友数(XX)

@property (weak, nonatomic) IBOutlet UIView *referralInfoView;//邀请奖励说明和用户邀请情况
@property (weak, nonatomic) IBOutlet UIImageView *imgReferralTips;//图片
@property (weak, nonatomic) IBOutlet UILabel *lblRewardTips1;//每邀请1位好友
@property (weak, nonatomic) IBOutlet UILabel *lblMinReward;//最低奖励70SILK
@property (weak, nonatomic) IBOutlet UILabel *lblRewardTips2;//邀请无上限 奖励不封顶
@property (weak, nonatomic) IBOutlet UIButton *btnDetail;//详情按钮
@property (weak, nonatomic) IBOutlet UILabel *lblInvitedTitle;//已邀请好友
@property (weak, nonatomic) IBOutlet UILabel *lblSilkRewardTitle;//Silk奖励
@property (weak, nonatomic) IBOutlet UILabel *lblPowerRewardTitle;//算力奖励
@property (weak, nonatomic) IBOutlet UILabel *lblInvitedCount;//已邀请好友数量
@property (weak, nonatomic) IBOutlet UILabel *lblSilkRewardCount;//Silk奖励数量
@property (weak, nonatomic) IBOutlet UILabel *lblPowerRewardCount;//算力奖励数量
@property (weak, nonatomic) IBOutlet UILabel *lblTwoInvitedCount;//好友再邀请数量
@property (weak, nonatomic) IBOutlet UILabel *lblTwoSilkRewardCount;//额外奖励数量
@property (weak, nonatomic) IBOutlet UILabel *lblTwoPowerRewardCount;//算力加成数量

@property (weak, nonatomic) IBOutlet UIView *btnInviteModeBView;
@property (weak, nonatomic) IBOutlet UIView *btnInviteModeView;//邀请方式按钮背景view
@property (weak, nonatomic) IBOutlet UIButton *btnInviteMode;//邀请方式按钮
@property (weak, nonatomic) IBOutlet UITableView *tabInvite;//邀请方式列表
@property (weak, nonatomic) IBOutlet UIView *emptyView;

@property (weak, nonatomic) IBOutlet UIView *helpTipBView;
@property (weak, nonatomic) IBOutlet UIImageView *imgHelpViewEN;
@property (weak, nonatomic) IBOutlet UIImageView *imgHelpViewCN;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weeklyRankingBgImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblRewardTips2Width;//邀请无上限 奖励不封顶标签宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabInviteHeight;//邀请方式列表高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnInviteModeTop;//邀请方式按钮距底部位置
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnInviteModeWidth;//邀请方式按钮宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHelpViewRatio;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_DetailImgTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;


- (IBAction)buttonToNavLeftAction:(UIButton *)sender;
//详情按钮事件
- (IBAction)buttonToDetailAction:(UIButton *)sender;
- (IBAction)tapToDetailAction:(UITapGestureRecognizer *)sender;
//攻略(问号)按钮事件
- (IBAction)buttonToStrategyAction:(UIButton *)sender;
//展示邀请方式按钮事件
- (IBAction)buttonToShowInviteModesAction:(UIButton *)sender;

- (IBAction)tapToHiddenHelpView:(id)sender;

@end


