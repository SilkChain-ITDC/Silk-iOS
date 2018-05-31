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

@interface OSilkReferralViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSString *referralCode;
    NSMutableArray *arrList;
}

@end

@implementation OSilkReferralViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self getString:@"Refeffal"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDatas];
    [self layoutViews];
}
//初始化数据
- (void)setupDatas {
    referralCode = @"ABCDEFGH";
    arrList = [NSMutableArray array];
    
    OSilkReferralModel *model0 = [OSilkReferralModel new];
    model0.name = @"direct";
    model0.silk = @"500";
    model0.power = @"10";
    [arrList addObject:model0];
    
    OSilkReferralModel *model1 = [OSilkReferralModel new];
    model1.name = @"indirect";
    model1.silk = @"890";
    model1.power = @"89";
    [arrList addObject:model1];
}
//设置UI
- (void)layoutViews {
    [self.btnCopy setupCornerRadius:16.0];
    [self.btnInvite setupCornerRadius:22.0];
    [self.btnCopy setupBorderColor:RGBCOLOR(40, 130, 200)];
    [self adjustmentEmptyViewHeight];
    [self.tabReferral registerNib:[UINib nibWithNibName:@"OSilkReferralCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"OSilkReferralCell"];
    
    self.tabReferralHeight.constant = 32.0 * arrList.count + 45.0;
    
    
    NSString *strTips = @"1. 1 Referral = 50 Silk + 50 power\n\n2. Your invited friend refer to his or her friends, when his or her friend complete the registration and pass kyc verification, you will be rewarded with 15 silk + 15 power\n\n3. SilkChain has final right of interpretation within the law and will investigate fraudulent invitations, once discovered we will take back rewards and frozen the account.\n\n4. Get your referral link on Referral Page and invite friends to sign up on SilkChain and finish KYC verification. Send your referral link to friends at Facebook, Twitter, Reddit, Medium, Google+, Telegram Group or any other online soclal mediia platforms as widely as you can !!!";
    self.lblReferralTips.text = strTips;
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
//点击复制邀请码到系统剪切板
- (IBAction)buttonToCopyCodeAction:(UIButton *)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = referralCode;
    [self makeToast:@"已复制"];
}
//点击立刻邀请好友
- (IBAction)buttonToInviteNowAction:(UIButton *)sender {
    //coding
}

#pragma mark - 协议
//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"OSilkReferralCell";
    OSilkReferralCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (indexPath.row < arrList.count) {
        OSilkReferralModel *model = [arrList objectAtIndex:indexPath.row];
        [cell setupReferralInfo:model];
    }
    return cell;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32.0)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel *lblName = [[UILabel alloc] initWithText:[self getString:@"Number Of Referrals"] textColor:RGBCOLOR(153, 153, 153) fontSize:13 alignment:NSTextAlignmentCenter];
    [view addSubview:lblName];
    [lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view).offset(10);
        make.centerY.equalTo(view);
    }];
    
    UILabel *lblSilk = [[UILabel alloc] initWithText:[self getString:@"Total Amount"] textColor:RGBCOLOR(153, 153, 153) fontSize:13 alignment:NSTextAlignmentCenter];
    [view addSubview:lblSilk];
    [lblSilk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view);
        make.centerX.equalTo(view).offset(36);
    }];
    
    UILabel *lblPower = [[UILabel alloc] initWithText:[self getString:@"Power"] textColor:RGBCOLOR(153, 153, 153) fontSize:13 alignment:NSTextAlignmentCenter];
    [view addSubview:lblPower];
    [lblPower mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(view).offset(-20);
        make.centerY.equalTo(view);
    }];
    
    return view;
}


/*
1. 1 Referral = 50 Silk + 50 power

2. Your invited friend refer to his or her friends, when his or her friend complete the registration and pass kyc verification, you will be rewarded with 15 silk + 15 power

3. SilkChain has final right of interpretation within the law and will investigate fraudulent invitations, once discovered we will take back rewards and frozen the account.

4. Get your referral link on Referral Page and invite friends to sign up on SilkChain and finish KYC verification. Send your referral link to friends at Facebook, Twitter, Reddit, Medium, Google+, Telegram Group or any other online soclal mediia platforms as widely as you can !!!
//*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


