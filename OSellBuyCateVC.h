//
//  OSellBuyCateVC.h
//  OSell
//
//  Created by OSellResuming on 16/9/29.
//  Copyright © 2016年 OSellResuming. All rights reserved.
//

#import "Base.h"

@interface OSellBuyCateVC : Base

@property (weak, nonatomic) IBOutlet UITableView *tableMain;

@property (weak, nonatomic) IBOutlet UIButton *btnPurchaseAll;

- (IBAction)btnPurchaseAllAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblAllMoneyTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblAllMoneyValue;

@property (weak, nonatomic) IBOutlet UIButton *btnSettlement;

- (IBAction)btnSettlementAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnCollection;

- (IBAction)btnCollectionAction:(id)sender;

@property (nonatomic, strong) NSString *strHallID;

@end
