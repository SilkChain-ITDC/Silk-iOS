//
//  SilkAppStopTipView.m
//  OSell
//
//  Created by Tom on 2018/10/18.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "SilkAppStopTipView.h"

@interface SilkAppStopTipView ()

@property(nonatomic,strong)UIView *vForBackground;
@property(nonatomic,strong)UIView *vForContent;
@property(nonatomic,strong)UIView *vForTitle;
@property(nonatomic,strong)UILabel *lblTitle;
@property(nonatomic,strong)UITextView *txtContent;

@property(nonatomic,assign)BOOL isStoping;
@property(nonatomic,strong)NSString *tipMessage;
@property(nonatomic,assign)NSInteger countDownTime;



- (void)readyUI;


@end

@implementation SilkAppStopTipView


- (id)init {
    self = [super init];
    if (!self) return nil;
    
    [self readyUI];
    
    return self;
}

- (void)readyUI{
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo([[UIScreen mainScreen] bounds].size);
        make.width.equalTo(@([[UIScreen mainScreen] bounds].size.width));
        
    }];
    
    self.vForBackground=[[UIView alloc] init];
    [self.vForBackground setBackgroundColor:[UIColor blackColor]];
    [self.vForBackground setAlpha:0.8f];
    
    [self addSubview:self.vForBackground];
    [self.vForBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self);
        
    }];
    
    self.vForContent=[[UIView alloc] init];
    [self.vForContent setBackgroundColor:[UIColor whiteColor]];
    self.vForContent.layer.cornerRadius=5.f;
    self.vForContent.layer.masksToBounds=YES;
    [self addSubview:self.vForContent];
    
    [self.vForContent mas_makeConstraints:^(MASConstraintMaker *make) {
        
        CGFloat content_W=[[UIScreen mainScreen] bounds].size.width*3/4;
        CGFloat content_H=[[UIScreen mainScreen] bounds].size.height*2/3;
        
        make.width.equalTo(content_W);
        make.height.equalTo(content_H);
        make.center.equalTo(CGPointMake(0, 0));
        
        
    }];
    
    
    self.vForTitle=[[UIView alloc] init];
    [self.vForTitle setBackgroundColor:[UIColor whiteColor]];
    [self.vForContent addSubview:self.vForTitle];
    
    [self.vForTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(self.vForContent);
        make.height.equalTo(60);
        make.top.equalTo(self.vForContent.top).offset(0);
        make.left.equalTo(self.vForContent.left).offset(0);
        
    }];
    
    self.lblTitle=[[UILabel alloc] init];
    
    [self.lblTitle setBackgroundColor:[UIColor colorWithRed:80/255.0f green:129/255.0f blue:197/255.0f alpha:1]];
    [self.lblTitle setTextAlignment:(NSTextAlignmentCenter)];
    [self.lblTitle setTextColor:[UIColor blackColor]];
    [self.vForTitle addSubview:self.lblTitle];
    
    [self.lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(self.vForTitle);
        make.center.equalTo(CGPointMake(0, 0));
        
        
    }];
    
    self.txtContent=[[UITextView alloc] init];
    [self.vForContent addSubview:self.txtContent];
    
    [self.txtContent setBackgroundColor:[UIColor whiteColor]];
    [self.txtContent setEditable:NO];
    [self.txtContent setSelectable:NO];
    
    
    [self.txtContent setFont:[UIFont systemFontOfSize:13.f]];
    
    
    [self.txtContent mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.vForTitle.mas_bottom).offset(0);
        make.left.equalTo(self.vForContent.mas_left).offset(4);
        make.right.equalTo(self.vForContent.mas_right).offset(-4);
        make.bottom.equalTo(self.vForContent.mas_bottom).offset(0);
        
    }];
    
    
    
}


- (void)showViewWhitTitle:(NSString *)theTitle andInfo:(NSDictionary *)dictInfo{
    

    
    [self.lblTitle setText:theTitle];
    
    self.isStoping=[[dictInfo objectForKey:@"isEnable"] boolValue];
    self.tipMessage=[NSString stringWithFormat:@"%@",[dictInfo objectForKey:@"message"]];
    self.countDownTime=[[dictInfo objectForKey:@"isEnable"] integerValue];
    
    self.txtContent.text=self.tipMessage;
    
    UIWindow *appWindow=[[UIApplication sharedApplication] keyWindow];
    [appWindow addSubview:self];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
