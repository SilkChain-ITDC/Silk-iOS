//
//  OSellCywMakeSureOrderFooterView.h
//  OSell
//
//  Created by OSellResuming on 2017/6/5.
//  Copyright © 2017年 OSellResuming. All rights reserved.
//

typedef void(^kOSellCywSureOrderFooterViewNoteBlock)(NSString *note);
typedef void(^kOSellCywSureOrderFooterViewGiftCardBlock)();
typedef void(^kOSellCywSureOrderFooterViewShippingBlock)();

#import <UIKit/UIKit.h>
@class OSellBuyCateModel;

@interface OSellCywMakeSureOrderFooterView : UIView<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *giftCardView;
- (IBAction)giftCardBtnAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *giftCardNumLabel;

@property (weak, nonatomic) IBOutlet UILabel *buyerMessageTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtView;

@property (weak, nonatomic) IBOutlet UILabel *orderSubTotalTitle;
@property (weak, nonatomic) IBOutlet UILabel *shippingMoneyTitle;
@property (weak, nonatomic) IBOutlet UILabel *orderSubTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingMoneyShowLabel;

@property (weak, nonatomic) IBOutlet UILabel *grandTotalTitle;
@property (weak, nonatomic) IBOutlet UILabel *grandTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsTotalNumLabel;


- (void)refreshViewWithData:(OSellBuyCateModel *)model;
@property (nonatomic, strong) NSString *defaultCountry; //Country

@property (nonatomic, strong) kOSellCywSureOrderFooterViewNoteBlock kNoteBlock;
@property (nonatomic, strong) kOSellCywSureOrderFooterViewGiftCardBlock kGiftCardBlock;
@property (nonatomic, strong) kOSellCywSureOrderFooterViewShippingBlock kShippingBlock;

@property (weak, nonatomic) IBOutlet UILabel *shippingMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingOnePriceLabel;
- (IBAction)shippingMoneyBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *shippingBtn;
@property (weak, nonatomic) IBOutlet UILabel *shippingTitle;
@property (weak, nonatomic) IBOutlet UIImageView *shippingGoImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buyerMessageTopConstraint; //显示52  隐藏7


@end
