//
//  OSilkPowerRankingVC.m
//  OSell
//
//  Created by xlg on 2018/4/2.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "OSilkPowerRankingVC.h"

#import "Masonry.h"
#import "UILabel+Extension.h"
#import "UIScrollView+Extension.h"
#import "ORankingListCell.h"

@interface OSilkPowerRankingVC () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tabList;
    NSMutableArray *arrList;
}

@end

@implementation OSilkPowerRankingVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self getString:@"Power Ranking"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupDatas];
    [self layoutViews];
    [self setBackButton];
}
//初始化数据
- (void)setupDatas {
    arrList = [NSMutableArray array];
}
//设置UI
- (void)layoutViews {
    WS(weakSelf);
    
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *strTips = [self getString:@"Updated per hour"];
    UILabel *lblTips = [[UILabel alloc] initWithText:strTips textColor:RGBCOLOR(51, 51, 51) fontSize:14];
    [self.view addSubview:lblTips];
    [lblTips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view);
        make.leading.equalTo(weakSelf.view).offset(15);
        make.height.equalTo(@(44.0));
    }];
    
    tabList = [[UITableView alloc] init];
    tabList.delegate = self;
    tabList.dataSource = self;
    tabList.separatorStyle = UITableViewCellSeparatorStyleNone;
    tabList.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [tabList registerNib:[UINib nibWithNibName:@"ORankingListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ORankingListCell"];
    [tabList setupRefresh:^{
        [weakSelf requestGetPowerRanking:NO];
    }];
    [self.view addSubview:tabList];
    [tabList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lblTips.mas_bottom);
        make.leading.trailing.bottom.equalTo(weakSelf.view);
    }];
    [tabList.header beginRefreshing];
}

#pragma mark - 网络请求
//网络请求Silk和Power排名
- (void)requestGetPowerRanking:(BOOL)isLoad {
    WS(weakSelf);
    NSString *apiUrl = [NSString stringWithFormat:@"%@/DragonSilk/GetSilkUserList", [[OSellServerHelper shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"lan"];
    [param setObject:@"100" forKey:@"Top"];
    
    [DZProgress show:[self getString:@"Loading"]];
    [[OSellHTTPHelper shareInstance] requestHTTPDataWithAPI:apiUrl andParams:param andSuccessBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [tabList endRefreshAndLoadMore];
        if (apiResult.apiCode == 0) {
            [weakSelf handlePowerRankingList:apiResult.dataResult isLoad:isLoad];
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [tabList endRefreshAndLoadMore];
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [tabList endRefreshAndLoadMore];
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        [tabList endRefreshAndLoadMore];
        [weakSelf pushToLoginVC:NO];
    }];
}
//处理网络请求数据
- (void)handlePowerRankingList:(NSArray *)array isLoad:(BOOL)isLoad {
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    if (isLoad == NO) {
        [arrList removeAllObjects];
    }
    for (NSDictionary *dict in array) {
        OSilkPowerModel *model = [OSilkPowerModel modelWithDict:dict];
        [arrList addObject:model];
    }
    [arrList sortUsingComparator:^NSComparisonResult(OSilkPowerModel*  _Nonnull obj1, OSilkPowerModel*  _Nonnull obj2) {
        if (obj1.order > obj2.order) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    [tabList reloadData];
}

#pragma mark - 协议
//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ORankingListCell *cell = [tabList dequeueReusableCellWithIdentifier:@"ORankingListCell"];
    OSilkPowerModel *model = [arrList objectAtIndex:indexPath.row];
    [cell setupRankingInfo:model];
    return cell;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (arrList.count == 0) {
        return 0.1;
    }
    return 36.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (arrList.count == 0) {
        return [UIView new];
    }
    
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 36.0)];
    hView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel *lblNo = [[UILabel alloc] initWithText:[self getString:@"NO."] textColor:[UIColor darkGrayColor] fontSize:15];
    [hView addSubview:lblNo];
    [lblNo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(hView).offset(15);
        make.centerY.equalTo(hView);
    }];
    
    UILabel *lblSilk = [[UILabel alloc] initWithText:[self getString:@"Silk"] textColor:[UIColor darkGrayColor] fontSize:15 alignment:NSTextAlignmentCenter];
    [hView addSubview:lblSilk];
    [lblSilk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(hView).offset(20);
        make.centerY.equalTo(hView);
    }];
    
    UILabel *lblPower = [[UILabel alloc] initWithText:[self getString:@"Power"] textColor:[UIColor darkGrayColor] fontSize:15 alignment:NSTextAlignmentRight];
    [hView addSubview:lblPower];
    [lblPower mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(hView).offset(-15);
        make.centerY.equalTo(hView);
    }];
    
    return hView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark - 其他


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


