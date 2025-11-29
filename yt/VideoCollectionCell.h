//
//  VideoCollectionCell.h
//  yt
//
//  Created by CalvinK19 on 7/21/25.
//  Copyright (c) 2025 calvink19. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCollectionCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *thumbnailView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *creatorLabel;
@end