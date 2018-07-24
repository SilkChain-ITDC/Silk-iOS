//
//  AddPhoneBookFriend.m
//  OSell
//
//  Created by OsellMobile on 15/5/11.
//  Copyright (c) 2015年 DZSOIN. All rights reserved.
//

#import "AddPhoneBookFriend.h"
#import "ChineseString.h"
#import "UIImageView+WebCache.h"
#import "CYWAlertView.h"
#import "BaseTapGesture.h"
#import "OSellPersonalInfoVC.h"

@interface AddPhoneBookFriend ()<UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>{
    NSArray *listContacts;
}

@property (weak, nonatomic) IBOutlet UITableView *phoneBookTable
;@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) BOOL isEditWithSearchBar;
@property (nonatomic, strong) NSMutableArray *selectPhoneArr; //选中的数组

@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) NSMutableArray *contactsArray; //联系人数组
@property (strong, nonatomic) NSMutableArray *searchArray; //搜索结果数组

@property (strong, nonatomic) NSMutableArray *indexArray; //引索数组
//设置每个section下的cell内容
@property (strong, nonatomic) NSMutableArray *LetterResultArr;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)submitEvent:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation AddPhoneBookFriend

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBackButton];
    [self.navigationController setNavigationBarHidden:NO];
  
    self.bottomLineHeightConstraint.constant = 0.6f;
    [self.submitButton setTitle:[NSString stringWithFormat:[self getString:@"AddPhoneBookFriend_You’ve already chosen N people; invite them to join now!"],(unsigned long)self.selectPhoneArr.count] forState:UIControlStateNormal];
    self.submitButton.layer.masksToBounds = YES;
    self.submitButton.layer.cornerRadius = 8.0f;
    
    [self loadBookPhone];
    
    self.shareUrl=[NSString stringWithFormat:@"%@%@",@"https://wallet.silkchain.io/Account/register?Code=",[[SilkLoginUserHelper shareInstance] getCurUserInfo].affiliateCode];
    
    self.searchBar.placeholder = [self getString:@"AddPhoneBookFriend_Search"];
    
    self.phoneBookTable.tableFooterView = [UIView new];
    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self searchController];
    self.phoneBookTable.sectionIndexBackgroundColor = [UIColor clearColor];
    self.phoneBookTable.sectionIndexColor = [UIColor blackColor];
    [self.phoneBookTable registerNib:[UINib nibWithNibName: @"AddPhoneBookCell" bundle: [NSBundle mainBundle]] forCellReuseIdentifier: @"CELL"];
    [self.searchController.searchResultsTableView registerNib: [UINib nibWithNibName: @"AddPhoneBookCell"
                                                                              bundle: [NSBundle mainBundle]] forCellReuseIdentifier: @"CELL"];
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.8)];
    footerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.searchController.searchResultsTableView.tableFooterView = footerView;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.phoneBookTable.hidden = NO;
    self.searchController.searchResultsTableView.hidden = NO;
    self.bottomView.hidden = NO;
    
    self.title=[self getString:@"AddPhoneBookFriend_Phone Contacts"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.phoneBookTable.hidden = YES;
    self.searchController.searchResultsTableView.hidden = YES;
    self.bottomView.hidden = YES;
}

- (void)loadBookPhone{
    ABAddressBookRef addressBook = nil;
     __block BOOL accessGranted = NO;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
         });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    if (accessGranted==NO) {
        [self alertMessage:[self getString:@"AddPhoneBookFriend_ContactsAuthority"]];
        return;
    }
    NSArray *paxuqian= listContacts = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    // 利用block进行排序
    listContacts=[paxuqian sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result=[CFBridgingRelease(ABRecordCopyValue(CFBridgingRetain(obj1), kABPersonFirstNameProperty)) compare:CFBridgingRelease(ABRecordCopyValue(CFBridgingRetain(obj2), kABPersonFirstNameProperty))];
        if (result==NSOrderedSame) {
            result=[CFBridgingRelease(ABRecordCopyValue(CFBridgingRetain(obj1), kABPersonLastNameProperty)) compare:CFBridgingRelease(ABRecordCopyValue(CFBridgingRetain(obj2), kABPersonLastNameProperty))];
        }
        return result;
    }];
    [self updateLoadPhoneServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateLoadPhoneServer{
    
    if (listContacts.count > 0) {
        [DZProgress show:[self getString:@"loading..."]];
//        if ([[[NSUserDefaults standardUserDefaults]objectForNotNullKey:@"savephoneServer"] intValue]<0) {
            NSString *contentString=@"";
            NSMutableArray *conatarrar=[[NSMutableArray alloc]init];
            for (int p=0; p<listContacts.count; p++) {
                ABRecordRef thisPerson = CFBridgingRetain([listContacts objectAtNotNullIndex:p]);
                //查找这条记录中的名字
                NSString *firstName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty));
                firstName = firstName != nil? firstName:@"";
                //查找这条记录中的姓氏
                NSString *lastName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonLastNameProperty));
                lastName = lastName != nil? lastName:@"";
                NSString *userstring=[lastName stringByAppendingString:firstName];
                //读取organization公司
                NSString *organization = (NSString*)CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonOrganizationProperty));
                //读取birthday生日
                NSString *birthday = (NSString *)CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonBirthdayProperty));               
                
                //获取email多值
                NSString *emailString=@"";
                ABMultiValueRef email = ABRecordCopyValue(thisPerson, kABPersonEmailProperty);
                long emailcount = ABMultiValueGetCount(email);
                for (int x = 0; x < emailcount; x++)
                {
                    //获取email值
                   emailString = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(email, x));
                }
                
                //获取URL多值
                NSString *urlString=@"";
                ABMultiValueRef url = ABRecordCopyValue(thisPerson, kABPersonURLProperty);
                for (int m = 0; m < ABMultiValueGetCount(url); m++)
                {
                    urlString = (__bridge NSString*)ABMultiValueCopyValueAtIndex(url,m);
                    
                }
                
                
                //读取地址多值
                NSString *addressString=@"";
                ABMultiValueRef address = ABRecordCopyValue(thisPerson, kABPersonAddressProperty);
                long count = ABMultiValueGetCount(address);
                for(int j = 0; j < count; j++)
                {
                    //获取地址Label
                    NSString* addressLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(address, j);
                    addressString = [addressString stringByAppendingFormat:@"%@,",addressLabel];
                    //获取該label下的地址6属性
                    NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
                    NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
                    if(country != nil)
                        addressString = [addressString stringByAppendingFormat:@"国家：%@,",country];
                    NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
                    if(city != nil)
                        addressString = [addressString stringByAppendingFormat:@"城市：%@,",city];
                    NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
                    if(state != nil)
                        addressString = [addressString stringByAppendingFormat:@"省：%@,",state];
                    NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
                    if(street != nil)
                        addressString = [addressString stringByAppendingFormat:@"街道：%@,",street];
                    NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
                    if(zip != nil)
                        addressString = [addressString stringByAppendingFormat:@"邮编：%@,",zip];
                    NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
                    if(coutntrycode != nil)
                        addressString = [addressString stringByAppendingFormat:@"国家编号：%@,",coutntrycode];
                }
                
                
                
                //读取电话多值
                ABMultiValueRef phone = ABRecordCopyValue(thisPerson, kABPersonPhoneProperty);
                for (int k = 0; k<ABMultiValueGetCount(phone); k++)
                {
                    //获取电话Label
                    NSString * personPhoneString = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                    personPhoneString=[personPhoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
                    personPhoneString=[personPhoneString stringByReplacingOccurrencesOfString:@"  " withString:@""];
                    
                    NSString *personPhone = [personPhoneString stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    if (![personPhone isEqualToString:[[SilkLoginUserHelper shareInstance] getCurUserInfo].phone]) {
                        [conatarrar addObject:[self setdiclist:userstring mobile:personPhoneString company:organization Url:urlString email:emailString address:addressString birthday:birthday]];
                    }
                    
                }
                
            }
            
            //
            NSMutableDictionary *userdic=[[NSMutableDictionary alloc]init];
            [userdic setValue:[[SilkLoginUserHelper shareInstance] getCurUserInfo].userId forKey:@"userid"];
            [userdic setValue:conatarrar forKey:@"userlist"];
            [userdic setValue:@"" forKey:@"phonenum"];
        
            NSData *postData = [NSJSONSerialization dataWithJSONObject:userdic options:NSJSONWritingPrettyPrinted error:nil];
            contentString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        
            NSString *address = [NSString stringWithFormat:@"%@Service/SaveBookInfo",[[SilkServerConfig shareInstance] addressForBaseAPI]];
            NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
            [parameter setValue: contentString forKey: @"content"];
            [parameter setValue: [InternationalizationHelper getLocalizeion] forKey: @"lan"];
        
        
        [[SilkHttpServerHelper shareInstance] requestHTTPDataWithAPI:address andHeader:nil andBody:parameter andSuccessBlock:^(SilkAPIResult *apiResult) {
            
            if (apiResult.apiCode == 0) {
                
                [DZProgress dismiss];
                
                if(![apiResult.dataResult isKindOfClass:[NSDictionary class]]) return;
                NSArray *dataArr = [apiResult.dataResult objectForNotNullKey:@"UserList"];
                for (int i = 0; i < dataArr.count; i++) {
                    NSDictionary *userDic = dataArr[i];
                    NSMutableDictionary *newDic = userDic.mutableCopy;
                    [newDic setObject:[NSString stringWithFormat:@"%i",i] forKey:@"screenId"]; //排序id
                    [self.contactsArray addObject:newDic];
                }
                
                NSMutableArray *friendArray = [NSMutableArray new];
                NSMutableArray *friendNameArray = [NSMutableArray new];
                for (NSDictionary *userDic in self.contactsArray) {
                    
                    [friendArray addObject:userDic];
                    [friendNameArray addObject:[[userDic objectForNotNullKey:@"UserType"] integerValue] == 0 ? [userDic objectForNotNullKey:@"RealName"]:[NSString stringWithFormat:@"%@(%@)",[NSString isNullOrEmpty:[userDic objectForNotNullKey:@"RealName"]] ? [userDic objectForNotNullKey:@"Mobile"] : [userDic objectForNotNullKey:@"RealName"], [userDic objectForNotNullKey:@"NickName"]]];
                }
                [self.LetterResultArr addObjectsFromArray:[ChineseString LetterPhoneArray:friendArray]];
                [self.indexArray addObjectsFromArray:[ChineseString IndexArray:friendNameArray]];
                
                [self.phoneBookTable reloadData];
                
                
                
            } else {
                
                [DZProgress dismiss];
                [self makeToast:apiResult.errorMsg];
                
            }
        } andFailBlock:^(SilkAPIResult *apiResult) {
            
            [DZProgress dismiss];
            [self makeToast:apiResult.errorMsg];
        } andTimeOutBlock:^(SilkAPIResult *apiResult) {
            
            [DZProgress dismiss];
            [self makeToast:apiResult.errorMsg];
        } andLoginBlock:^(SilkAPIResult *apiResult) {
            
        }];
        
    }
    
}



- (NSMutableDictionary *)setdiclist:(NSString *)username mobile:(NSString *)mob company:(NSString *)companyN Url:(NSString *)url email:(NSString *)email address:(NSString *)ad birthday:(NSString *)bri{
    NSMutableDictionary *userphone=[[NSMutableDictionary alloc]init];
    [userphone setValue:[NSString stringWithFormat:@"%@",username].length == 0 ? companyN == nil ? @"":[NSString stringWithFormat:@"%@",companyN] : [NSString stringWithFormat:@"%@",username] forKey:@"realname"];
    [userphone setValue:[NSString stringWithFormat:@"%@",mob] forKey:@"mobile"];
    [userphone setValue:companyN == nil ? @"":[NSString stringWithFormat:@"%@",companyN] forKey:@"company"];
    [userphone setValue:[NSString stringWithFormat:@"%@",url] forKey:@"url"];
    [userphone setValue:[NSString stringWithFormat:@"%@",email] forKey:@"email"];
    [userphone setValue:[NSString stringWithFormat:@"%@",ad] forKey:@"address"];
    [userphone setValue:[NSString stringWithFormat:@"%@",bri] forKey:@"birthday"];
    return userphone;
}



#pragma mark -----UITableViewDataSource--

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 显示
    if (tableView == self.phoneBookTable) {
        
        return self.indexArray.count;
    }
    // 搜索结果
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // 显示
    if (tableView == self.phoneBookTable) {
        
        NSArray *userArr = [self.LetterResultArr objectAtNotNullIndex:section];
        return userArr.count;
        
    }
    // 搜索结果
    else {
        return self.searchArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AddPhoneBookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    
    if (tableView == self.phoneBookTable) {
        
        NSArray *userArr = [self.LetterResultArr objectAtNotNullIndex:indexPath.section];
        NSDictionary *userDic = [userArr objectAtNotNullIndex: indexPath.row];
        
        cell.addFriendBtn.tag = [[userDic objectForNotNullKey:@"screenId"] integerValue]+1;
        //usertype:0代表未注册,1代表已注册(不是好友),2代表好友
        if ([[userDic objectForNotNullKey:@"UserType"] integerValue] == 0) { //未注册的本地
            cell.NetDataView.hidden = YES;
            cell.LocationView.hidden = NO;
            cell.locationNickLabel.text = [NSString isNullOrEmpty:[userDic objectForNotNullKey:@"RealName"]] ? [userDic objectForNotNullKey:@"Mobile"] : [userDic objectForNotNullKey:@"RealName"];
            if ([self.selectPhoneArr containsObject:[userDic objectForNotNullKey:@"screenId"]]) {
                cell.selectImgView.image = [UIImage imageNamed:@"icon_caregr_redselect"];
            }else {
                cell.selectImgView.image = [UIImage imageNamed:@"icon_caregroup_kuang"];
            }
            
        }else {
            cell.NetDataView.hidden = NO;
            cell.LocationView.hidden = YES;
            //      cell.authImgView.hidden = YES; //认证状态
            cell.netNickLabel.text = [NSString stringWithFormat:@"%@(%@)",[NSString isNullOrEmpty:[userDic objectForNotNullKey:@"RealName"]] ? [userDic objectForNotNullKey:@"Mobile"] : [userDic objectForNotNullKey:@"RealName"], [userDic objectForNotNullKey:@"NickName"]];
            [cell.headImgView sd_setImageWithURL:[NSURL URLWithString:[userDic objectForNotNullKey:@"Faceimg"]] placeholderImage:[UIImage imageNamed:@"chat_tab_defaut"]];
            BaseTapGesture *tap = [[BaseTapGesture alloc] initWithTarget:self action:@selector(headImgViewTapAction:)];
            tap.theTag = [[userDic objectForNotNullKey:@"screenId"] integerValue]+1;
            cell.headImgView.userInteractionEnabled = YES;
            [cell.headImgView addGestureRecognizer:tap];
            
            if ([[userDic objectForNotNullKey:@"UserType"] integerValue] == 1) { //1代表已注册(不是好友)
                cell.addFriendBtn.backgroundColor = UIColorFromRGB(0x17AAF6);
                cell.addFriendBtn.userInteractionEnabled = YES;
                [cell.addFriendBtn setTitle:[self getString:@"AddPhoneBookFriend_Add Friend"] forState:UIControlStateNormal];
                [cell.addFriendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                cell.addFriendBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            }else { //2代表好友
                cell.addFriendBtn.backgroundColor = [UIColor whiteColor];
                cell.addFriendBtn.userInteractionEnabled = NO;
                [cell.addFriendBtn setTitle:[self getString:@"AddPhoneBookFriend_Added"] forState:UIControlStateNormal];
                [cell.addFriendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                cell.addFriendBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
            }
        }
        
        
        //分割线
        if (indexPath.row == [[self.LetterResultArr objectAtNotNullIndex:indexPath.section] count]-1) {
            cell.bottomLine.hidden = YES;
        }else {
            cell.bottomLine.hidden = NO;
        }
        
        
    }else {
        if (self.searchArray && self.searchArray.count > indexPath.section) {
            
            NSDictionary *userDic = [self.searchArray objectAtNotNullIndex:indexPath.row];
            
            cell.addFriendBtn.tag = [[userDic objectForNotNullKey:@"screenId"] integerValue]+1;
            //usertype:0代表未注册,1代表已注册(不是好友),2代表好友
            if ([[userDic objectForNotNullKey:@"UserType"] integerValue] == 0) { //未注册的本地
                cell.NetDataView.hidden = YES;
                cell.LocationView.hidden = NO;
                cell.locationNickLabel.text = [NSString isNullOrEmpty:[userDic objectForNotNullKey:@"RealName"]] ? [userDic objectForNotNullKey:@"Mobile"] : [userDic objectForNotNullKey:@"RealName"];
                if ([self.selectPhoneArr containsObject:[userDic objectForNotNullKey:@"screenId"]]) {
                    cell.selectImgView.image = [UIImage imageNamed:@"icon_caregr_redselect"];
                }else {
                    cell.selectImgView.image = [UIImage imageNamed:@"icon_caregroup_kuang"];
                }
                
            }else {
                cell.NetDataView.hidden = NO;
                cell.LocationView.hidden = YES;
                //      cell.authImgView.hidden = YES; //认证状态
                cell.netNickLabel.text = [NSString stringWithFormat:@"%@(%@)",[NSString isNullOrEmpty:[userDic objectForNotNullKey:@"RealName"]] ? [userDic objectForNotNullKey:@"Mobile"] : [userDic objectForNotNullKey:@"RealName"], [userDic objectForNotNullKey:@"NickName"]];
                [cell.headImgView sd_setImageWithURL:[NSURL URLWithString:[userDic objectForNotNullKey:@"Faceimg"]] placeholderImage:[UIImage imageNamed:@"chat_tab_defaut"]];
                BaseTapGesture *tap = [[BaseTapGesture alloc] initWithTarget:self action:@selector(headImgViewTapAction:)];
                tap.theTag = [[userDic objectForNotNullKey:@"screenId"] integerValue]+1;
                cell.headImgView.userInteractionEnabled = YES;
                [cell.headImgView addGestureRecognizer:tap];
                
                if ([[userDic objectForNotNullKey:@"UserType"] integerValue] == 1) { //1代表已注册(不是好友)
                    cell.addFriendBtn.backgroundColor = UIColorFromRGB(0x17AAF6);
                    cell.addFriendBtn.userInteractionEnabled = YES;
                    [cell.addFriendBtn setTitle:[self getString:@"AddPhoneBookFriend_Add Friend"] forState:UIControlStateNormal];
                    [cell.addFriendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    cell.addFriendBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
                }else { //2代表好友
                    cell.addFriendBtn.backgroundColor = [UIColor whiteColor];
                    cell.addFriendBtn.userInteractionEnabled = NO;
                    [cell.addFriendBtn setTitle:[self getString:@"AddPhoneBookFriend_Added"] forState:UIControlStateNormal];
                    [cell.addFriendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                    cell.addFriendBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
                }
            }
            
            //分割线
            if (indexPath.row == [self.searchArray count]-1) {
                cell.bottomLine.hidden = YES;
            }else {
                cell.bottomLine.hidden = NO;
            }
            
        }
    }
    
    [cell.addFriendBtn addTarget:self action:@selector(addFriendBtnActioin:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//头像点击事件
- (void)headImgViewTapAction:(BaseTapGesture *)tap
{
    for (NSDictionary *userDic in self.contactsArray) {
        //循环查找点击的user
        if ([[userDic objectForNotNullKey:@"screenId"] integerValue] == tap.theTag-1) {
            
            if ([[userDic objectForNotNullKey:@"ReadUserType"] integerValue] == 1) { //供应商 进入企业信息
                
//                OSellGuestUserInfoViewController *vc = [[OSellGuestUserInfoViewController alloc] init];
//                vc.userid = [userDic objectForNotNullKey:@"UserId"];
//                vc.screenId = [[userDic objectForNotNullKey:@"screenId"] integerValue];
//                vc.addFriendSuccessBlock = ^(NSInteger screenId){
//                    [self reloadSomeOneCellDataWithScreenId:screenId];
//                };
//                [self pushController:vc];
                
            }else {
                
                OSellPersonalInfoVC *personalInfoVC = [[OSellPersonalInfoVC alloc] init];
                id lock = self.navigationController.navigationlock;
                personalInfoVC.userId = [userDic objectForNotNullKey:@"UserId"];
                personalInfoVC.screenId = [[userDic objectForNotNullKey:@"screenId"] integerValue];
                personalInfoVC.addFriendSuccessBlock = ^(NSInteger screenId){
                    [self reloadSomeOneCellDataWithScreenId:screenId];
                };
                personalInfoVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:personalInfoVC animated:YES navigationLock:lock];
            }
            
            
        }
    }
}

//添加好友按钮 事件
- (void)addFriendBtnActioin:(UIButton *)sender
{
    for (NSDictionary *userDic in self.contactsArray) {
        //循环查找点击的user
        if ([[userDic objectForNotNullKey:@"screenId"] integerValue] == sender.tag-1) {
            
            NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
            
            [parameter setValue: @"to_friend" forKey: @"action"];
            [parameter setValue: [userDic objectForNotNullKey:@"Uid"] forKey: @"fuid"];
            [parameter setValue: [[SilkLoginUserHelper shareInstance] getCurUserInfo].uId forKey: @"uid"];
            [parameter setValue:[InternationalizationHelper getLocalizeion] forKey:@"lan"];
            
            [DZProgress show:[self getString:@"loading..."]];
            
            
            [[SilkHttpServerHelper shareInstance] requestHTTPDataWithAPI:[NSString stringWithFormat:@"%@DinoDirect/Friend/Index",[[SilkServerConfig shareInstance] addressForBaseAPI]] andHeader:nil andBody:parameter andSuccessBlock:^(SilkAPIResult *apiResult) {
                
                if (apiResult.apiCode == 0) {
                    
                    [DZProgress dismiss];
                    
                    [CYWAlertView cywShow:[self getString:@"AddPhoneBookFriend_Has been sent"]];
                    
                    
                    
                } else {
                    
                    [DZProgress dismiss];
                    if ([apiResult.errorMsg isEqualToString:@"already friend, don't need to add again"]) {
                        [self makeToast:[self getString:@"AddPhoneBookFriend_You have been added as a friend"]];
                        //刷新该cell
                        [self reloadSomeOneCellDataWithScreenId:sender.tag-1];
                    }
                    else {
                        [self makeToast:[self getString:@"AddPhoneBookFriend_Send failed"]];
                    }
                    
                }
            } andFailBlock:^(SilkAPIResult *apiResult) {
                
                [DZProgress dismiss];
                if ([apiResult.errorMsg isEqualToString:@"already friend, don't need to add again"]) {
                    [self makeToast:[self getString:@"AddPhoneBookFriend_You have been added as a friend"]];
                    //刷新该cell
                    [self reloadSomeOneCellDataWithScreenId:sender.tag-1];
                }
                else {
                    [self makeToast:[self getString:@"AddPhoneBookFriend_Send failed"]];
                }
            } andTimeOutBlock:^(SilkAPIResult *apiResult) {
                
            } andLoginBlock:^(SilkAPIResult *apiResult) {
                
            }];
            
            
        }
    }
}

- (void)reloadSomeOneCellDataWithScreenId:(NSInteger)theScreenId
{
    
    //修改LetterResultArr
    NSInteger arrCount = self.LetterResultArr.count;
    for (int i = 0; i < arrCount; i++) {
        
        NSArray *userArr = [self.LetterResultArr objectAtNotNullIndex:i];
        NSInteger smallArrCount = userArr.count;
        for (int j = 0; j < smallArrCount; j++) {
            NSMutableDictionary *userDic = [userArr objectAtNotNullIndex: j];
            if ([[userDic objectForNotNullKey:@"screenId"] integerValue] == theScreenId) {
                [userDic setObject:@"2" forKey:@"UserType"];
            }
        }
    }
    
    //修改searchArray
    NSInteger arrCount2 = self.searchArray.count;
    for (int i = 0; i < arrCount2; i++) {
        NSMutableDictionary *userDic = [self.searchArray objectAtNotNullIndex: i];
        if ([[userDic objectForNotNullKey:@"screenId"] integerValue] == theScreenId) {
            [userDic setObject:@"2" forKey:@"UserType"];
        }
    }
    
    //修改contactsArray
    NSInteger arrCount3 = self.contactsArray.count;
    for (int i = 0; i < arrCount3; i++) {
        NSMutableDictionary *userDic2 = [self.contactsArray objectAtNotNullIndex: i];
        if ([[userDic2 objectForNotNullKey:@"screenId"] integerValue] == theScreenId) {
            [userDic2 setObject:@"2" forKey:@"UserType"];
        }
    }
    
    [self.phoneBookTable reloadData];
    [self.searchController.searchResultsTableView reloadData];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 显示
    if (tableView == self.phoneBookTable) {
        
        UIView *groupcell = [[UIView alloc] init];
        groupcell.backgroundColor = [UIColor whiteColor];
        groupcell.frame = CGRectMake(0, 0, tableView.frame.size.width, 20);
        groupcell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UILabel *groupLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-10, 20)];
        groupLabel.text = [self.indexArray objectAtNotNullIndex:section];
        groupLabel.font = [UIFont systemFontOfSize:14.0];
        [groupcell addSubview:groupLabel];
        
        return groupcell;
    }
    // 搜索结果
    else {
        return nil;
    }
}


-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indexArray;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // 显示
    if (tableView == self.phoneBookTable) {
        return 20;
        
    }
    // 搜索结果
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AddPhoneBookCell *cell;
    NSDictionary *userDic;
    // 显示
    if (tableView == self.phoneBookTable) {
        
        cell = (AddPhoneBookCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSArray *userArr = [self.LetterResultArr objectAtNotNullIndex:indexPath.section];
        userDic = [userArr objectAtNotNullIndex: indexPath.row];
        if ([[userDic objectForNotNullKey:@"UserType"] integerValue] != 0) { //已注册的
            return;
        }
    }
    
    // 搜索结果
    else {
        
        cell = (AddPhoneBookCell *)[tableView cellForRowAtIndexPath:indexPath];
        userDic = [self.searchArray objectAtNotNullIndex: indexPath.row];
        if ([[userDic objectForNotNullKey:@"UserType"] integerValue] != 0) { //已注册的
            return;
        }
    }
    
    for (NSString *screenId in self.selectPhoneArr) {
        if ([screenId integerValue] == [[userDic objectForNotNullKey:@"screenId"] integerValue]) {
            cell.selectImgView.image = [UIImage imageNamed:@"icon_caregroup_kuang"];
            [self.selectPhoneArr removeObject:screenId];
            [_submitButton setTitle:[NSString stringWithFormat:[self getString:@"AddPhoneBookFriend_You’ve already chosen N people; invite them to join now!"],(unsigned long)self.selectPhoneArr.count] forState:UIControlStateNormal];
            return;
        }
        
    }
    cell.selectImgView.image = [UIImage imageNamed:@"icon_caregr_redselect"];
    [self.selectPhoneArr addObject:[userDic objectForNotNullKey:@"screenId"]];
    [_submitButton setTitle:[NSString stringWithFormat:[self getString:@"AddPhoneBookFriend_You’ve already chosen N people; invite them to join now!"],(unsigned long)self.selectPhoneArr.count] forState:UIControlStateNormal];
    
}


- (IBAction)submitEvent:(UIButton *)sender {
    if (self.selectPhoneArr.count>0) {
        [self send_SMS];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[self getString:@"AddPhoneBookFriend_no contacts"] delegate:self cancelButtonTitle:[self getString:@"AddPhoneBookFriend_Confirm"] otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)send_SMS{
    
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    
    if (messageClass != nil) {
        // Check whether the current device is configured for sending SMS messages
        if ([messageClass canSendText]) {
            [self displaySMSComposerSheet];
        }
        else {
            //  feedbackMsg.hidden = NO;
            //  feedbackMsg.text = @"Device not configured to send SMS.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[self getString:@"AddPhoneBookFriend_Device not configured to send SMS"] delegate:self cancelButtonTitle:[self getString:@"AddPhoneBookFriend_Cancel"] otherButtonTitles:nil];
            //[alert setTag:5];
            [alert show];
        }
    }
    else {
        // feedbackMsg.hidden = NO;
        // feedbackMsg.text = @"Device not configured to send SMS.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[self getString:@"AddPhoneBookFriend_Device not configured to send SMS"] delegate:self cancelButtonTitle:[self getString:@"AddPhoneBookFriend_Cancel"] otherButtonTitles:nil];
        //[alert setTag:5];
        [alert show];
        
    }
    
    
}

- (NSMutableArray *)returnPhoneNumber{
    
    NSMutableArray *phonArr=[[NSMutableArray alloc]init];
    for (NSString *screenId in self.selectPhoneArr) {
       
        for (NSDictionary *userDic in self.contactsArray) {
            //循环查找选中的user
            if ([[userDic objectForNotNullKey:@"screenId"] integerValue] == [screenId integerValue]) {
                
                [phonArr addObject:[userDic objectForNotNullKey:@"Mobile"]];
            }
        }
        
    }
    
    return phonArr;
}

// Displays an SMS composition interface inside the application.
-(void)displaySMSComposerSheet
{
    
    NSString *shareContent=[NSString stringWithFormat:@"%@ %@",[self getString:@"AddNewFriendVC_invite you to join this chat"],_shareUrl];
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    picker.body=shareContent;
    picker.recipients = [self returnPhoneNumber];
    [self presentViewController:picker animated:YES completion:^{
        
    }];
    
}



- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.searchArray removeAllObjects];
    
    NSString *key = [searchString lowercaseString];
    
    if (self.contactsArray && self.contactsArray.count > 0)
    {
        for (NSDictionary *userDic in self.contactsArray)
        {
            NSString *showName = [[userDic objectForNotNullKey:@"UserType"] integerValue] == 0 ? [userDic objectForNotNullKey:@"RealName"]:[NSString stringWithFormat:@"%@(%@)",[NSString isNullOrEmpty:[userDic objectForNotNullKey:@"RealName"]] ? [userDic objectForNotNullKey:@"Mobile"] : [userDic objectForNotNullKey:@"RealName"], [userDic objectForNotNullKey:@"NickName"]];
            NSString *val = [[showName stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
            
            if (NSNotFound != [val rangeOfString: key].location)
            {
                [self.searchArray addObject: userDic];
            }
        }
    }
    [self.searchController.searchResultsTableView reloadData];
    
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    self.isEditWithSearchBar = YES;
    UIButton *voiceBtn = (UIButton *)[self.searchBar viewWithTag:1001];
    voiceBtn.frame = CGRectMake(SCREEN_WIDTH-95-6, 11, 13, 20);
    UIButton *voiceBigBtn = (UIButton *)[self.searchBar viewWithTag:1002];
    voiceBigBtn.frame = CGRectMake(SCREEN_WIDTH-95-16, 6, 33, 30);
    
    //修改searchBar的取消按钮的文案
    UIView * view = [self.searchBar.subviews objectAtNotNullIndex:0];
    for (int i = 0; i < view.subviews.count; i++)
    {
        if ([[view.subviews objectAtNotNullIndex:i] isKindOfClass:[UIButton class]])
        {
            
            [(UIButton *)[view.subviews objectAtNotNullIndex:i]setTitle:[self getString:@"AddPhoneBookFriend_Cancel"] forState:UIControlStateNormal] ;
            
        }
    }
//修改搜索列表的 “无结果” 的文案
//    NSArray *sub = self.searchController.searchResultsTableView.subviews;
//    for (int i = 0; i < sub.count; i++)
//    {
//        if ([[sub objectAtNotNullIndex:i] isKindOfClass:[UILabel class]])
//        {
//
//            [(UILabel *)[sub objectAtNotNullIndex:i]setText:[self getString:@"Cancel"]];
//
//        }
//    }
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.isEditWithSearchBar = NO;
    UIButton *voiceBtn = (UIButton *)[self.searchBar viewWithTag:1001];
    voiceBtn.frame = CGRectMake(SCREEN_WIDTH-40-6, 11, 13, 20);
    UIButton *voiceBigBtn = (UIButton *)[self.searchBar viewWithTag:1002];
    voiceBigBtn.frame = CGRectMake(SCREEN_WIDTH-40-16, 6, 33, 30);

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.phoneBookTable reloadData];
}

#pragma mark - Getters

- (UISearchDisplayController *)searchController
{
    if (!_searchController) {
        
        _searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.searchResultsDataSource = self;
        _searchController.searchResultsDelegate = self;
        _searchController.delegate = self;
    }
    return _searchController;
}

- (NSMutableArray *)contactsArray
{
    if (!_contactsArray) {
        _contactsArray = [[NSMutableArray alloc] init];
    }
    return _contactsArray;
}

- (NSMutableArray *)indexArray
{
    if (!_indexArray) {
        _indexArray = [[NSMutableArray alloc] init];
        
    }
    return _indexArray;
}

-(NSMutableArray *)LetterResultArr
{
    if (!_LetterResultArr) {
        _LetterResultArr = [[NSMutableArray alloc] init];
        
    }
    return _LetterResultArr;
}

- (NSMutableArray *)searchArray
{
    if (!_searchArray) {
        _searchArray = [[NSMutableArray alloc] init];
    }
    return _searchArray;
}

- (NSMutableArray *)selectPhoneArr
{
    if (!_selectPhoneArr) {
        _selectPhoneArr=[[NSMutableArray alloc]init];
    }
    return _selectPhoneArr;
}

@end
