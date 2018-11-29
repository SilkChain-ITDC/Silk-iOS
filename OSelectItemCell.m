//
//  OSelectItemCell.m
//  OSell
//
//  Created by xlg on 2018/1/8.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "OSelectItemCell.h"

#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Extension.h"

@interface OSelectItemCell ()
{
    UIView *imageBView;    
    UIImageView *imageHead;
    
    UILabel *lblTitle;
    UIView *redView;  
}

@end

@implementation OSelectItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self layoutViews];
    }
    return self;
}

- (void)layoutViews {
    WS(weakSelf);

    imageBView = [[UIView alloc] init];
    imageBView.clipsToBounds = YES;
    imageBView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:imageBView];
    [imageBView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(weakSelf.contentView);
        make.leading.equalTo(weakSelf.contentView).offset(15);
        make.width.equalTo(@(35));
    }];

    imageHead = [[UIImageView alloc] init];
    imageHead.backgroundColor = [UIColor clearColor];
    [imageBView addSubview:imageHead];
    [imageHead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.centerY.equalTo(imageBView);
        make.width.height.equalTo(@(25));
    }];

    lblTitle = [[UILabel alloc] initWithText:@"" textColor:RGBCOLOR(51, 51, 51) fontSize:15];
    [self.contentView addSubview:lblTitle];
    [lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(imageBView.mas_trailing);
        make.centerY.equalTo(weakSelf.contentView);
    }];

    redView = [[UIView alloc] init];
    redView.backgroundColor = [UIColor redColor];
    redView.layer.cornerRadius = 3.0;
    redView.layer.masksToBounds = YES;
    [self.contentView addSubview:redView];
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lblTitle).offset(2);
        make.leading.equalTo(lblTitle.mas_trailing).offset(4);
        make.width.height.equalTo(@(6));
    }];
    
    redView.hidden = YES;
}


- (void)setupImage:(id)image title:(NSString *)title {
    BOOL hasImage = NO;
    if (image) {

        if ([image isKindOfClass:[UIImage class]]) {
            hasImage = YES;
            imageHead.image = image;
        } else if ([image isKindOfClass:[NSString class]]) {
            if ([image hasPrefix:@"http://"] || [image hasPrefix:@"https://"]) {
                hasImage = YES;
                [imageHead sd_setImageWithURL:[NSURL URLWithString:image]];
            } else {
                UIImage *theImage = [UIImage imageNamed:image];
                if (image) {
                    hasImage = YES;
                    imageHead.image = theImage;
                }
            }
        }
    }

    if (hasImage) {
        [imageBView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(35));
        }];
    } else {
        [imageBView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(0));
        }];
    }
    
    lblTitle.text = [NSString stringWithFormat:@"%@", title];
}

- (void)showRedDotWithIsShow:(BOOL)isShow {
    if (isShow) {
        redView.hidden = NO;
    } else {
        redView.hidden = YES;
    }
}


@end


