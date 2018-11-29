//
//  SilkActionSheetSelectView.h
//  OSell
//
//  Created by xlg on 2018/6/1.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^kActionSheetSelectBlock)(NSInteger index, NSString *strTitle);

@interface SilkActionSheetSelectView : UIView

+ (instancetype)showWithDatas:(NSArray *)datas selectBlock:(kActionSheetSelectBlock)block;

@end
