//
//  OSilkPowerViewController.h
//  OSell
//
//  Created by xlg on 2018/4/2.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "Base.h"

#import "OSilkInfoModel.h"

@interface OSilkPowerViewController : Base

@property (strong, nonatomic) OSilkInfoModel *silkInfo;

@property (weak, nonatomic) IBOutlet UIScrollView *bGView;

@property (weak, nonatomic) IBOutlet UILabel *lblSilkPower;
@property (weak, nonatomic) IBOutlet UILabel *lblRanking;

@property (weak, nonatomic) IBOutlet UILabel *lblTips;
@property (weak, nonatomic) IBOutlet UICollectionView *collList;

@property (weak, nonatomic) IBOutlet UIView *emptyView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collListHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyViewHeight;


//SilkPower
- (IBAction)tapToSilkPowerAction:(UITapGestureRecognizer *)sender;
//Ranking
- (IBAction)tapToCheckRankingAction:(UITapGestureRecognizer *)sender;


@end


