//
//  SilkActionSheetSelectView.m
//  OSell
//
//  Created by xlg on 2018/6/1.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "SilkActionSheetSelectView.h"

#import "Masonry.h"

@interface SilkActionSheetSelectView () <UITableViewDelegate ,UITableViewDataSource>
{
    CGFloat tabHeight;
    UIColor *lineColor;
    
    UIView *bGView;
    UITableView *tabList;
}

@property (strong, nonatomic) NSMutableArray *arrList;
@property (copy, nonatomic) kActionSheetSelectBlock selectBlock;

@end

@implementation SilkActionSheetSelectView

+ (instancetype)showWithDatas:(NSArray *)datas selectBlock:(kActionSheetSelectBlock)block {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    SilkActionSheetSelectView *view = [[SilkActionSheetSelectView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [view setupDatas:datas block:block];
    [view layoutViews];
    [view showWithDelay:0.01];
    [keyWindow addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(keyWindow);
    }];
    return view;
}

- (void)setupDatas:(NSArray *)array block:(kActionSheetSelectBlock)block {
    self.selectBlock = block;
    
    if (!self.arrList) {
        self.arrList = [NSMutableArray array];
    }
    [self.arrList removeAllObjects];
    [self.arrList addObjectsFromArray:array];
    
    lineColor = [UIColor colorWithWhite:0 alpha:0.5];
    tabHeight = 51.0 + self.arrList.count * 44.0;
}

- (void)layoutViews {
    WS(weakSelf);
    
    if (!bGView) {
        bGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        bGView.alpha = 0;
        bGView.backgroundColor = lineColor;
        [self addSubview:bGView];
        [bGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToHiddenViewAction:)];
        [bGView addGestureRecognizer:tap];
        
        tabList = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-tabHeight, SCREEN_WIDTH, tabHeight)];
        tabList.backgroundColor = [UIColor whiteColor];
        tabList.separatorColor = lineColor;
        tabList.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tabList.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        tabList.delegate = self;
        tabList.dataSource = self;
        tabList.scrollEnabled = NO;
        [self addSubview:tabList];
        [tabList mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf).offset(tabHeight);
            make.height.equalTo(@(tabHeight));
        }];
    }
}

- (void)showWithDelay:(CGFloat)delay {
    WS(weakSelf);
    if (delay < 0.001) {
        delay = 0.001;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf show];
    });
}

- (void)show {
    WS(weakSelf);
    [tabList mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf).offset(0);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        bGView.alpha = 1.0;
        [weakSelf layoutIfNeeded];
    }];
}

- (void)hide {
    WS(weakSelf);
    [tabList mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf).offset(tabHeight);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        bGView.alpha = 0;
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}


- (void)tapToHiddenViewAction:(UITapGestureRecognizer *)sender {
    [self hide];
}

#pragma mark 
//UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 1;
    }
    return self.arrList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellId"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = RGBCOLOR(51, 51, 51);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44.0);
    }
    if (indexPath.section == 1) {
        cell.textLabel.text = [InternationalizationHelper getText:@"Cancel"];
    } else {
        cell.textLabel.text = [self.arrList objectAtIndex:indexPath.row];
    }
    
    return cell;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1.0)];
    view.backgroundColor = lineColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 5.0;
    }
    return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGFloat height = 1.0;
    if (section == 0) {
        height = 5.0;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    view.backgroundColor = lineColor;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.selectBlock) {
            self.selectBlock(indexPath.row, [self.arrList objectAtIndex:indexPath.row]);
        }
    }
    [self hide];
}


@end


