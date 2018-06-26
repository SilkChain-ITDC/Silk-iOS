//
//  OSellMakeSureOrderVC.h
//  OSell
//
//  Created by wenchy on 2016/10/18.
//  Copyright © 2016年 OSellResuming. All rights reserved.
//

#import "Base.h"
#import "OSellBuyCateModel.h"

@interface OSellMakeSureOrderVC : Base<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableMain;

@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
- (IBAction)btnSubmitAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblMoneyValue;



@property (nonatomic, assign) BOOL isFromReplenishment; //是否来自快速补货

@property (assign, nonatomic) BOOL isDirectPurchase;//是否直接购买单件商品

@property (strong, nonatomic) NSMutableArray *arrSelectProducts;//将要购买的商品

@property (strong, nonatomic) NSMutableArray *arrSelectCurrencyProducts;//选商品的货币单位

@end
