//
//  SilkReferralDetailViewController.h
//  OSell
//
//  Created by xlg on 2018/9/7.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "Base.h"

@interface SilkReferralDetailViewController : Base

//0全部、1一级好友、2二级好友、3三级好友
@property (assign, nonatomic) NSUInteger selectLevel;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (weak, nonatomic) IBOutlet UIScrollView *bGView;
@property (weak, nonatomic) IBOutlet UITableView *tabSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UITableView *tabList;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalReward;
@property (weak, nonatomic) IBOutlet UILabel *lblBottomTips;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

@property (weak, nonatomic) IBOutlet UIView *dateBView;
@property (weak, nonatomic) IBOutlet UIView *dateHiddenView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSure;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UIView *friendBView;
@property (weak, nonatomic) IBOutlet UIView *friendHiddenView;
@property (weak, nonatomic) IBOutlet UITableView *tabFriend;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabSearchHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabListHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabFriendTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;


- (IBAction)buttonToLeftAction:(UIButton *)sender;
- (IBAction)buttonToCancelAction:(UIButton *)sender;
- (IBAction)buttonToSureAction:(UIButton *)sender;
- (IBAction)tapToHiddenAction:(id)sender;
- (IBAction)tapToHiddenFriendView:(id)sender;

- (IBAction)buttonToSearchAction:(UIButton *)sender;

@end
