//
//  VideoCollectionCell.m
//  yt
//
//  Created by CalvinK19 on 7/21/25.
//  Copyright (c) 2025 calvink19. All rights reserved.
//

#import "VideoCollectionCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation VideoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Title Label 
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_titleLabel];
        
        // Creator Label 
        _creatorLabel = [[UILabel alloc] init];
        _creatorLabel.font = [UIFont systemFontOfSize:10];
        _creatorLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_creatorLabel];
        
        // Thumbnail Image View 
        _thumbnailView = [[UIImageView alloc] init];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailView.clipsToBounds = YES;
        _thumbnailView.layer.cornerRadius = 6;
        _thumbnailView.layer.masksToBounds = YES;
        [self.contentView addSubview:_thumbnailView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat thumbnailHeight = width * 9 / 16;
    
    // Layout frames
    self.thumbnailView.frame = CGRectMake(0, 0, width, thumbnailHeight);
    self.titleLabel.frame = CGRectMake(5, thumbnailHeight + 5, width - 10, 30);
    self.creatorLabel.frame = CGRectMake(5, thumbnailHeight + 35, width - 10, 15); 
}

@end