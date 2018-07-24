//
//  AddNewFriendCell.h
//  OSell
//
//  Created by OSellResuming on 15/11/19.
//  Copyright © 2015年 DZSOIN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSellStringHelper.h"

@class NotifyMessage;

@interface AddNewFriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightConstraint;

@property (nonatomic, strong) NotifyMessage *curNotifyMessage;

/**刷新Cell，根据当前消息Model和当前好友列表
 */
- (void)refreshCellData:(NotifyMessage *)curMsg;

@end
