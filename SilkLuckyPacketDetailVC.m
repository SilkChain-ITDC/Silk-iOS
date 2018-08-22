//
//  SilkLuckyPacketDetailVC.m
//  OSell
//
//  Created by xlg on 2018/6/5.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "SilkLuckyPacketDetailVC.h"

#import "NSString+Extension.h"
#import "SilkPacketDetailCell.h"

@interface SilkLuckyPacketDetailVC () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *arrList;
}

@end

@implementation SilkLuckyPacketDetailVC

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isRedPacketDetail) {
        self.title = [self getString:@"发出的红包"];
    } else {
        self.title = [self getString:@"分享详情"];
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDatas];
    [self layoutViews];
}
//初始化数据
- (void)setupDatas {
    arrList = [NSMutableArray array];
}
//设置UI
- (void)layoutViews {
    [self.userHead setupCornerRadius:5.0];
    [self.userHead setupBorderColor:RGBCOLOR(255, 122, 35)];
    [self.btnSharingView setupCornerRadius:20.0];
    [self.btnShareView setupCornerRadius:20.0];
    [self.tabList registerNib:[UINib nibWithNibName:@"SilkPacketDetailCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SilkPacketDetailCell"];
    if (@available(iOS 11.0, *)) {
        self.bGView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self loadViewByPacketType];
}
//根据红包类型调整显示视图
- (void)loadViewByPacketType {
    if (self.isRedPacketDetail) {
        self.buttonViewHeight.constant = 52;
        self.lblBottomTitle.textColor = RGBCOLOR(36, 133, 201);
        self.lblBottomTitle.text = [self getString:@"Red Packet transferred to Wallet"];
        //中间的提示语
        NSString *strTips = [NSString stringWithFormat:@"%d red packet opened in %d Minutes %d Seconds", 10, 2, 34];
        CGFloat tipsHeight = [strTips getHeight:(SCREEN_WIDTH-30) fontSize:14] + 24;
        self.middleTipsViewHeight.constant = tipsHeight;
    } else {
        self.buttonViewHeight.constant = 0;
        self.middleTipsViewHeight.constant = 0;
        self.lblBottomTitle.textColor = RGBCOLOR(136, 136, 136);
        self.lblBottomTitle.text = [self getString:@"Get bounds"];
    }
    [self adjustmentEmptyViewHeight];
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
}

#pragma mark - 交互事件
//返回上个页面按钮事件
- (IBAction)buttonToBackAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//第一个按钮
- (IBAction)tapToSharingAction:(UITapGestureRecognizer *)sender {
    
}
//第二个分享红包按钮
- (IBAction)tapToShareAction:(UITapGestureRecognizer *)sender {
    
}

#pragma mark - 协议
//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SilkPacketDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SilkPacketDetailCell"];
    SilkPacketDetailModel *model = [arrList objectAtIndex:indexPath.row];
    [cell setupPacketDetailInfo:model isRedPacketDetail:self.isRedPacketDetail];
    return cell;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


