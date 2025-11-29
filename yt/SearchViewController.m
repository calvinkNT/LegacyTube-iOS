#import "SearchViewController.h"
#import "Video.h"
#import "VideoCell.h"
#import "VideoViewController.h"

@interface SearchViewController ()
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) NSMutableDictionary *imageCache;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videos = @[];
    self.imageCache = [NSMutableDictionary dictionary];
    
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 80;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSString *query = [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:
                           @"%@/get_search_videos.php?apikey=%@&query=%@",
                           [[NSUserDefaults standardUserDefaults] stringForKey:@"url"], [[NSUserDefaults standardUserDefaults] stringForKey:@"api"], query];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   NSLog(@"Search error: %@", error);
                                   return;
                               }
                               
                               NSError *jsonError;
                               NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                               if (jsonError) {
                                   NSLog(@"Parse error: %@", jsonError);
                                   return;
                               }
                               
                               NSMutableArray *results = [NSMutableArray array];
                               for (NSDictionary *dict in jsonArray) {
                                   Video *video = [[Video alloc] initWithDictionary:dict];
                                   [results addObject:video];
                               }
                               
                               self.videos = results;
                               [self.tableView reloadData];
                           }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"VideoCell";
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    Video *video = self.videos[indexPath.row];
    cell.titleLabel.text = video.title;
    cell.creatorLabel.text = video.author;
    cell.thumbnailView.image = [UIImage imageNamed:@"placeholder"];
    
    [self loadImageForIndexPath:indexPath thumbnailUrl:video.thumbnailUrl];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Video *video = self.videos[indexPath.row];
    VideoViewController *videoVC = [[VideoViewController alloc] initWithVideo:video];
    [self presentViewController:videoVC animated:YES completion:nil];
}

#pragma mark - Image Loading

- (void)loadImageForIndexPath:(NSIndexPath *)indexPath thumbnailUrl:(NSString *)urlString {
    UIImage *cached = self.imageCache[urlString];
    if (cached) {
        [self updateCellAtIndexPath:indexPath withImage:cached];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        UIImage *img = [UIImage imageWithData:data];
        if (img) {
            self.imageCache[urlString] = img;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateCellAtIndexPath:indexPath withImage:img];
            });
        }
    });
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath withImage:(UIImage *)image {
    VideoCell *cell = (VideoCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [UIView transitionWithView:cell.thumbnailView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            cell.thumbnailView.image = image;
                        } completion:nil];
    }
}

- (IBAction)backBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
