//
//  SilkNewReferralViewController.m
//  OSell
//
//  Created by xlg on 2018/8/28.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "SilkNewReferralViewController.h"

#import "NSString+Extension.h"
#import "UILabel+Extension.h"
#import "UIScrollView+Extension.h"
#import "SilkNewReferralCell.h"
#import "SilkInviteModeCell.h"
#import "CYWShareView.h"
#import "SilkNewReferralPopView.h"
#import "OSellWebViewController.h"
#import "SilkReferralDetailViewController.h"

@interface SilkNewReferralViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (assign, nonatomic) BOOL isDragging;
@property (assign, nonatomic) BOOL needScroll;
@property (assign, nonatomic) CGFloat tabCellHeight;
@property (strong, nonatomic) NSDictionary *shareDict;
@property (strong, nonatomic) NSMutableArray *arrInvite;
@property (strong, nonatomic) SilkNewReferralModel *referralModel;

@end

@implementation SilkNewReferralViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self getString:@"NewReferral_Title"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDatas];
    [self layoutViews];
    [self requestGetShareContents:NO];
    //[self setupNavRightButtonForNewsList];
}
//初始化数据
- (void)setupDatas {
    self.isDragging = NO;
    [self setupInviteModes];
}
//设置UI
- (void)layoutViews {
    WS(weakSelf);
    
    self.topViewHeight.constant = StatusHeight + 44;
    self.contentView.hidden = YES;
    self.btnInviteMode.hidden = YES;
    self.btnInviteModeBView.hidden = YES;
    self.helpTipBView.hidden = YES;
    [self.totalRewardView setupCornerRadius:12];
    [self.btnInviteModeView setupCornerRadius:self.btnInviteMode.frame.size.height];
    self.lblTitle.text = [self getString:@"NewReferral_Title"];
    
    NSString *curLanguage = [InternationalizationHelper getCurLanguage];
    if ([curLanguage isEqualToString:@"en"] && SCREEN_WIDTH < 414) {
        self.topView.hidden = YES;
        self.topView2.hidden = NO;
        self.topBViewHeight.constant = 80;
    } else {
        self.topView.hidden = NO;
        self.topView2.hidden = YES;
        self.topBViewHeight.constant = 50;
    }
    if ([curLanguage isEqualToString:@"en"]) {
        self.imgHelpViewEN.hidden = NO;
        self.imgHelpViewCN.hidden = YES;
        /*
        if (SCREEN_WIDTH == 320) {
            self.layout_DetailImgTop.constant = 40;
        } else if (SCREEN_WIDTH == 375) {
            self.layout_DetailImgTop.constant = 24;
        } else if {
            self.layout_DetailImgTop.constant = 24;
        }//*/
    } else {
        self.imgHelpViewEN.hidden = YES;
        self.imgHelpViewCN.hidden = NO;
    }
    [self setupTexts];
    
    [self.collList registerNib:[UINib nibWithNibName:@"SilkNewReferralCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"SilkNewReferralCell"];
    [self.tabInvite registerNib:[UINib nibWithNibName:@"SilkInviteModeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SilkInviteModeCell"];
    
    [self.bGView setupRefresh:^{
        [weakSelf requestGetReferralInfo];
    }];
    [self.bGView.header beginRefreshing];
    [self adjustmentEmptyViewHeight];
}
//攻略按钮
- (void)setupNavRightButtonForNewsList {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button setTitle:[self getString:@"NewReferral_Guide"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonToNavRightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
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
        weakSelf.weeklyRankingBgImgHeight.constant = weakSelf.referralListView.height;
        
        //判断是否需要调整
        if (weakSelf.tabInvite.frame.origin.y < weakSelf.bGView.frame.size.height) {
            weakSelf.btnInviteModeTop.constant = self.tabInvite.frame.origin.y;
        } else {
            weakSelf.btnInviteModeTop.constant = weakSelf.bGView.frame.size.height - weakSelf.btnInviteMode.frame.size.height;
        }
        
        NSString *strRewardTips2 = [weakSelf getString:@"NewReferral_ReferLimit"];
        CGFloat rewardTips2Width = [strRewardTips2 getWidth:50 fontSize:12] + 1;
        if (rewardTips2Width > (weakSelf.imgReferralTips.frame.origin.x - 30 - 35)) {
            rewardTips2Width = weakSelf.imgReferralTips.frame.origin.x - 30 - 35;
        }
        weakSelf.lblRewardTips2.text = strRewardTips2;
        weakSelf.lblRewardTips2Width.constant = rewardTips2Width;
    });
}
//设置中英文
- (void)setupTexts {
    self.lblTopOneT.text = [self getString:@"NewReferral_ReferFriends"];
    self.lblTopTwoT.text = [self getString:@"NewReferral_FriendsMining"];
    self.lblTopThreeT.text = [self getString:@"NewReferral_GetRewards"];
    self.lblTopOneT2.text = [self getString:@"NewReferral_ReferFriends"];
    self.lblTopTwoT2.text = [self getString:@"NewReferral_FriendsMining"];
    self.lblTopThreeT2.text = [self getString:@"NewReferral_GetRewards"];
    self.lblThisWeekList.text = [self getString:@"NewReferral_WeeklyRanking"];
    self.lblRewardTips.text = [self getString:@"NewReferral_RewardCondition"];
    self.lblRewardTips1.text = [self getString:@"NewReferral_ReferOneFriend"];
    [self.btnDetail setTitle:[self getString:@"NewReferral_Detail"] forState:UIControlStateNormal];
    self.lblInvitedTitle.text = [self getString:@"NewReferral_Refered"];
    self.lblSilkRewardTitle.text = [self getString:@"NewReferral_SilkReward"];
    self.lblPowerRewardTitle.text = [self getString:@"NewReferral_PowerReward"];
    NSString *strInviteMode = [self getString:@"NewReferral_ReferMethod"];
    [self.btnInviteMode setTitle:strInviteMode forState:UIControlStateNormal];
    self.btnInviteModeWidth.constant = [strInviteMode getWidth:32 fontSize:15] + 80;
}

#pragma mark - 按钮事件
//返回按钮事件
- (IBAction)buttonToNavLeftAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//跳转攻略
- (void)buttonToNavRightButtonAction:(id)sender {
    
}
//详情按钮事件
- (IBAction)buttonToDetailAction:(UIButton *)sender {
    SilkReferralDetailViewController *vc = [SilkReferralDetailViewController new];
    [self pushController:vc];
}
//点击跳转详情页面
- (IBAction)tapToDetailAction:(UITapGestureRecognizer *)sender {
    [self buttonToDetailAction:nil];
}
//攻略(问号)按钮事件
- (IBAction)buttonToStrategyAction:(UIButton *)sender {
    self.helpTipBView.hidden = NO;
    self.helpTipBView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.helpTipBView.alpha = 1.0;
    }];
}
//展示邀请方式按钮事件
- (IBAction)buttonToShowInviteModesAction:(UIButton *)sender {
    if (self.isDragging) {
        self.needScroll = YES;
        return;
    }
    [self moveBtnInviteModeAndBGView];
}

- (IBAction)tapToHiddenHelpView:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.helpTipBView.alpha = 0;
    } completion:^(BOOL finished) {
        self.helpTipBView.hidden = YES;
    }];
}
//移动邀请方式按钮和背景view偏移
- (void)moveBtnInviteModeAndBGView {
    self.needScroll = NO;
    CGFloat offsetY = self.bGView.contentOffset.y;
    CGFloat needOffsetY = self.bGView.contentSize.height - self.bGView.frame.size.height;
    if (needOffsetY == offsetY) {
        return;
    }
    WS(weakSelf);
    self.isDragging = NO;
    self.btnInviteModeTop.constant = self.bGView.frame.size.height - (self.bGView.contentSize.height - self.tabInvite.frame.origin.y) - self.btnInviteMode.frame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        [weakSelf.view layoutIfNeeded];
        [weakSelf.bGView setContentOffset:CGPointMake(0, needOffsetY)];
    }];
}

#pragma mark - 网络请求
//网络请求邀请信息
- (void)requestGetReferralInfo {
    WS(weakSelf);
    SilkLoginUserModel *user = [[SilkLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@Account/XXXXXXXXX", [[SilkServerConfig shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"Lan"];
    [param setObject:@"IOS" forKey:@"Source"];
    [param setObject:user.userId forKey:@"UserID"];
    
    [[SilkHttpServerHelper shareInstance] requestHTTPDataWithAPI:apiUrl andHeader:nil andBody:param andSuccessBlock:^(SilkAPIResult *apiResult) {
        [weakSelf.bGView endRefreshAndLoadMore];
        if (apiResult.apiCode == 0) {
            [weakSelf handleNewReferralInfo:apiResult.dataResult];
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(SilkAPIResult *apiResult) {
        [weakSelf.bGView endRefreshAndLoadMore];
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(SilkAPIResult *apiResult) {
        [weakSelf.bGView endRefreshAndLoadMore];
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(SilkAPIResult *apiResult) {
        [weakSelf pushToLoginVC:NO];
        [weakSelf.bGView endRefreshAndLoadMore];
    }];
}
//网络请求分享文案
- (void)requestGetShareContents:(BOOL)isShare {
    WS(weakSelf);
    SilkLoginUserModel *user = [[SilkLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@Service/XXXXXXXXX", [[SilkServerConfig shareInstance] addressForBaseAPI]];
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
            weakSelf.shareDict = apiResult.dataResult;
            weakSelf.referralModel.inviteLink = [weakSelf.shareDict stringForKey:@"SourceUrl"];
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
//处理返回数据
- (void)handleNewReferralInfo:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if (self.contentView.hidden) {
        self.contentView.hidden = NO;
        self.btnInviteMode.hidden = NO;
        self.btnInviteModeBView.hidden = NO;
    }
    self.referralModel = [SilkNewReferralModel modelWithDict:dict];
    [self.collList reloadData];
    self.lblMinReward.text = [NSString stringWithFormat:@"%@%@%@", [self getString:@"NewReferral_MinReward1"], self.referralModel.MinAmount, [self getString:@"NewReferral_MinReward2"]];
    [self setupHighestSilk:[self.referralModel.RewardMultiple.firstObject intValue]];
    [self setupThisWeekInvitedCount:self.referralModel.InviteNumByWeek percent:self.referralModel.Percent];
    [self setupDistributedCount:self.referralModel.TotalRewardAmount];
    
    SilkAwardModel *indirectM;
    SilkAwardModel *selfInviteM;
    SilkAwardModel *oneModel = [self.referralModel.AwardList firstObject];
    if ([oneModel.TypeName isEqualIgnoreCase:@"indirect"]) {
        indirectM = oneModel;
        selfInviteM = [self.referralModel.AwardList lastObject];
    } else {
        selfInviteM = oneModel;
        indirectM = [self.referralModel.AwardList lastObject];
    }
    self.lblInvitedCount.text = [NSString stringWithFormat:@"%@%@", selfInviteM.UserNum, [self getString:@"NewReferral_PeopleCount"]];
    self.lblSilkRewardCount.text = selfInviteM.Amount;
    self.lblPowerRewardCount.text = selfInviteM.Power;
    [self setupInvitedCount:indirectM.UserNum];
    [self setupRewardSilkOrPower:YES count:indirectM.Amount];
    [self setupRewardSilkOrPower:NO count:indirectM.Power];
    
    WS(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.weeklyRankingBgImgHeight.constant = weakSelf.referralListView.height;
    });
}
//处理网络返回分享内容
- (void)shareThirdPlatform {
    if (![self.shareDict isKindOfClass:[NSDictionary class]]) {
        [self requestGetShareContents:YES];
        return;
    }
    NSString *shareTitle = [self.shareDict stringForKey:@"Title"];
    if (shareTitle.length == 0) {
        shareTitle = @"SilkAll";
    }
    NSString *shareContent = [self.shareDict stringForKey:@"Content"];
    NSString *shareImageUrl = [self.shareDict stringForKey:@"ImageUrl"];
    if (shareImageUrl.length < 4) {
        shareImageUrl = [[NSBundle mainBundle] pathForResource:@"login_icon120"ofType:@"png"];
    }
    NSString *shareUrl = [self.shareDict stringForKey:@"SourceUrl"];
    
    NSString *nowlanguage = [InternationalizationHelper getLocalizeion];
    if ([nowlanguage isEqualToString:LOCALIZATOIN_CHINESE]) { //中文版本
        //构造分享内容
        [CYWShareView cywShowWithTypeArr:@[@(SSDKPlatformSubTypeWechatSession), @(SSDKPlatformSubTypeWechatTimeline)] withShareTitle:shareTitle withShareText:shareContent withShareImgPath:shareImageUrl withShareUrlPath:shareUrl andOtherData:nil];
    } else {
        //构造分享内容
        [OSellShareModel showWithText:shareContent imagePath:shareImageUrl url:shareUrl title:shareTitle];
    }
}

#pragma mark - UIScrollView 协议
//UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isDragging && scrollView == self.bGView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat tabInviteY = self.tabInvite.frame.origin.y;
        CGFloat buttonTop =  self.bGView.frame.size.height - self.btnInviteMode.frame.size.height;
        if (tabInviteY - offsetY < self.bGView.frame.size.height) {
            buttonTop = tabInviteY - offsetY - self.btnInviteMode.frame.size.height;
        }
        self.btnInviteModeTop.constant = buttonTop;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.bGView) {
        self.isDragging = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.bGView && decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.bGView) {
        self.isDragging = NO;
        if (self.needScroll) {
            [self moveBtnInviteModeAndBGView];
        }
    }
}

#pragma mark - UITableView 协议
//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrInvite.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SilkInviteModeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SilkInviteModeCell"];
    SilkInviteModeModel *model = [self.arrInvite objectAtIndex:indexPath.row];
    [cell setupInviteModeInfo:model];
    return cell;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tabCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strLink = self.referralModel.inviteLink;
    if (self.shareDict) {
        strLink = [self.shareDict stringForKey:@"SourceUrl"];
    }
    switch (indexPath.row) {
        case 0:{//二维码扫描
            [SilkNewReferralPopView showWithUrl:strLink silk:self.referralModel.AmountByWeek isScan:YES];
        }
            break;
        case 1:{//链接分享
            [SilkNewReferralPopView showWithUrl:strLink silk:self.referralModel.AmountByWeek isScan:NO];
        }
            break;
        case 2:{//Share
            [self shareThirdPlatform];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UICollectionView 协议
//UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SilkInviteRankModel *model = nil;
    SilkNewReferralCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SilkNewReferralCell" forIndexPath:indexPath];
    if (indexPath.item < self.referralModel.InviteRankList.count) {
        model = [self.referralModel.InviteRankList objectAtIndex:indexPath.item];
        model.sort = indexPath.item + 1;//coding
    }
    int times = 1;
    if (indexPath.item < self.referralModel.RewardMultiple.count) {
        times = [[self.referralModel.RewardMultiple objectAtIndex:indexPath.item] intValue];
    }
    [cell setupReferralListInfo:model times:times];
    return cell;
}

//UICollectionViewDelegate

//UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 128);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

#pragma mark - 设置属性文本
//最高获得 XX SILK
- (void)setupHighestSilk:(int)times {
    self.lblHighest.text = [self getString:@"NewReferral_HighestReward1"];
    self.lblRewardT.text = [self getString:@"NewReferral_HighestReward2"];
    NSString *curLanguage = [InternationalizationHelper getCurLanguage];
    NSString *imageName = [NSString stringWithFormat:@"new_ref_timesT%d", times];
    if ([curLanguage isEqualToString:@"en"]) {
        imageName = [NSString stringWithFormat:@"new_ref_times%d", times];
    }
    self.imgHighest.image = [UIImage imageNamed:imageName];
}
//您本周已成功邀请X人，超过了全球X%的用户
- (void)setupThisWeekInvitedCount:(NSString *)count percent:(NSString *)percent {
    NSString *strText = [NSString stringWithFormat:@"%@%@%@%@%@", [self getString:@"NewReferral_YourReferInfo1"], count, [self getString:@"NewReferral_YourReferInfo2"], percent, [self getString:@"NewReferral_YourReferInfo3"]];
    NSRange range1 = [strText rangeOfString:count];
    NSRange range2 = [strText rangeOfString:percent];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:strText];
    [attrText addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(247, 59, 84) range:range1];
    [attrText addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(247, 59, 84) range:range2];
    self.lblReferralInfo.attributedText = attrText;
}
//已发放奖励
- (void)setupDistributedCount:(NSString *)count {
    NSString *strText = [NSString stringWithFormat:@"%@%@%@", [self getString:@"NewReferral_Distributed1"], count, [self getString:@"NewReferral_Distributed2"]];
    self.lblTotalReward.text = strText;
}
//设置已邀请好友人数
- (void)setupInvitedCount:(NSString *)count {
    NSString *strText = [NSString stringWithFormat:@"%@%@%@", [self getString:@"NewReferral_ReRefered1"], count, [self getString:@"NewReferral_ReRefered2"]];
    NSRange range = [strText rangeOfString:count];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:strText];
    [attrText addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(42, 129, 200) range:range];
    self.lblTwoInvitedCount.attributedText = attrText;
}
//设置Silk奖励和算力奖励数量
- (void)setupRewardSilkOrPower:(BOOL)isSilk count:(NSString *)count {
    NSString *strText = [NSString stringWithFormat:@"%@%@", [self getString:@"NewReferral_AdditionalReward"], count];
    if (isSilk) {
        strText = [NSString stringWithFormat:@"%@%@", [self getString:@"NewReferral_AdditionalPower"], count];
    }
    NSRange range = [strText rangeOfString:count];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:strText];
    [attrText addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(42, 129, 200) range:range];
    if (isSilk) {
        self.lblTwoSilkRewardCount.attributedText = attrText;
    } else {
        self.lblTwoPowerRewardCount.attributedText = attrText;
    }
}

#pragma mark - 其他
//邀请方式
- (NSMutableArray *)arrInvite {
    if (!_arrInvite) {
        _arrInvite = [NSMutableArray array];
    }
    return _arrInvite;
}
//设置邀请方式 model
- (void)setupInviteModes {
    self.tabCellHeight = 80.0;
    SilkInviteModeModel *model1 = [SilkInviteModeModel modelWithImage:@"new_ref_qrCode" name:[self getString:@"NewReferral_QRCode"] desc:[self getString:@"NewReferral_QRCodeT"]];
    SilkInviteModeModel *model2 = [SilkInviteModeModel modelWithImage:@"new_ref_link" name:[self getString:@"NewReferral_WebLink"] desc:[self getString:@"NewReferral_WebLinkT"]];
    SilkInviteModeModel *model3 = [SilkInviteModeModel modelWithImage:@"new_ref_share" name:[self getString:@"NewReferral_Share"] desc:[self getString:@"NewReferral_ShareT"] isLast:YES];
    [self.arrInvite addObjectsFromArray:@[model1, model2, model3]];
    self.tabInviteHeight.constant = self.arrInvite.count * self.tabCellHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


