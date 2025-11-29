#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate> {
    NSString *previousSearchText;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *videos;
@property (strong, nonatomic) NSMutableDictionary *imageCache;

@property (strong, nonatomic) NSURLConnection *videoExtractConnection;
@property (strong, nonatomic) NSURLConnection *videoDownloadConnection;
@property (strong, nonatomic) NSMutableData *responseData;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)searchVCBtn:(id)sender;
- (IBAction)settingsBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UINavigationBar *titleBar;

@end