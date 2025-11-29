#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (nonatomic, assign) BOOL currentProxyState;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSavedSettings];
}

- (void)loadSavedSettings {
    NSString *proxyStateString = [[NSUserDefaults standardUserDefaults] stringForKey:@"proxy"];
    self.currentProxyState = [proxyStateString isEqualToString:@"true"];
    [self.proxySwitch setOn:self.currentProxyState animated:NO];
    
    NSString *savedApiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"api"];
    self.apiKey.text = savedApiKey ? savedApiKey : @"";
    
    NSString *savedServerUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url"];
    self.serverUrl.text = savedServerUrl ? savedServerUrl : @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)proxySwitchChanged:(UISwitch *)sender {
    self.currentProxyState = sender.on;
    NSLog(@"Proxy setting changed to: %@", sender.on ? @"ON" : @"OFF");
}

- (IBAction)dismissBtn:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.currentProxyState ? @"true" : @"false" forKey:@"proxy"];
    [[NSUserDefaults standardUserDefaults] setObject:self.apiKey.text forKey:@"api"];
    [[NSUserDefaults standardUserDefaults] setObject:self.serverUrl.text forKey:@"url"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"All settings saved");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end