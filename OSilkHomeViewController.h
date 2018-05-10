//
//  OSilkHomeViewController.h
//  OSell
//
//  Created by xlg on 2018/4/2.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "Base.h"

@interface OSilkHomeViewController : Base


@property (weak, nonatomic) IBOutlet UIScrollView *bGView;

@property (weak, nonatomic) IBOutlet UIView *oneView;
@property (weak, nonatomic) IBOutlet UIImageView *imgOneBG;
@property (weak, nonatomic) IBOutlet UIView *silkView;
@property (weak, nonatomic) IBOutlet UIImageView *imgSilk;
@property (weak, nonatomic) IBOutlet UILabel *lblSilk;
@property (weak, nonatomic) IBOutlet UIView *powerBView;
@property (weak, nonatomic) IBOutlet UILabel *lblPower;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIImageView *imgCenter;
@property (weak, nonatomic) IBOutlet UILabel *lblCenter;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIView *tipsView;

@property (weak, nonatomic) IBOutlet UIView *twoView;
@property (weak, nonatomic) IBOutlet UILabel *lblLatestRecord;
@property (weak, nonatomic) IBOutlet UITableView *tabRecords;
@property (weak, nonatomic) IBOutlet UIButton *btnMoreRecord;
@property (weak, nonatomic) IBOutlet UIView *emptyView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgCenterTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabRecordsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabRecordsBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyViewHeight;


//Silk
- (IBAction)tapToSilkTaskAction:(UITapGestureRecognizer *)sender;
//Power
- (IBAction)tapToPowerTaskAction:(UITapGestureRecognizer *)sender;
//Increase Power
- (IBAction)buttonToIncreasePowerAction:(UIButton *)sender;
//Redeem
- (IBAction)buttonToRedeemAction:(UIButton *)sender;
//More Records
- (IBAction)buttonToMoreRecordsAction:(UIButton *)sender;


@end


