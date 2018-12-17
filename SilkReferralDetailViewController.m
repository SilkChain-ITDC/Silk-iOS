//
//  SilkReferralDetailViewController.m
//  OSell
//
//  Created by xlg on 2018/9/7.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "SilkReferralDetailViewController.h"

#import "Masonry.h"
#import "HExtension.h"
#import "UIScrollView+Extension.h"
#import "SilkReferralSearchModel.h"
#import "SilkReferralDetailCell.h"
#import "SilkActionSheetSelectView.h"

@interface SilkReferralDetailViewController () <UITableViewDelegate, UITableViewDataSource>
{
    BOOL isStartTime;
    SilkReferralSearchModel *searchModel;
    NSMutableArray *arrList;
    NSMutableArray *arrSearch;
    NSMutableArray *arrFriend;
    SilkActionSheetSelectView *selectLevelView;
}

@end

@implementation SilkReferralDetailViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self getString:@"ReferralDetail_Title"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDatas];
    [self layoutViews];
}

- (void)setupDatas {
    isStartTime = NO;
    arrList = [NSMutableArray array];
    arrFriend = [NSMutableArray array];
    //第一项为：全部
    [arrFriend addObject:@{@"UserID": @"", @"UserName": [self getString:@"ReferralDetail_All"]}];
    //根据选中的好友级设置数据
    searchModel = [SilkReferralSearchModel modelWithLevel:self.selectLevel];
    [self setupSearchItemsWithLevel:self.selectLevel];
    //当选中好友级为2或3时，要请求上级邀请人数据
    if (self.selectLevel == 2 || self.selectLevel == 3) {
        [self requestGetInviteUsersByLevel:NO];
    }
}

- (void)layoutViews {
    WS(weakSelf);
    //隐藏选择视图
    self.dateBView.hidden = YES;
    self.dateHiddenView.alpha = 0;
    self.datePickerBottom.constant = -260;
    self.friendBView.hidden = YES;
    self.friendHiddenView.alpha = 0;
    self.tabFriendTop.constant = SCREEN_HEIGHT;
    //
    self.lblTitle.text = [self getString:@"ReferralDetail_Title"];
    [self.btnSearch setTitle:[self getString:@"ReferralDetail_Search"] forState:UIControlStateNormal];
    self.lblBottomTips.text = [self getString:@"ReferralDetail_BottomTips"];
    
    self.topViewHeight.constant = StatusHeight + 44;
    self.lblTotalReward.hidden = YES;
    [self.btnSearch setupCornerRadius:5.0];
    self.tabListHeight.constant = 0;
    [self.tabList registerNib:[UINib nibWithNibName:@"SilkReferralDetailCell" bundle:nil] forCellReuseIdentifier:@"SilkReferralDetailCell"];
    
    [self.bGView setupRefresh:^{
        [weakSelf requestGetInviteUserList:NO isLoading:NO];
    } loadMore:^{
        [weakSelf requestGetInviteUserList:YES isLoading:NO];
    }];
    [self.bGView.footer noticeNoMoreData];
    [self.bGView.header beginRefreshing];
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
//返回事件
- (IBAction)buttonToLeftAction:(UIButton *)sender {
    if (self.tabFriendTop.constant == 0) {
        [self showChooseFriendList:NO];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//取消按钮事件
- (IBAction)buttonToCancelAction:(UIButton *)sender {
    [self showDatePicker:NO];
}
//确定按钮事件
- (IBAction)buttonToSureAction:(UIButton *)sender {
    [self showDatePicker:NO];
    
    NSDateFormatter *formatter = [NSDateFormatter ymdDateFormatter];
    NSString *strDate = [formatter stringFromDate:self.datePicker.date];
    if (isStartTime) {
        if (searchModel.endTime.length > 0) {
            NSDate *endDate = [formatter dateFromString:searchModel.endTime];
            NSTimeInterval interval = [self.datePicker.date timeIntervalSinceDate:endDate];
            if (interval > 0) {
                [self makeToast:[self getString:@"ReferralDetail_TimeTips"]];
                strDate = searchModel.endTime;
            }
        }
        searchModel.startTime = strDate;
        SilkSearchItemModel *model = [arrSearch objectAtIndex:0];
        model.detail = strDate;
        [self.tabSearch reloadData];
    } else {
        if (searchModel.startTime.length > 0) {
            NSDate *startDate = [formatter dateFromString:searchModel.startTime];
            NSTimeInterval interval = [startDate timeIntervalSinceDate:self.datePicker.date];
            if (interval > 0) {
                [self makeToast:[self getString:@"ReferralDetail_TimeTips"]];
                strDate = searchModel.startTime;
            }
        }
        searchModel.endTime = strDate;
        SilkSearchItemModel *model = [arrSearch objectAtIndex:1];
        model.detail = strDate;
        [self.tabSearch reloadData];
    }
}
//点击隐藏时间选择器
- (IBAction)tapToHiddenAction:(id)sender {
    [self showDatePicker:NO];
}
//点击隐藏好友列表
- (IBAction)tapToHiddenFriendView:(id)sender {
    [self showChooseFriendList:NO];
}

//搜索按钮事件
- (IBAction)buttonToSearchAction:(UIButton *)sender {
    [self requestGetInviteUserList:NO isLoading:YES];
}

#pragma mark - 网络请求
//网络请求邀请信息
- (void)requestGetInviteUserList:(BOOL)isLoad isLoading:(BOOL)isLoading {
    WS(weakSelf);
    NSInteger pageIndex = 1;
    if (isLoad) {
        pageIndex = arrList.count / 20 + 1;
    }
    SilkLoginUserModel *user = [[SilkLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@Account/XXXXXXXX", [[SilkServerConfig shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"Lan"];
    [param setObject:@"IOS" forKey:@"Source"];
    [param setObject:searchModel.startTime forKey:@"BeginTime"];
    [param setObject:searchModel.endTime forKey:@"EndTime"];
    [param setObject:searchModel.level forKey:@"Level"];
    [param setObject:searchModel.inviterId forKey:@"InviteUserID"];
    [param setObject:@(pageIndex) forKey:@"PageIndex"];
    [param setObject:@"20" forKey:@"PageSize"];
    [param setObject:user.userId forKey:@"UserID"];
    
    if (isLoading) {
        [DZProgress show:[self getString:@"Silk_Loading"]];
    }
    [[SilkHttpServerHelper shareInstance] requestHTTPDataWithAPI:apiUrl andHeader:nil andBody:param andSuccessBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf.bGView endRefreshAndLoadMore];
        if (apiResult.apiCode == 0) {
            [weakSelf handleInviteUserList:apiResult.dataResult isLoad:isLoad];
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf.bGView endRefreshAndLoadMore];
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf.bGView endRefreshAndLoadMore];
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(SilkAPIResult *apiResult) {
        [weakSelf pushToLoginVC:NO];
        [weakSelf.bGView endRefreshAndLoadMore];
    }];
}
//网络请求邀请的好友信息
- (void)requestGetInviteUsersByLevel:(BOOL)isLoading {
    if (searchModel.level.intValue < 2) {
        return;
    }
    WS(weakSelf);
    SilkLoginUserModel *user = [[SilkLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@Account/XXXXXXXXX", [[SilkServerConfig shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"Lan"];
    [param setObject:@"IOS" forKey:@"Source"];
    //1(一级好友) 2(二级好友) 3(三级好友)
    [param setObject:@(searchModel.level.intValue-1) forKey:@"Level"];
    [param setObject:user.userId forKey:@"UserID"];
    
    if (isLoading) {
        [DZProgress show:[self getString:@"Silk_Loading"]];
    }
    [[SilkHttpServerHelper shareInstance] requestHTTPDataWithAPI:apiUrl andHeader:nil andBody:param andSuccessBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        if (apiResult.apiCode == 0) {
            [weakSelf handleInviteUsersByLevel:apiResult.dataResult isLoading:isLoading];
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
        [weakSelf pushToLoginVC:NO];
    }];
}
//处理网络返回数据
- (void)handleInviteUserList:(NSDictionary *)dict isLoad:(BOOL)isLoad {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *strTotal = [NSString stringWithFormat:@"%@%@%@+%@%@", [self getString:@"ReferralDetail_Total"], [dict stringForKey:@"TotalAmount"], [self getString:@"Silk_SILK"], [dict stringForKey:@"TotalPower"], [self getString:@"SilkPower_power0"]];
    self.lblTotalReward.hidden = NO;
    self.lblTotalReward.text = strTotal;
    
    if (isLoad == NO) {
        [arrList removeAllObjects];
    }
    NSArray *array = [dict objectForKey:@"userList"];
    if (![array isKindOfClass:[NSArray class]]) {
        array = nil;
    }
    if (array.count < 20) {
        [self.bGView.footer noticeNoMoreData];
    } else {
        [self.bGView.footer resetNoMoreData];
    }
    for (NSDictionary *dic in array) {
        SilkReferralDetailModel *model = [SilkReferralDetailModel modelWithDict:dic];
        [arrList addObject:model];
    }
    self.tabListHeight.constant = (arrList.count + 1) * 40.0;
    [self adjustmentEmptyViewHeight];
    [self.tabList reloadData];
}
//处理网络返回数据
- (void)handleInviteUsersByLevel:(NSArray *)array isLoading:(BOOL)isLoading {
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    [arrFriend removeAllObjects];
    [arrFriend addObject:@{@"UserID": @"", @"UserName": [self getString:@"ReferralDetail_All"]}];
    [arrFriend addObjectsFromArray:array];
    [self.tabFriend reloadData];
    if (isLoading && arrFriend.count > 0) {
        [self showChooseFriendList:YES];
    }
}

#pragma mark - 协议
//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tabSearch) {
        return arrSearch.count;
    } else if (tableView == self.tabFriend) {
        return arrFriend.count;
    }
    return arrList.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *color51 = RGBCOLOR(51, 51, 51);
    UIColor *color153 = RGBCOLOR(153, 153, 153);
    if (tableView == self.tabSearch) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        }
        [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cell.contentView).offset(15);
            make.centerY.equalTo(cell.contentView);
        }];
        [cell.detailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(cell.contentView).offset(-10);
            make.centerY.equalTo(cell.contentView);
        }];
        cell.textLabel.textColor = color51;
        cell.detailTextLabel.textColor = color51;
        if (indexPath.row == 3) {
            if (searchModel.level.integerValue != 2 && searchModel.level.integerValue != 3) {
                cell.textLabel.textColor = color153;
                cell.detailTextLabel.textColor = color153;
            }
        }
        SilkSearchItemModel *model = [arrSearch objectAtIndex:indexPath.row];
        cell.textLabel.text = model.title;
        cell.detailTextLabel.text = model.detail;
        return cell;
    }
    if (tableView == self.tabFriend) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = color51;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
        NSDictionary *friend = [arrFriend objectAtIndex:indexPath.row];
        NSString *strName = [friend stringForKey:@"UserName"];
        //* //coding
        if (indexPath.row > 0) {
            if (strName.length >= 6) {
                NSString *str1 = [strName substringToIndex:3];
                NSString *str2 = [strName substringFromIndex:6];
                NSString *str3 = @"***";
                strName = [NSString stringWithFormat:@"%@%@%@", str1, str3, str2];
            } else if (strName.length >= 3) {
                NSString *str1 = [strName substringToIndex:3];
                NSString *str3 = @"***";
                strName = [NSString stringWithFormat:@"%@%@", str1, str3];
            } else {
                strName = [NSString stringWithFormat:@"%@%@", strName, @"***"];
            }
        }//*/
        cell.textLabel.text = strName;
        return cell;
    }
    SilkReferralDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SilkReferralDetailCell"];
    if (indexPath.row == 0) {
        [cell setupReferralDetailInfo:nil isFirst:YES];
    } else {
        SilkReferralDetailModel *model = [arrList objectAtIndex:(indexPath.row - 1)];
        [cell setupReferralDetailInfo:model isFirst:NO];
    }
    return cell;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tabSearch) {
        return 44;
    }
    if (tableView == self.tabFriend) {
        return 44;
    }
    return 40;//coding
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tabSearch) {
        __block SilkSearchItemModel *model = [arrSearch objectAtIndex:indexPath.row];
        //开始时间
        if (indexPath.row == 0) {
            isStartTime = YES;
            [self showDatePicker:YES];
        }
        //结束时间
        else if (indexPath.row == 1) {
            isStartTime = NO;
            [self showDatePicker:YES];
        }
        //好友关系
        else if (indexPath.row == 2) {
            WS(weakSelf);
            NSArray *datas = @[[self getString:@"ReferralDetail_All"], [self getString:@"ReferralDetail_RelationShip1"], [self getString:@"ReferralDetail_RelationShip2"], [self getString:@"ReferralDetail_RelationShip3"]];
            selectLevelView = [SilkActionSheetSelectView showWithDatas:datas selectBlock:^(NSInteger index, NSString *strTitle) {
                NSString *selectLevel = [NSString stringWithFormat:@"%d", (int)index];
                if (![selectLevel isEqualToString:searchModel.level]) {
                    searchModel.level = selectLevel;
                    model.detail = strTitle;
                    if (index == 2 || index == 3) {
                        [weakSelf requestGetInviteUsersByLevel:NO];
                    } else {
                        SilkSearchItemModel *model = [arrSearch objectAtIndex:3];
                        model.detail = [self getString:@"ReferralDetail_All"];
                        searchModel.inviterId = @"";
                        searchModel.inviterName = [self getString:@"ReferralDetail_All"];
                    }
                    [weakSelf.tabSearch reloadData];
                }
            }];
        }
        //邀请人
        else if (indexPath.row == 3) {
            //只有一级或二级才有邀请人  coding
            if (searchModel.level.intValue == 2 || searchModel.level.intValue == 3) {
                if (arrFriend.count == 0) {
                    [self requestGetInviteUsersByLevel:YES];
                } else {
                    [self showChooseFriendList:YES];
                }
            }
        }
        return;
    }
    if (tableView == self.tabFriend) {
        NSDictionary *friend = [arrFriend objectAtIndex:indexPath.row];
        searchModel.inviterId = [friend stringForKey:@"UserID"];
        searchModel.inviterName = [friend stringForKey:@"UserName"];
        SilkSearchItemModel *model = [arrSearch objectAtIndex:3];
        model.detail = searchModel.inviterName;
        [self.tabSearch reloadData];
        [self showChooseFriendList:NO];
    }
}

#pragma mark - 显示或隐藏选择条件
//显示或隐藏时间选择器
- (void)showDatePicker:(BOOL)isShow {
    if (isShow) {
        NSDate *currentDate;
        NSDateFormatter *formatter = [NSDateFormatter ymdDateFormatter];
        if (isStartTime && searchModel.startTime.length > 0) {
            currentDate = [formatter dateFromString:searchModel.startTime];
        }
        if (isStartTime == NO && searchModel.endTime.length > 0) {
            currentDate = [formatter dateFromString:searchModel.endTime];
        }
        if (currentDate) {
            [self.datePicker setDate:currentDate animated:YES];
        }
        self.dateBView.hidden = NO;
        self.datePickerBottom.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            self.dateHiddenView.alpha = 1.0;
            [self.dateBView layoutIfNeeded];
        }];
    } else {
        self.datePickerBottom.constant = -260;
        [UIView animateWithDuration:0.5 animations:^{
            self.dateHiddenView.alpha = 0;
            [self.dateBView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.dateBView.hidden = YES;
        }];
    }
}
//显示或隐藏好友选择列表
- (void)showChooseFriendList:(BOOL)isShow {
    if (isShow) {
        self.friendBView.hidden = NO;
        self.tabFriendTop.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            self.friendHiddenView.alpha = 1.0;
            [self.friendBView layoutIfNeeded];
        }];
    } else {
        self.tabFriendTop.constant = SCREEN_HEIGHT;
        [UIView animateWithDuration:0.5 animations:^{
            self.friendHiddenView.alpha = 0;
            [self.friendBView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.friendBView.hidden = YES;
        }];
    }
}

#pragma mark - 其他
- (void)setupSearchItemsWithLevel:(NSUInteger)selectLevel {
    if (!arrSearch) {
        arrSearch = [NSMutableArray array];
    }
    [arrSearch removeAllObjects];
    SilkSearchItemModel *startTime = [SilkSearchItemModel modelWithTitle:[self getString:@"ReferralDetail_StartTime"] detail:[self getString:@"ReferralDetail_Any"]];
    SilkSearchItemModel *endTime = [SilkSearchItemModel modelWithTitle:[self getString:@"ReferralDetail_EndTime"] detail:[self getString:@"ReferralDetail_Any"]];
    SilkSearchItemModel *level = [SilkSearchItemModel modelWithTitle:[self getString:@"ReferralDetail_RelationShip"] detail:[self getString:@"ReferralDetail_All"]];
    if (selectLevel != 0) {
        level.detail = [self getString:[NSString stringWithFormat:@"ReferralDetail_RelationShip%d", (int)selectLevel]];
    }
    SilkSearchItemModel *inviter = [SilkSearchItemModel modelWithTitle:[self getString:@"ReferralDetail_Inviter"] detail:[self getString:@"ReferralDetail_All"]];
    [arrSearch addObjectsFromArray:@[startTime, endTime, level, inviter]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


