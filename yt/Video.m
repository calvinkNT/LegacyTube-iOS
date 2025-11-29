#import "Video.h"

@implementation Video

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _videoId = dict[@"video_id"] ?: @"";
        _title = dict[@"title"] ?: @"";
        _author = dict[@"author"] ?: @"";
        _thumbnailUrl = dict[@"thumbnail"] ?: @"";
        _descriptionText = dict[@"description"] ?: @"";
        _duration = dict[@"duration"] ?: @"";
        _views = dict[@"views"] ?: @"";
        _likes = dict[@"likes"] ?: @"";
        _publishedAt = dict[@"published_at"] ?: @"";
        _commentCount = dict[@"comment_count"] ?: @"";
        _comments = dict[@"comments"] ?: @[];
    }
    return self;
}

@end