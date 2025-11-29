#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Video.h"

@interface VideoViewController : UIViewController <NSURLConnectionDelegate, UIWebViewDelegate>

@property (strong, nonatomic) Video *video;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *viewsLabel;
@property (strong, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navbar;
@property (weak, nonatomic) IBOutlet UITableView *rTable;
@property (nonatomic, strong) NSMutableArray *recommendedVideos;
@property (nonatomic, strong) NSMutableDictionary *imageCache;

@property (strong, nonatomic) NSURLConnection *videoExtractConnection;
@property (strong, nonatomic) NSMutableData *responseData;

- (instancetype)initWithVideo:(Video *)video;

@end