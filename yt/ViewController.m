#import "ViewController.h"
#import "Video.h"
#import "VideoCell.h"
#import "VideoViewController.h"
#import "SearchViewController.h"
#import "VideoCollectionCell.h"
#import "SettingsViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[VideoCollectionCell class] forCellWithReuseIdentifier:@"VideoCollectionCell"];
    
    self.imageCache = [NSMutableDictionary dictionary];
    
    // Detect device type
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    if (idiom == UIUserInterfaceIdiomPad) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        self.collectionView.hidden = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        
        self.tableView.hidden = YES;
    } else {
        self.tableView.hidden = NO;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.rowHeight = 80;
        
        self.collectionView.hidden = YES;
    }
    
    self.searchBar.delegate = self;
    
    [self fetchVideoData];
}


#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"VideoCell";
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Video *video = self.videos[indexPath.row];
    cell.titleLabel.text = video.title;
    cell.creatorLabel.text = video.author;
    cell.thumbnailView.image = [UIImage imageNamed:@"placeholder"];
    
    // Restore table view layout
    cell.thumbnailView.frame = CGRectMake(10, 10, 90, 67);
    CGFloat titleX = CGRectGetMaxX(cell.thumbnailView.frame) + 10;
    CGFloat titleWidth = cell.contentView.bounds.size.width - titleX - 15;
    cell.titleLabel.frame = CGRectMake(titleX, 12, titleWidth, 38);
    cell.creatorLabel.frame = CGRectMake(titleX, CGRectGetMaxY(cell.titleLabel.frame) + 4, titleWidth, 18);
    
    [self loadImageForIndexPath:indexPath thumbnailUrl:video.thumbnailUrl];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Video *selectedVideo = self.videos[indexPath.row];
    VideoViewController *videoVC = [[VideoViewController alloc] initWithVideo:selectedVideo];
    [self presentViewController:videoVC animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videos.count;
}

#pragma mark - Collection View

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    UIEdgeInsets insets = flowLayout.sectionInset;
    CGFloat availableWidth = collectionView.bounds.size.width - insets.left - insets.right;
    
    CGFloat interitemSpacing = flowLayout.minimumInteritemSpacing;
    availableWidth -= 2 * interitemSpacing;
    
    CGFloat itemWidth = availableWidth / 3;
    
    CGFloat itemHeight = (itemWidth * (9.0f / 16.0f)) + 50;
    
    return CGSizeMake(itemWidth, itemHeight);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"VideoCollectionCell";
    VideoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    Video *video = self.videos[indexPath.item];
    cell.titleLabel.text = video.title;
    cell.creatorLabel.text = video.author;
    cell.thumbnailView.image = [UIImage imageNamed:@"placeholder"];
    
    [self loadImageForIndexPath:indexPath thumbnailUrl:video.thumbnailUrl];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Video *selectedVideo = self.videos[indexPath.row];
    VideoViewController *videoVC = [[VideoViewController alloc] initWithVideo:selectedVideo];
    [self presentViewController:videoVC animated:YES completion:nil];

}
#pragma mark - Image Loading

- (void)loadImageForIndexPath:(NSIndexPath *)indexPath thumbnailUrl:(NSString *)thumbnailUrl {
    // Check cache first
    UIImage *cachedImage = self.imageCache[thumbnailUrl];
    if (cachedImage) {
        [self updateCellAtIndexPath:indexPath withImage:cachedImage];
        return;
    }
    
    // Load from network
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:thumbnailUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (image) {
            // Cache image
            self.imageCache[thumbnailUrl] = image;
            
            // Update UI on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateCellAtIndexPath:indexPath withImage:image];
            });
        }
    });
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath withImage:(UIImage *)image {
    // Update table view cell (iPhone)
    VideoCell *tableViewCell = (VideoCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (tableViewCell) {
        tableViewCell.thumbnailView.image = image;
    }
    
    // Update collection view cell (iPad)
    VideoCollectionCell *collectionCell = (VideoCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (collectionCell) {
        collectionCell.thumbnailView.image = image;
    }
}

#pragma mark - Data Fetching

- (void)fetchVideoData {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/get_top_videos.php?apikey=%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"url"], [[NSUserDefaults standardUserDefaults] stringForKey:@"api"]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak ViewController *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               ViewController *strongSelf = weakSelf;
                               if (!strongSelf) return;
                               
                               if (error) {
                                   NSLog(@"Error: %@", error);
                                   return;
                               }
                               
                               NSError *jsonError;
                               NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                               
                               if (jsonError) {
                                   NSLog(@"JSON Error: %@", jsonError);
                                   return;
                               }
                               
                               NSMutableArray *videos = [NSMutableArray array];
                               for (NSDictionary *dict in jsonArray) {
                                   Video *video = [[Video alloc] initWithDictionary:dict];
                                   [videos addObject:video];
                               }
                               
                               strongSelf.videos = videos;
                               

                               [strongSelf.tableView reloadData];
                               [strongSelf.collectionView reloadData];
                           }];
}

#pragma mark - Search Bar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *query = [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.titleBar.topItem.title = [NSString stringWithFormat:@"Search - %@", query];

    NSString *urlString = [NSString stringWithFormat:
                           @"%@/get_search_videos.php?apikey=%@&query=%@",
                           [[NSUserDefaults standardUserDefaults] stringForKey:@"url"],
                           [[NSUserDefaults standardUserDefaults] stringForKey:@"api"],
                           query];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak ViewController *weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               ViewController *strongSelf = weakSelf;
                               if (!strongSelf) return;
                               
                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               
                               if (error) {
                                   NSLog(@"Search request error: %@", error);
                                   return;
                               }
                               
                               NSError *jsonError;
                               NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                               
                               if (jsonError) {
                                   NSLog(@"JSON Parse Error: %@", jsonError);
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JSON parse error"
                                                                                   message:jsonError
                                                                                  delegate:self
                                                                         cancelButtonTitle:@"Cancel"
                                                                         otherButtonTitles:@"", nil];
                                   [alert show];
                                   return;
                               }
                               
                               NSMutableArray *results = [NSMutableArray array];
                               for (NSDictionary *dict in jsonArray) {
                                   Video *video = [[Video alloc] initWithDictionary:dict];
                                   [results addObject:video];
                               }
                               
                               strongSelf.videos = results;
                               [strongSelf.imageCache removeAllObjects];
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [strongSelf.tableView reloadData];
                                   [strongSelf.collectionView reloadData];
                               });
                           }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    BOOL clearedViaClearButton = previousSearchText.length > 0 && searchText.length == 0;
    
    if (clearedViaClearButton) {
        NSLog(@"Search bar cleared");
        self.titleBar.topItem.title = @"YouTube - Trending";

        [self fetchVideoData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [searchBar resignFirstResponder];
        });
    }
    
    previousSearchText = [searchText copy];
}

#pragma mark - Cleanup

- (void)dealloc {
    // Clean up any resources
    [self.videoExtractConnection cancel];
    [self.videoDownloadConnection cancel];
}

- (IBAction)searchVCBtn:(id)sender {
    SearchViewController *searchVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    [self presentViewController:searchVC animated:YES completion:nil];
}

- (IBAction)settingsBtn:(id)sender {
    SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self presentViewController:settingsVC animated:YES completion:nil];

}
@end