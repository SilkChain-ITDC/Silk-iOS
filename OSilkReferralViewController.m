//
//  OSilkReferralViewController.m
//  OSell
//
//  Created by xlg on 2018/5/29.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "OSilkReferralViewController.h"

#import "Masonry.h"
#import "UILabel+Extension.h"
#import "OSilkReferralCell.h"
#import "AddNewFriendVC.h"
#import "CYWShareView.h"

@interface OSilkReferralViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSString *referralCode;
    NSMutableArray *arrList;
    NSDictionary *shareDict;
}

@end

@implementation OSilkReferralViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self getString:@"Silk_Referral"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDatas];
    [self layoutViews];
    [self setBackButton];
    [self requestGetReferralInfo];
    [self requestGetShareContents:NO];
}
//初始化数据
- (void)setupDatas {
    arrList = [NSMutableArray array];
}
//设置UI
- (void)layoutViews {
    if (self.silkInfo) {
        self.lblReferralCode.text = self.silkInfo.AffiliateCode;
    }
    [self.btnCopy setupCornerRadius:16.0];
    [self.btnInvite setupCornerRadius:22.0];
    [self.btnCopy setupBorderColor:RGBCOLOR(40, 130, 200)];
    [self adjustmentEmptyViewHeight];
    [self.tabReferral registerNib:[UINib nibWithNibName:@"OSilkReferralCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"OSilkReferralCell"];
    
    self.lblCodeTips.text = [self getString:@"Referral_YourCode"];
    [self.btnCopy setTitle:[self getString:@"Silk_Copy"] forState:UIControlStateNormal];
    NSString *strTips = [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@", [self getString:@"Referral_Desc1"], [self getString:@"Referral_Desc2"], [self getString:@"Referral_Desc3"], [self getString:@"Referral_Desc4"]];
    self.lblReferralTips.text = strTips;
    NSString *strSubTips = [self getString:@"Referral_Attention"];
    [self.lblReferralTips setupAttributeText:strTips subStr:strSubTips subColor:[UIColor redColor]];
    [self.btnInvite setTitle:[self getString:@"Silk_InviteNow"] forState:UIControlStateNormal];
}
//调整空视图的高度
- (void)adjustmentEmptyViewHeight {
    WS(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat offset = weakSelf.bGView.frame.size.height - weakSelf.emptyView.frame.origin.y;
        if (offset <= 0) {
            offset = 1;
        } else {
            offset = offset + 1;
        }
        weakSelf.emptyViewHeight.constant = offset;
    });
    if (arrList.count == 0) {
        self.tabReferralHeight.constant = 0;
    } else {
        self.tabReferralHeight.constant = 40.0 * arrList.count + 40.0;
    }
}

#pragma mark - 交互事件
//点击复制邀请码到系统剪切板
- (IBAction)buttonToCopyCodeAction:(UIButton *)sender {
    if (referralCode.length == 0) {
        [self requestGetReferralInfo];
    } else {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = referralCode;
        [self makeToast:[self getString:@"Silk_Copied"]];
    }
}
//点击立刻邀请好友
- (IBAction)buttonToInviteNowAction:(UIButton *)sender {
    [self shareThirdPlatform];
}

#pragma mark - 网络请求
//获取邀请信息
- (void)requestGetReferralInfo {
    WS(weakSelf);
    SilkLoginUserModel *user = [[SilkLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@XXXXX", [[SilkServerConfig shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"Lan"];
    [param setObject:user.userId forKey:@"UserID"];
    
    [DZProgress show:[self getString:@"Silk_Loading"]];
    [[SilkHttpServerHelper shareInstance] requestHTTPDataWithAPI:apiUrl andHeader:nil andBody:param andSuccessBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        if (apiResult.apiCode == 0) {
            [weakSelf handleReferralInfo:apiResult.dataResult];
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf pushToLoginVC:NO];
    }];
}
//网络返回处理
- (void)handleReferralInfo:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [arrList removeAllObjects];
    referralCode = [dict stringForKey:@"AffiliateCode"];
    self.lblReferralCode.text = referralCode;
    
    NSArray *array = [dict objectForKey:@"AwardList"];
    for (NSDictionary *dic in array) {
        OSilkReferralModel *model = [OSilkReferralModel modelWithDict:dic];
        [arrList addObject:model];
    }
    [self.tabReferral reloadData];
    [self adjustmentEmptyViewHeight];
}

//网络请求分享文案
- (void)requestGetShareContents:(BOOL)isShare {
    WS(weakSelf);
    SilkLoginUserModel *user = [[SilkLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@XXXXX", [[SilkServerConfig shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"Lan"];
    [param setObject:user.affiliateCode forKey:@"InviteCode"];
    [param setObject:@"1" forKey:@"ShareType"];
    [param setObject:user.userName forKey:@"UserName"];
    
    if (isShare) {
        [DZProgress show:[self getString:@"Silk_Loading"]];
    }
    [[SilkHttpServerHelper shareInstance] requestHTTPDataWithAPI:apiUrl andHeader:nil andBody:param andSuccessBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        if (apiResult.apiCode == 0) {
            shareDict = apiResult.dataResult;
            if (isShare) {
                [weakSelf shareThirdPlatform];
            }
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf pushToLoginVC:NO];
    }];
}
//处理网络返回分享内容
- (void)shareThirdPlatform {
    if (![shareDict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *shareTitle = [shareDict stringForKey:@"Title"];
    if (shareTitle.length == 0) {
        shareTitle = @"SilkAll";
    }
    NSString *shareContent = [shareDict stringForKey:@"Content"];
    NSString *shareImageUrl = [shareDict stringForKey:@"ImageUrl"];
    if (shareImageUrl.length < 4) {
        shareImageUrl = [[NSBundle mainBundle] pathForResource:@"login_icon120"ofType:@"png"];
    }
    NSString *shareUrl = [shareDict stringForKey:@"SourceUrl"];
    
    NSString *nowlanguage = [InternationalizationHelper getLocalizeion];
    if ([nowlanguage isEqualToString:LOCALIZATOIN_CHINESE]) { //中文版本
        //构造分享内容
        [CYWShareView cywShowWithTypeArr:@[@(SSDKPlatformSubTypeWechatSession), @(SSDKPlatformSubTypeWechatTimeline)] withShareTitle:shareTitle withShareText:shareContent withShareImgPath:shareImageUrl withShareUrlPath:shareUrl andOtherData:nil];
    } else {
        //构造分享内容
        [OSellShareModel showWithText:shareContent imagePath:shareImageUrl url:shareUrl title:shareTitle];
    }
}

#pragma mark - 协议
//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (arrList.count > 0) {
        return arrList.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"OSilkReferralCell";
    OSilkReferralCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (indexPath.row == 0) {
        [cell setupReferralInfo:nil isHeader:YES];
    } else {
        OSilkReferralModel *model = [arrList objectAtIndex:(indexPath.row - 1)];
        [cell setupReferralInfo:model isHeader:NO];
    }
    return cell;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 44.0;
    }
    return 32.0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


