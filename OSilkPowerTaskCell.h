//
//  OSilkPowerTaskCell.h
//  OSell
//
//  Created by xlg on 2018/4/2.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OSilkPowerTaskModel.h"

/** SilkPower页面获取power任务列表cell */
@interface OSilkPowerTaskCell : UICollectionViewCell

- (void)setupSilkPowerTaskInfo:(OSilkPowerTaskModel *)model;
- (void)setupLineWithIndex:(NSInteger)index;

@end
