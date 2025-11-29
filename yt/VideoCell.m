// VideoCell.m
#import "VideoCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation VideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Thumbnail Image View
        _thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 67)]; // 4:3 ratio for video thumbnail
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailView.clipsToBounds = YES;
        _thumbnailView.layer.cornerRadius = 6;
        _thumbnailView.layer.masksToBounds = YES;
        [self.contentView addSubview:_thumbnailView];
        
        // Title Label
        CGFloat titleX = CGRectGetMaxX(_thumbnailView.frame) + 10;
        CGFloat titleWidth = self.contentView.bounds.size.width - titleX - 15;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleX, 12, titleWidth, 38)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_titleLabel];
        
        // Creator Label
        _creatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleX, CGRectGetMaxY(_titleLabel.frame) + 4, titleWidth, 18)];
        _creatorLabel.font = [UIFont systemFontOfSize:13];
        _creatorLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_creatorLabel];
        
        // Optional: Accessory indicator
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

@end
