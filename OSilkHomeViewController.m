//
//  OSilkHomeViewController.m
//  OSell
//
//  Created by xlg on 2018/4/2.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "OSilkHomeViewController.h"

#import "Masonry.h"
#import "UIView+Extension.h"
#import "UILabel+Extension.h"
#import "NSString+Extension.h"
#import "OSilkHomeRecordCell.h"
#import "MarqueeLabel.h"

#import "OSilkPowerViewController.h"
#import "OSilkPowerRankingVC.h"
#import "OSelectItemViewController.h"
#import "OSellWebViewController.h"
#import "OSellSilkCywVC.h"
#import "OSellNewScoreSearchViewController.h"

@interface OSilkHomeViewController () <UITableViewDelegate, UITableViewDataSource>
{
    BOOL isViewAppear;           //该页面是否为当前显示页面
    CGFloat cellHeight;          //收取Silk币记录列表高度
    OSilkInfoModel *silkInfo;    //Silk币的用户信息
    
    NSMutableArray *arrSilks;    //未收取的Silk币数组
    NSMutableArray *arrRecord;   //也收取的Silk币数组 (暂定最新的5个)
    NSMutableArray *arrButton;   //收取Silk按钮的数组
    NSMutableArray *arrAddedSilk;//已显示的Silk币数组
    
    MarqueeLabel *topTips;       //滚动提示文本
}

@end

@implementation OSilkHomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self getString:@"Silk"];
    if (isViewAppear == NO) {
        isViewAppear = YES;
        NSString *strTips = [self getString:@"Silk production will not occupy the memory and battery."];
        [topTips setLabelText:strTips andTheType:NSTextAlignmentLeft WithFrame:CGRectMake(0, 0, topTips.width, self.tipsView.height)];
        [self addSilksViewInOneView];
        [self animationForImgCenter];
    }
    [self requestGetSilkUserInfo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    isViewAppear = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDatas];
    [self layoutViews];
    
    [self requestGetSilksWithIsReceived:YES];
    [self requestGetSilksWithIsReceived:NO];
    
    [self setBackButton];
    [self setBarButton:@"img_join_help.png" frame:CGRectMake(0, 0, 20, 20) isright:YES];
}

#pragma mark - 初始化数据和设置UI
//初始化数据
- (void)setupDatas {
    cellHeight = 32.0;
    arrSilks = [NSMutableArray array];
    arrRecord = [NSMutableArray array];
    arrButton = [NSMutableArray array];
    arrAddedSilk = [NSMutableArray array];
}
//设置UI
- (void)layoutViews {
    [self.silkView setupCornerRadius:16.0];
    [self.imgCenter setupCornerRadius:38.0];
    [self.tabRecords registerNib:[UINib nibWithNibName:@"OSilkHomeRecordCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"OSilkHomeRecordCell"];
    if (@available(iOS 11.0, *)) {
        self.bGView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    /*
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }//*/
    topTips = [[MarqueeLabel alloc] initWithFrame:CGRectMake(36, 0, SCREEN_WIDTH-50, self.tipsView.height) duration:20.0f andFadeLength:1000.0f andTheFont:[UIFont systemFontOfSize:14] andTextColor:RGBCOLOR(51, 51, 51)];
    [self.tipsView addSubview:topTips];
    
    self.tabRecordsHeight.constant = 0;
    self.tabRecordsBottom.constant = 0;
    self.topViewTop.constant = -50;
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
//中间那个大的Silk币上下移动
- (void)animationForImgCenter {
    if (isViewAppear == NO) {
        return;
    }
    WS(weakSelf);
    if (self.imgCenterTop.constant >= 8) {
        self.imgCenterTop.constant = -8;
    } else {
        self.imgCenterTop.constant = 8;
    }
    [UIView animateWithDuration:1.0 animations:^{
        [weakSelf.centerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf animationForImgCenter];
    }];
}

#pragma mark - 添加Silk币
//添加Silk币   40X60
- (void)addSilksViewInOneView {
    if (arrSilks.count == 0) {
        return;
    }
    CGFloat startY = self.powerBView.frame.origin.y + self.powerBView.frame.size.height - 3;
    CGFloat endY = self.buttonView.frame.origin.y;
    CGFloat startCenterX = self.imgCenter.frame.origin.x;
    CGFloat centerWidth = self.imgCenter.frame.size.width;
    CGFloat startCenterY = self.centerView.frame.origin.y;
    
    NSInteger rows = (NSInteger)((endY - startY) / 70.0);
    NSInteger columns = (NSInteger)((self.view.frame.size.width - centerWidth) / 60.0);
    if (columns % 2 != 0) {
        columns = columns - 1;
    }
    NSInteger maxCount = rows * columns;
    if ((startCenterY - startY) > 60) {
        maxCount = maxCount + 1;
    }
    CGFloat silkBWidth = (self.view.frame.size.width - centerWidth) / columns;
    CGFloat silkBHeight = (endY - startY) / rows;
    
    NSMutableArray *arrNumbers = [NSMutableArray array];
    for (NSInteger n = 0; n < maxCount; n++) {
        [arrNumbers addObject:[NSNumber numberWithInteger:n]];
    }
    if (arrSilks.count < maxCount) {
        NSInteger subCount = maxCount - arrSilks.count;
        for (NSInteger m = 0; m < subCount; m++) {
            int subIndex = arc4random() % arrNumbers.count;
            [arrNumbers removeObjectAtIndex:(NSUInteger)subIndex];
        }
    }
    [arrButton removeAllObjects];
    [arrAddedSilk removeAllObjects];
    for (UIView *view in self.oneView.subviews) {
        if (view.tag >= 9999) {
            [view removeFromSuperview];
        }
    }
    for (NSInteger i = 0; i < arrNumbers.count; i++) {
        OSilkProfitModel *model = [arrSilks objectAtIndex:i];
        [arrAddedSilk addObject:model];
        NSInteger position = [[arrNumbers objectAtIndex:i] integerValue];
        
        CGFloat originX = 0;
        CGFloat originY = startY;
        if (((startCenterY - startY) > 60) && (position == (maxCount - 1))) {
            originX = startCenterX + (arc4random() % ((NSInteger)(centerWidth - 40)));
            originY = originY + (arc4random() % ((NSInteger)(startCenterY - startY - 56)));
        } else {
            if (position >= ((columns * rows) / 2)) {
                originX = startCenterX + centerWidth;
                position = position - ((columns * rows) / 2);
            }
            NSInteger line = position / (columns / 2);
            NSInteger item = position % (columns / 2);
            originX = originX + item * silkBWidth + (arc4random() % ((NSInteger)(silkBWidth - 40)));
            originY = originY + line * silkBHeight + (arc4random() % ((NSInteger)(silkBHeight - 56)));
        }
        
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, 40, 40)];
        btnView.tag = 40000 + i;
        btnView.backgroundColor = [UIColor clearColor];
        [self.oneView addSubview:btnView];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.tag = 20000 + i;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"SilkHome_Silks"];
        [btnView addSubview:imageView];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        btn.tag = 30000 + i;
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(buttonToReceiveSilkAction:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:btn];
        
        NSString *str = [NSString stringWithFormat:@"%.3f", model.SilkNum.doubleValue];
        CGFloat lblWidth = [str getWidth:20 fontSize:12] + 2;
        UILabel *lbl = [[UILabel alloc] initWithText:str textColor:[UIColor whiteColor] fontSize:12 alignment:NSTextAlignmentCenter];
        lbl.tag = 10000 + i;
        [lbl setFrame:CGRectMake(originX+(40-lblWidth)/2.0, originY+40, lblWidth, 16)];
        [self.oneView addSubview:lbl];
        [arrButton addObject:btnView];
        [self animateForSilkAction:imageView];
    }
}

//闪烁定时器
- (void)animateForSilkAction:(UIView *)view {
    if (isViewAppear == NO) {
        return;
    }
    NSInteger index = view.tag - 20000;
    UIView *btnView = [self.oneView viewWithTag:(40000 + index)];
    UIButton *btn = [btnView viewWithTag:(30000 + index)];
    if (btn.selected) {
        return;
    }
    WS(weakSelf);
    NSInteger duration = 1.5 + ((arc4random() % 101) / 100.0);
    [UIView animateWithDuration:duration animations:^{
        if (view.alpha <= 0.3) {
            view.alpha = 1.0;
        } else {
            view.alpha = 0.2;
        }
    } completion:^(BOOL finished) {
        [weakSelf animateForSilkAction:view];
    }];
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
//Silk
- (IBAction)tapToSilkTaskAction:(UITapGestureRecognizer *)sender {
    OSellSilkCywVC *vc = [OSellSilkCywVC new];
    [self pushController:vc];
}
//Power
- (IBAction)tapToPowerTaskAction:(UITapGestureRecognizer *)sender {
    OSilkPowerViewController *vc = [OSilkPowerViewController new];
    vc.silkInfo = silkInfo;
    [self pushController:vc];
}
//Increase Power
- (IBAction)buttonToIncreasePowerAction:(UIButton *)sender {
    OSilkPowerViewController *vc = [OSilkPowerViewController new];
    vc.silkInfo = silkInfo;
    [self pushController:vc];
}
//Redeem
- (IBAction)buttonToRedeemAction:(UIButton *)sender {
    [self makeToast:[self getString:@"Comming soon"]];//coding
}
//More Records
- (IBAction)buttonToMoreRecordsAction:(UIButton *)sender {
    OSellNewScoreSearchViewController *vc = [OSellNewScoreSearchViewController new];
    vc.fromType = @"3";
    [self pushController:vc];
}

//收取Silk币
- (void)buttonToReceiveSilkAction:(UIButton *)sender {
    [self requestReceiveSilkWithIndex:(sender.tag - 30000)];
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
    
    [DZProgress show:[self getString:@"Loading"]];
    [[OSellHTTPHelper shareInstance] requestHTTPDataWithAPI:apiUrl andParams:param andSuccessBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        if (apiResult.apiCode == 0) {
            [weakSelf handleSilkUserInfo:apiResult.dataResult];
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
//获取用户Silk生成记录
- (void)requestGetSilksWithIsReceived:(BOOL)isReceived {
    WS(weakSelf);
    OSellUserModel *user = [[OSellLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@/DragonSilk/GetSilkProduceRecord", [[OSellServerHelper shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"lan"];
    [param setObject:@"0" forKey:@"IsReceive"];
    [param setObject:@"100" forKey:@"Top"];
    if (isReceived) {
        [param setObject:@"1" forKey:@"IsReceive"];
        [param setObject:@"5" forKey:@"Top"];//coding
    }
    [param setObject:user.userId forKey:@"UserID"];
    
    //[DZProgress show:[self getString:@"Loading"]];
    [[OSellHTTPHelper shareInstance] requestHTTPDataWithAPI:apiUrl andParams:param andSuccessBlock:^(OSellAPIResult *apiResult) {
        //[DZProgress dismiss];
        if (apiResult.apiCode == 0) {
            [weakSelf handleSilkRecord:apiResult.dataResult isReceived:isReceived];
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(OSellAPIResult *apiResult) {
        //[DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        //[DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        [weakSelf pushToLoginVC:NO];
    }];
}
//收取Silk币
- (void)requestReceiveSilkWithIndex:(NSUInteger)index {
    WS(weakSelf);
    if (index >= arrAddedSilk.count) {
        return;
    }
    OSilkProfitModel *model = [arrAddedSilk objectAtIndex:index];
    NSString *apiUrl = [NSString stringWithFormat:@"%@/DragonSilk/ReceiveSilkProduce", [[OSellServerHelper shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:model.SilkProduceRecordID forKey:@"SilkProduceRecordID"];
    
    [[OSellHTTPHelper shareInstance] requestHTTPDataWithAPI:apiUrl andParams:param andSuccessBlock:^(OSellAPIResult *apiResult) {
        if (apiResult.apiCode == 0) {
            [weakSelf receiveSilkWithIndex:index];
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

#pragma mark - 网络请求完毕处理
//处理Silk用户信息
- (void)handleSilkUserInfo:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    silkInfo = [OSilkInfoModel modelWithDict:dict];
    NSString *strSilk = [NSString stringWithFormat:@"%@ : %.3f", [self getString:@"SILK"], silkInfo.TotalSilk.doubleValue];
    NSString *strPower = [NSString stringWithFormat:@"%@ : %@", [self getString:@"Present Power Value"], silkInfo.TotalPower];
    self.lblSilk.text = strSilk;
    self.lblPower.text = strPower;
}
//用户Silk生成记录处理
- (void)handleSilkRecord:(NSArray *)array isReceived:(BOOL)isReceived {
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    if (isReceived) {
        [arrRecord removeAllObjects];
        for (NSDictionary *dict in array) {
            OSilkProfitModel *model = [OSilkProfitModel modelWithDict:dict];
            [arrRecord addObject:model];
        }
        self.tabRecordsHeight.constant = arrRecord.count * cellHeight;
        if (arrRecord.count > 0) {
            self.tabRecordsBottom.constant = 15;
        }
        [self adjustmentEmptyViewHeight];
        [self.tabRecords reloadData];
    } else {
        [arrSilks removeAllObjects];
        for (NSDictionary *dict in array) {
            OSilkProfitModel *model = [OSilkProfitModel modelWithDict:dict];
            [arrSilks addObject:model];
        }
        [self addSilksViewInOneView];
    }
}

//收取Silk币
- (void)receiveSilkWithIndex:(NSUInteger)index {
    __block UIView *btnView = [self.oneView viewWithTag:(40000 + index)];
    UIButton *btn = [btnView viewWithTag:(30000 + index)];
    btn.selected = YES;
    UIImageView *imageView = [btnView viewWithTag:(20000 + index)];
    imageView.alpha = 1.0;
    if (index < arrAddedSilk.count) {
        __block OSilkProfitModel *model = [arrAddedSilk objectAtIndex:index];
        __block UILabel *lbl = [self.oneView viewWithTag:(10000 + index)];
        
        WS(weakSelf);
        [UIView animateWithDuration:1.0 animations:^{
            
            [btnView setCenter:CGPointMake(weakSelf.silkView.origin.x + weakSelf.imgSilk.center.x, weakSelf.silkView.origin.y + weakSelf.imgSilk.center.y)];
            [lbl setCenter:CGPointMake(weakSelf.silkView.origin.x + weakSelf.lblSilk.center.x + 15, weakSelf.silkView.origin.y + weakSelf.lblSilk.center.y)];
            
        } completion:^(BOOL finished) {
            
            [btnView removeFromSuperview];
            [lbl removeFromSuperview];
            [arrButton removeObject:btnView];
            for (NSInteger s = 0; s < arrSilks.count; s++) {
                OSilkProfitModel *aModel = [arrSilks objectAtIndex:s];
                if ([aModel.SilkProduceRecordID isEqualToString:model.SilkProduceRecordID]) {
                    [arrSilks removeObjectAtIndex:s];
                    break;
                }
            }
            if (arrButton.count == 0 && arrSilks.count > 0) {
                [weakSelf addSilksViewInOneView];
            }
            
            double totalSilk = silkInfo.TotalSilk.doubleValue + model.SilkNum.doubleValue;
            NSString *strSilk = [NSString stringWithFormat:@"%.3f", totalSilk];
            for (NSInteger k = 0; k < strSilk.length; k++) {
                NSString *str = [strSilk substringFromIndex:(strSilk.length - 1)];
                if ([str isEqualToString:@"0"]) {
                    strSilk = [strSilk substringToIndex:(strSilk.length - 1)];
                    k = k - 1;
                } else {
                    break;
                }
                if ([str isEqualToString:@"."]) {
                    strSilk = [strSilk substringToIndex:(strSilk.length - 1)];
                    break;
                }
            }
            silkInfo.TotalSilk = strSilk;
            weakSelf.lblSilk.text = [NSString stringWithFormat:@"%@ : %@", [weakSelf getString:@"SILK"], strSilk];
            //刷新收币记录
            [weakSelf requestGetSilksWithIsReceived:YES];
        }];
        [self playReceiveSilkSound];
    }
}
//播放收获Silk币的声音
- (void)playReceiveSilkSound {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ReceiveSilk2" ofType:@"mp3"];
    SystemSoundID soundID = 1000;
    if (path) {
        NSURL *url = [NSURL URLWithString:path];
        OSStatus error = AudioServicesCreateSystemSoundID(((__bridge CFURLRef _Nonnull)url), &soundID);
        if (error != kAudioServicesNoError) {
            //发生错误
        }
    }
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark - 协议
//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrRecord.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSilkHomeRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSilkHomeRecordCell"];
    OSilkProfitModel *model = [arrRecord objectAtIndex:indexPath.row];
    [cell setupProfitInfo:model];
    return cell;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //NSLog(@"dealloc");
}


@end


