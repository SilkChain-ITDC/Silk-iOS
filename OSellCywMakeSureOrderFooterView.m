//
//  OSellCywMakeSureOrderFooterView.m
//  OSell
//
//  Created by OSellResuming on 2017/6/5.
//  Copyright © 2017年 OSellResuming. All rights reserved.
//

#import "OSellCywMakeSureOrderFooterView.h"
#import "OSellBuyCateModel.h"

@implementation OSellCywMakeSureOrderFooterView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
    self.buyerMessageTitle.text = [NSString stringWithFormat:@"%@:", [InternationalizationHelper getText:@"OSellMakeSureOrderVC_Other Requirements"]];
    self.orderSubTotalTitle.text = [NSString stringWithFormat:@"%@:", [InternationalizationHelper getText:@"OSellMakeSureOrderVC_Subtotal"]];
    self.shippingMoneyTitle.text = [NSString stringWithFormat:@"%@:", [InternationalizationHelper getText:@"OSellMakeSureOrderVC_Shipping Cost"]];
    self.grandTotalTitle.text = [NSString stringWithFormat:@"%@:", [InternationalizationHelper getText:@"OSellMakeSureOrderVC_Total"]];
    
    [self.txtView setValue:@"100" forKey:@"limit"];
    self.txtView.layer.borderWidth = 1.0f;
    self.txtView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.txtView.delegate = self;
    
    [self layoutIfNeeded];
    
}


//刷新ui
- (void)refreshViewWithData:(OSellBuyCateModel *)model
{
    
    self.txtView.text = model.Note;
    
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    
    if (self.kNoteBlock) {
        self.kNoteBlock(self.txtView.text);
    }
    
}

- (IBAction)giftCardBtnAction:(UIButton *)sender {
    
    if (self.kGiftCardBlock) {
        self.kGiftCardBlock();
    }
    
}

- (IBAction)shippingMoneyBtnAction:(UIButton *)sender {
    
    if (self.kShippingBlock) {
        self.kShippingBlock();
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"])
    { //判断输入的字是否是回车，即按下return
        
        [textView resignFirstResponder];
        
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

- (UIViewController *)viewController
{
    //下一个响应者
    UIResponder *next=[self nextResponder];
    
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        
        next = [next nextResponder];
        
    } while (next!=nil);
    
    return nil;
}

@end
