#import <Foundation/Foundation.h>

@interface Video : NSObject

@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *views;
@property (nonatomic, strong) NSString *likes;
@property (nonatomic, strong) NSString *publishedAt;
@property (nonatomic, strong) NSString *commentCount;
@property (nonatomic, strong) NSArray *comments;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end