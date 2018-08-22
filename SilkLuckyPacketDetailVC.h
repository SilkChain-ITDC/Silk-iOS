//
//  SilkLuckyPacketDetailVC.h
//  OSell
//
//  Created by xlg on 2018/6/5.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "Base.h"

@interface SilkLuckyPacketDetailVC : Base


@property (assign, nonatomic) BOOL isRedPacketDetail;
@property (copy, nonatomic) NSString *packetId;


@property (weak, nonatomic) IBOutlet UIScrollView *bGView;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *userHead;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblNameSuffix;
@property (weak, nonatomic) IBOutlet UILabel *lblPingTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBestWidhes;
@property (weak, nonatomic) IBOutlet UILabel *lblSilk;
@property (weak, nonatomic) IBOutlet UILabel *lblSilkUnit;
@property (weak, nonatomic) IBOutlet UIView *btnSharingView;
@property (weak, nonatomic) IBOutlet UILabel *lblSharingTitle;
@property (weak, nonatomic) IBOutlet UIView *btnShareView;
@property (weak, nonatomic) IBOutlet UILabel *lblShareTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBottomTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblMiddleTips;

@property (weak, nonatomic) IBOutlet UITableView *tabList;

@property (weak, nonatomic) IBOutlet UIView *emptyView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleTipsViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyViewHeight;


//返回上个页面按钮事件
- (IBAction)buttonToBackAction:(UIButton *)sender;
//第一个按钮
- (IBAction)tapToSharingAction:(UITapGestureRecognizer *)sender;
//第二个分享红包按钮
- (IBAction)tapToShareAction:(UITapGestureRecognizer *)sender;


@end


