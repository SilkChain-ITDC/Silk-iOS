//
//  OSelectItemCell.h
//  OSell
//
//  Created by xlg on 2018/1/8.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSelectItemCell : UITableViewCell


- (void)setupImage:(id)image title:(NSString *)title;

- (void)showRedDotWithIsShow:(BOOL)isShow;


@end


