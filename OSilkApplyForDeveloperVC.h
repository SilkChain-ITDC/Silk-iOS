//
//  OSilkApplyForDeveloperVC.h
//  OSell
//
//  Created by xlg on 2018/5/30.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "Base.h"

@interface OSilkApplyForDeveloperVC : Base


@property (weak, nonatomic) IBOutlet UIScrollView *bGView;
@property (weak, nonatomic) IBOutlet UILabel *lblTipsTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTipsDetail;

@property (weak, nonatomic) IBOutlet UILabel *lblOneTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblOnePlace;
@property (weak, nonatomic) IBOutlet UITextField *tfOne;
@property (weak, nonatomic) IBOutlet UILabel *lblTwoTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTwoPlace;
@property (weak, nonatomic) IBOutlet UITextField *tfTwo;
@property (weak, nonatomic) IBOutlet UILabel *lblThreeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblThreePlace;
@property (weak, nonatomic) IBOutlet UITextField *tfThree;
@property (weak, nonatomic) IBOutlet UILabel *lblFourTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfFour;
@property (weak, nonatomic) IBOutlet UILabel *lblFiveTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfFive;
@property (weak, nonatomic) IBOutlet UILabel *lblSixTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfSix;
@property (weak, nonatomic) IBOutlet UILabel *lblSevenTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfSeven;
@property (weak, nonatomic) IBOutlet UILabel *lblEightTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfEight;
@property (weak, nonatomic) IBOutlet UILabel *lblNineTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfNine;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIView *emptyView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyViewHeight;


- (IBAction)buttonToSubmitAction:(UIButton *)sender;


@end


