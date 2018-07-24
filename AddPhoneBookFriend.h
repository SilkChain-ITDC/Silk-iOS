//
//  AddPhoneBookFriend.h
//  OSell
//
//  Created by OsellMobile on 15/5/11.
//  Copyright (c) 2015年 DZSOIN. All rights reserved.
//

//#import "Base.h"
#import "AddPhoneBookCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface AddPhoneBookFriend : Base

@property (nonatomic, strong) NSString *shareUrl;
@property (assign,nonatomic) BOOL isFromProductMatchView;

@end
