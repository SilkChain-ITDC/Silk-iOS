//
//  OSilkPowerTaskCell.m
//  OSell
//
//  Created by xlg on 2018/4/2.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "OSilkPowerTaskCell.h"

#import "UIImageView+WebCache.h"

@interface OSilkPowerTaskCell ()
{
    BOOL setted;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgTask;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblAddedNum;
@property (weak, nonatomic) IBOutlet UILabel *lblAddCount;
@property (weak, nonatomic) IBOutlet UIButton *btnCompleted;

@property (weak, nonatomic) IBOutlet UIView *lineOne;
@property (weak, nonatomic) IBOutlet UIView *lineTwo;

@end

@implementation OSilkPowerTaskCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setupSilkPowerTaskInfo:(OSilkPowerTaskModel *)model {
    if (setted == NO) {
        setted = YES;
        [self.lblAddCount setupCornerRadius:10.0];
    }
    if (![model isKindOfClass:[OSilkPowerTaskModel class]]) {
        return;
    }
    self.lblName.text = model.ActivityName;
    if (model.IsComplete) {
        self.lblAddCount.hidden = YES;
        self.btnCompleted.hidden = NO;
        self.lblAddedNum.hidden = NO;
        self.lblAddedNum.text = [NSString stringWithFormat:@"+%@ power", model.Value];
    } else {
        self.lblAddCount.hidden = NO;
        self.btnCompleted.hidden = YES;
        self.lblAddedNum.hidden = YES;
        self.lblAddCount.text = [NSString stringWithFormat:@"%@", model.ActivityDesc];
        if (model.ActivityDesc.length == 0 || model.SilkActivityType == 2) {
            self.lblAddCount.hidden = YES;
        }
    }
    [self.imgTask sd_setImageWithURL:[NSURL URLWithString:model.ActivityImg]];
}

- (void)setupLineWithIndex:(NSInteger)index {
    if ((index + 1) % 3 == 0) {
        self.lineOne.hidden = YES;
    } else {
        self.lineOne.hidden = NO;
    }
}


@end


