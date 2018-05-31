//
//  OSilkChainViewController.h
//  OSell
//
//  Created by xlg on 2018/5/30.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "Base.h"

@interface OSilkChainViewController : Base

@property (weak, nonatomic) IBOutlet UIScrollView *bGView;
@property (weak, nonatomic) IBOutlet UICollectionView *collList;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collListHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyViewHeight;

- (IBAction)tapToApplyForDeveloperAction:(UITapGestureRecognizer *)sender;

@end
