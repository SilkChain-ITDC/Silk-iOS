//
//  OSilkPowerViewController.m
//  OSell
//
//  Created by xlg on 2018/4/2.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "OSilkPowerViewController.h"

#import "Masonry.h"
#import "UIViewController+Extension.h"
#import "OSilkPowerTaskCell.h"
#import "OSilkOpenBoxView.h"

#import "OSilkPowerRankingVC.h"
#import "OSellWebViewController.h"
#import "OSellNewScoreSearchViewController.h"
#import "OSellInviteToRegisterViewController.h"
#import "OSellOpenWalletAgreementVC.h"
#import "OSellAuthenticationCipherViewController.h"
#import "MyPorfile.h"
#import "OSellProductCentreVC.h"
#import "OSellBalanceTopUpVC.h"


@interface OSilkPowerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    CGFloat cellWidth; //获取Power任务列表cell的宽度
    CGFloat cellHeight;//获取Power任务列表cell的高度
    NSMutableArray *arrTask;//获取Power任务
}

@end

@implementation OSilkPowerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self getString:@"SilkPower"];
    [self requestGetSilkUserInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDatas];
    [self layoutViews];
    [self setBackButton];
    [self setBarButton:@"img_join_help.png" frame:CGRectMake(0, 0, 20, 20) isright:YES];
    [self requestGetSilkPowerActivities];
}
//初始化数据
- (void)setupDatas {
    cellWidth = SCREEN_WIDTH / 3.0;
    cellHeight = 140.0;
    arrTask = [NSMutableArray array];
}
//设置UI
- (void)layoutViews {
    if (self.silkInfo) {
        [self handleSilkUserInfo:nil];
    }
    [self.collList registerNib:[UINib nibWithNibName:@"OSilkPowerTaskCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"OSilkPowerTaskCell"];
}
//调整空视图的高度
- (void)adjustmentEmptyViewHeight {
    WS(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat offset = weakSelf.bGView.frame.size.height - weakSelf.emptyView.frame.origin.y;
        if (offset <= 0) {
            offset = 1;
        } else {
            offset = offset + 1;
        }
        weakSelf.emptyViewHeight.constant = offset;
    });
}

#pragma mark - 交互事件
//导航栏右边按钮事件
- (void)rightBarButtonClick:(UIButton *)sender {
    OSellWebViewController *vc = [OSellWebViewController new];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",[[OSellServerHelper shareInstance] addressForBaseAPI], @"About/SilkIntro"];
    vc.strUrl = strUrl;
    vc.strTitle = @"SilkChain";
    [self pushController:vc];
}
//SilkPower
- (IBAction)tapToSilkPowerAction:(UITapGestureRecognizer *)sender {
    OSellNewScoreSearchViewController *vc = [OSellNewScoreSearchViewController new];
    vc.fromType = @"2";
    [self pushController:vc];
}
//Ranking
- (IBAction)tapToCheckRankingAction:(UITapGestureRecognizer *)sender {
    OSilkPowerRankingVC *vc = [OSilkPowerRankingVC new];
    [self pushController:vc];
}

#pragma mark - 网络请求
//获取Silk用户信息
- (void)requestGetSilkUserInfo {
    WS(weakSelf);
    OSellUserModel *user = [[OSellLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@/DragonSilk/GetSilkUserInfo", [[OSellServerHelper shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"lan"];
    [param setObject:user.userId forKey:@"UserID"];
    
    [[OSellHTTPHelper shareInstance] requestHTTPDataWithAPI:apiUrl andParams:param andSuccessBlock:^(OSellAPIResult *apiResult) {
        if (apiResult.apiCode == 0) {
            [weakSelf handleSilkUserInfo:apiResult.dataResult];
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(OSellAPIResult *apiResult) {
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        [weakSelf pushToLoginVC:NO];
    }];
}
//网络请求获取任务列表
- (void)requestGetSilkPowerActivities {
    WS(weakSelf);
    OSellUserModel *user = [[OSellLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@/DragonSilk/GetSilkActivityList", [[OSellServerHelper shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"lan"];
    [param setObject:@"2" forKey:@"Type"];
    [param setObject:@"1" forKey:@"PageIndex"];
    [param setObject:@"20" forKey:@"PageSize"];
    [param setObject:user.userId forKey:@"UserID"];
    
    [DZProgress show:[self getString:@"Loading"]];
    [[OSellHTTPHelper shareInstance] requestHTTPDataWithAPI:apiUrl andParams:param andSuccessBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        if (apiResult.apiCode == 0) {
            [weakSelf handleSilkPowerActivities:apiResult.dataResult];
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        [weakSelf pushToLoginVC:NO];
    }];
}
//网络请求获取每日登陆奖励
- (void)requestGetTreasureBox {
    WS(weakSelf);
    OSellUserModel *user = [[OSellLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@/DragonSilk/OpenTreasureBox", [[OSellServerHelper shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"lan"];
    [param setObject:user.userId forKey:@"UserID"];
    
    [DZProgress show:[self getString:@"Loading"]];
    [[OSellHTTPHelper shareInstance] requestHTTPDataWithAPI:apiUrl andParams:param andSuccessBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        if (apiResult.apiCode == 0) {
            [weakSelf handleOpenTreasureBox:apiResult.dataResult];
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        [weakSelf pushToLoginVC:NO];
    }];
}

//处理获取 Power 的活动列表
- (void)handleSilkPowerActivities:(NSArray *)array {
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    [arrTask removeAllObjects];
    for (NSDictionary *dict in array) {
        OSilkPowerTaskModel *model = [OSilkPowerTaskModel modelWithDict:dict];
        [arrTask addObject:model];
    }
    NSInteger lines = arrTask.count / 3;
    if (arrTask.count % 3 != 0) {
        lines = lines + 1;
    }
    self.collListHeight.constant = cellHeight * lines;
    [self.collList reloadData];
    [self adjustmentEmptyViewHeight];
}
//处理Silk用户信息
- (void)handleSilkUserInfo:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        self.silkInfo = [OSilkInfoModel modelWithDict:dict];
    }
    self.lblSilkPower.text = [NSString stringWithFormat:@"%@ : %@", [self getString:@"SilkPower"], self.silkInfo.TotalPower];
    self.lblRanking.text = [NSString stringWithFormat:@"%@ : %@", [self getString:@"Your Current Ranking"], self.silkInfo.PowerRankNum];
}
//处理开宝箱返回数据
- (void)handleOpenTreasureBox:(id)value {
    NSString *strPower = [NSString stringWithFormat:@"%@", value];
    if (strPower.integerValue == 0) {
        [self makeToast:[self getString:@"You've already received today's login rewards."]];
    } else {
        WS(weakSelf);
        __block OSilkPowerTaskModel *openModel;
        for (OSilkPowerTaskModel *model in arrTask) {
            if (model.SilkActivityType == 4) {
                openModel = model;
                break;
            }
        }
        [OSilkOpenBoxView showWithTitle:openModel.ActivityName value:value block:^{
            openModel.IsComplete = YES;
            [weakSelf.collList reloadData];
            
            NSString *strValue = [NSString stringWithFormat:@"%@", value];
            NSInteger totalPower = weakSelf.silkInfo.TotalPower.integerValue + strValue.integerValue;
            weakSelf.silkInfo.TotalPower = [NSString stringWithFormat:@"%d", (int)totalPower];
            weakSelf.lblSilkPower.text = [NSString stringWithFormat:@"%@ : %@", [weakSelf getString:@"SilkPower"], weakSelf.silkInfo.TotalPower];
        }];
    }
}

#pragma mark - 协议
//UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return arrTask.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OSilkPowerTaskCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OSilkPowerTaskCell" forIndexPath:indexPath];
    OSilkPowerTaskModel *model = [arrTask objectAtIndex:indexPath.item];
    [cell setupSilkPowerTaskInfo:model];
    [cell setupLineWithIndex:indexPath.item];
    return cell;
}

//UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL jumpToWeb = NO;
    OSilkPowerTaskModel *model = [arrTask objectAtIndex:indexPath.item];
    switch (model.SilkActivityType) {
        case 1:{//用户注册
            //纯展示
        }
            break;
        case 2:{//钱包付款
            //弹框展示
            [self alertWithMessage:[self getString:@"20-50 SilkPower Randomly \n Up to once a day"] sureTitle:[self getString:@"Got it"]];
        }
            break;
        case 3:{//绑定银行卡
            //跳转钱包绑卡页面
            if ([[OSellLoginUserHelper shareInstance] getCurUserInfo].isOpenedWallet) {
                //绑定银行卡
                OSellAuthenticationCipherViewController *vc = [OSellAuthenticationCipherViewController new];
                vc.strComeType = @"1";
                [self pushController:vc];
            } else {
                //开通钱包
                OSellOpenWalletAgreementVC *vc = [OSellOpenWalletAgreementVC new];
                [self pushController:vc];
            }
        }
            break;
        case 4:{//开箱子
            //宝箱动画页
            if (model.IsComplete == NO) {
                [self requestGetTreasureBox];
            }
        }
            break;
        case 5:{//完善个人资料
            //跳转个人资料页面，如果已完成，则用Completed表示，并不可点击
            if (model.IsComplete == NO) {
                MyPorfile *vc = [MyPorfile new];
                [self pushController:vc];
            }
        }
            break;
        case 6:{//购物
            //跳转产品列表页
            NSString *NowHallID = [[NSUserDefaults standardUserDefaults] objectForKey:@"NowHallID"];
            OSellProductCentreVC *vc = [OSellProductCentreVC new];
            vc.strHallID = NowHallID;
            [self pushController:vc];
        }
            break;
        case 7:{//钱包充值
            //跳转钱包现金充值页面
            if ([[OSellLoginUserHelper shareInstance] getCurUserInfo].isOpenedWallet) {
                //钱包充值
                OSellBalanceTopUpVC *vc = [OSellBalanceTopUpVC new];
                [self pushController:vc];
            } else {
                //开通钱包
                OSellOpenWalletAgreementVC *vc = [OSellOpenWalletAgreementVC new];
                [self pushController:vc];
            }
        }
            break;
        case 8:{//邀请注册
            //跳转邀请页面
            OSellInviteToRegisterViewController *vc = [OSellInviteToRegisterViewController new];
            [self pushController:vc];
        }
            break;
        case 9:{//关注
            
            OSellWebViewController *vc = [OSellWebViewController new];
            vc.isFollowUs = YES;
            vc.followUsCompleted = model.IsComplete;
            vc.strTitle = @"";
            vc.strUrl = @"https://t.me/silkchain?start=app";
            [self pushController:vc];
        }
            break;
            
        default:
            jumpToWeb = YES;
            break;
    }
    if (jumpToWeb) {
        if (model.UrlAddress.length > 4) {
            OSellWebViewController *vc = [OSellWebViewController new];
            vc.strUrl = model.UrlAddress;
            [self pushController:vc];
        } else {
            [self makeToast:[self getString:@"Comming soon"]];
        }
    }
}

//UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(cellWidth, cellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //NSLog(@"dealloc");
}


@end


