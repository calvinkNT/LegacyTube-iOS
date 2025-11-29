#import "VideoViewController.h"
#import "VideoCell.h"

@interface VideoViewController () <NSURLConnectionDelegate>
//@property (nonatomic, strong) NSURLConnection *videoExtractConnection;
@property (nonatomic, strong) NSURLConnection *metadataConnection;
//@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSMutableData *metadataResponseData;
@end

@implementation VideoViewController

- (instancetype)initWithVideo:(Video *)video {
    NSString *nibName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    ? @"VideoViewController_iPad"
    : @"VideoViewController";
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        _video = video;
        _responseData = [NSMutableData data];
        _metadataResponseData = [NSMutableData data];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure audio session for playback
    NSError *audioError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&audioError];
    if (audioError) {
        NSLog(@"Audio session error: %@", audioError);
    }
    
    [audioSession setActive:YES error:&audioError];
    if (audioError) {
        NSLog(@"Audio session activation error: %@", audioError);
    }
    
    // Initialise recommendation properties
    self.recommendedVideos = [NSMutableArray array];
    self.imageCache = [NSMutableDictionary dictionary];
    
    // Configure recommendation table
    self.rTable.dataSource = self;
    self.rTable.delegate = self;
    self.rTable.rowHeight = 80;
    
    // Start loading metadata first
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self fetchVideoMetadata];
}

- (void)fetchVideoMetadata {
    NSLog(@"Fetching metadata for Video ID: %@", self.video.videoId);
    NSString *apiUrlString = [NSString stringWithFormat:@"%@/get-ytvideo-info.php?video_id=%@&apikey=%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"url"], self.video.videoId, [[NSUserDefaults standardUserDefaults] stringForKey:@"api"]];
    NSURL *apiUrl = [NSURL URLWithString:apiUrlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:apiUrl];
    self.metadataConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.metadataResponseData setLength:0];
}

- (void)extractVideoURL {
    /*NSLog(@"Extracting video URL for Video ID: %@", self.video.videoId);
     // dont abuse my url pls, thanks
    NSString *extractUrlString = [NSString stringWithFormat:@"?id=%@", self.video.videoId];
    NSURL *extractUrl = [NSURL URLWithString:extractUrlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:extractUrl];
    self.videoExtractConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.responseData setLength:0];*/
    //[elf connection]
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.metadataConnection) {
        [self.metadataResponseData setLength:0];
    } else {
        [self.responseData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == self.metadataConnection) {
        [self.metadataResponseData appendData:data];
    } else {
        [self.responseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == self.metadataConnection) {
        // Handle metadata response
        NSError *error;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:self.metadataResponseData
                                                                     options:0
                                                                       error:&error];
        
        if (error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self showErrorAlert:@"Failed to parse video metadata"];
            return;
        }
        
        // Update video object with metadata
        self.video.title = jsonResponse[@"title"];
        self.video.author = jsonResponse[@"author"];
        self.video.views = jsonResponse[@"views"];
        self.video.likes = jsonResponse[@"likes"];
        self.video.publishedAt = jsonResponse[@"published_at"];
        self.video.duration = jsonResponse[@"duration"];
        self.video.descriptionText = jsonResponse[@"description"];
        
        [self setupMetadata];
        
        NSLog(@"feching recommendations");
        [self fetchRecommendations];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //[self playVideoWithURL:[NSURL URLWithString:jsonResponse[@"url"]]];
        NSLog(@"URL: %@", [NSString stringWithFormat:@"%@/direct_url?video_id=%@&proxy=%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"url"], self.video.videoId, [[NSUserDefaults standardUserDefaults] stringForKey:@"proxy"]]);
        [self playVideoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/direct_url?video_id=%@&proxy=%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"url"], self.video.videoId, [[NSUserDefaults standardUserDefaults] stringForKey:@"proxy"]]]];

    }
}

- (void)fetchRecommendations {
    NSString *urlString = [NSString stringWithFormat:
                           @"%@/get_related_videos.php?apikey=%@&video_id=%@&count=30",
                           [[NSUserDefaults standardUserDefaults] stringForKey:@"url"],
                           [[NSUserDefaults standardUserDefaults] stringForKey:@"api"],
                           self.video.videoId];
    NSLog(@"Rec. URL: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak VideoViewController *weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               VideoViewController *strongSelf = weakSelf;
                               if (!strongSelf) return;
                               
                               if (error) {
                                   NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                   message:errorMessage
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                                   [alert show];
                                   NSLog(@"Recommendation error: %@", error);
                                   return;
                               }
                               
                               NSError *jsonError;
                               NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                               
                               NSLog(@"JSON array: %@", jsonArray);
                               
                               if (jsonError) {
                                   NSString *errorMessage = [NSString stringWithFormat:@"JSON Error: %@", jsonError.localizedDescription];
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                   message:errorMessage
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                                   [alert show];
                                   NSLog(@"Recommendation JSON error: %@", jsonError);
                                   return;
                               }
                               
                               [strongSelf.recommendedVideos removeAllObjects];
                               for (NSDictionary *dict in jsonArray) {
                                   Video *video = [[Video alloc] init];
                                   video.videoId = dict[@"video_id"];
                                   video.title = dict[@"title"];
                                   video.author = dict[@"author"];
                                   video.thumbnailUrl = dict[@"thumbnail"];
                                   video.views = dict[@"views"];
                                   
                                   [strongSelf.recommendedVideos addObject:video];
                               }
                               
                               [strongSelf.rTable reloadData];
                               self.rTable.scrollEnabled = NO;
                               
                               CGRect tableFrame = self.rTable.frame;
                               tableFrame.size.height = self.rTable.contentSize.height;
                               self.rTable.frame = tableFrame;
                               UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:999];
                               
                               CGFloat totalHeight = CGRectGetMaxY(self.descriptionView.frame) + self.rTable.frame.size.height + 30;
                               
                               scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, totalHeight);

                           }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recommendedVideos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"VideoCell";
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Video *video = self.recommendedVideos[indexPath.row];
    cell.titleLabel.text = video.title;
    cell.creatorLabel.text = video.author;
    cell.thumbnailView.image = [UIImage imageNamed:@"placeholder"];
    
    cell.thumbnailView.frame = CGRectMake(10, 10, 90, 67);
    CGFloat titleX = CGRectGetMaxX(cell.thumbnailView.frame) + 10;
    CGFloat titleWidth = cell.contentView.bounds.size.width - titleX - 15;
    cell.titleLabel.frame = CGRectMake(titleX, 12, titleWidth, 38);
    cell.creatorLabel.frame = CGRectMake(titleX, CGRectGetMaxY(cell.titleLabel.frame) + 4, titleWidth, 18);
    
    [self loadImageForIndexPath:indexPath thumbnailUrl:video.thumbnailUrl];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Video *selectedVideo = self.recommendedVideos[indexPath.row];
    Video *newVideo = [[Video alloc] init];
    newVideo.videoId = selectedVideo.videoId;
    
    VideoViewController *videoVC = [[VideoViewController alloc] initWithVideo:newVideo];
    [self presentViewController:videoVC animated:YES completion:nil];
}

#pragma mark - Image Handling

- (void)loadImageForIndexPath:(NSIndexPath *)indexPath thumbnailUrl:(NSString *)thumbnailUrl {
    if (indexPath.row >= self.recommendedVideos.count) return;
    
    UIImage *cachedImage = self.imageCache[thumbnailUrl];
    if (cachedImage) {
        [self updateCellAtIndexPath:indexPath withImage:cachedImage];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:thumbnailUrl];
        if (!url) return;
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (image) {
            self.imageCache[thumbnailUrl] = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateCellAtIndexPath:indexPath withImage:image];
            });
        }
    });
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath withImage:(UIImage *)image {
    UITableViewCell *cell = [self.rTable cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[VideoCell class]]) {
        VideoCell *videoCell = (VideoCell *)cell;
        videoCell.thumbnailView.image = image;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (connection == self.metadataConnection) {
        [self showErrorAlert:@"Failed to fetch video metadata"];
    } else {
        [self showErrorAlert:@"Failed to get video URL"];
    }
    
    NSLog(@"Connection error: %@", error);
}

- (void)setupMetadata {
    if (self.navbar && self.video.title) {
        [self.navbar.topItem setTitle:self.video.title];
    }
    
    self.authorLabel.text = self.video.author ?: @"Unknown Author";
    self.viewsLabel.text = [NSString stringWithFormat:@"%@ views", self.video.views ?: @"0"];
    self.likesLabel.text = [NSString stringWithFormat:@"%@ likes", self.video.likes ?: @"0"];
    self.dateLabel.text = [self formattedDate:self.video.publishedAt] ?: @"Date not available";
    self.durationLabel.text = [self formattedDuration:self.video.duration] ?: @"";
    self.descriptionView.text = self.video.descriptionText ?: @"No description available";
    
    // only adjust if on iphoe
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.descriptionView.scrollEnabled = NO;
        
        CGSize sizeThatFits = [self.descriptionView sizeThatFits:CGSizeMake(self.descriptionView.frame.size.width, FLT_MAX)];
        CGRect descFrame = self.descriptionView.frame;
        descFrame.size.height = sizeThatFits.height;
        self.descriptionView.frame = descFrame;
        
        CGRect tableFrame = self.rTable.frame;
        tableFrame.origin.y = CGRectGetMaxY(self.descriptionView.frame) + 10.0; // 10pt padding
        self.rTable.frame = tableFrame;
        
        UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:999];
        CGFloat contentHeight = CGRectGetMaxY(self.rTable.frame) + 20.0;
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentHeight);
    }
    
    NSLog(@"Video ID: %@", self.video.videoId);
    NSLog(@"Title: %@", self.video.title);
    NSLog(@"Author: %@", self.video.author);
    NSLog(@"Views: %@", self.video.views);
    NSLog(@"Likes: %@", self.video.likes);
    NSLog(@"Published: %@", self.video.publishedAt);
    NSLog(@"Duration: %@", self.video.duration);
    NSLog(@"Description: %@", self.video.descriptionText);
}

- (NSString *)formattedDate:(NSString *)rawDate {
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    inputFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [inputFormatter setDateFormat:@"dd.MM.yyyy',' HH:mm:ss"];
    NSDate *date = [inputFormatter dateFromString:rawDate];
    
    if (!date) {
        [inputFormatter setDateFormat:@"dd.MM.yyyy"];
        date = [inputFormatter dateFromString:rawDate];
    }
    
    if (date) {
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        outputFormatter.dateStyle = NSDateFormatterMediumStyle;
        outputFormatter.timeStyle = NSDateFormatterNoStyle;
        return [outputFormatter stringFromDate:date];
    }
    
    return rawDate;
}


- (NSString *)formattedDuration:(NSString *)duration {
    if (![duration isKindOfClass:[NSString class]] || duration.length < 3) {
        return duration;
    }
    
    if ([duration hasPrefix:@"PT"] && [duration hasSuffix:@"S"]) {
        NSString *timePart = [duration substringWithRange:NSMakeRange(2, duration.length-3)];
        NSInteger minutes = 0;
        NSInteger seconds = 0;
        
        @try {
            NSRange mRange = [timePart rangeOfString:@"M"];
            if (mRange.location != NSNotFound) {
                NSString *minutesStr = [timePart substringToIndex:mRange.location];
                minutes = [minutesStr integerValue];
                timePart = [timePart substringFromIndex:mRange.location + 1];
            }
            
            NSRange sRange = [timePart rangeOfString:@"S"];
            if (sRange.location != NSNotFound) {
                NSString *secondsStr = [timePart substringToIndex:sRange.location];
                seconds = [secondsStr integerValue];
            } else {
                seconds = [timePart integerValue];
            }
            
            return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
        }
        @catch (NSException *exception) {
            NSLog(@"Error parsing duration: %@", exception);
            return duration;
        }
    }
    return duration;
}


- (void)playVideoWithURL:(NSURL *)videoURL {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:videoURL];
    [self.webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:
     @"var v=document.getElementsByTagName('video')[0];"
     @"if(v){v.play();}"];
}

- (void)showErrorAlert:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [_videoExtractConnection cancel];
    [_metadataConnection cancel];
    
    NSError *audioError = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&audioError];
    if (audioError) {
        NSLog(@"Audio session deactivation error: %@", audioError);
    }
    [_rTable setDelegate:nil];
    [_rTable setDataSource:nil];

}


@end