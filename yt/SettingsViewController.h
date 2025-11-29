//
//  SettingsViewController.h
//  yt
//
//  Created by CalvinK19 on 7/21/25.
//  Copyright (c) 2025 calvink19. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *serverUrl;
@property (weak, nonatomic) IBOutlet UITextField *apiKey;
@property (weak, nonatomic) IBOutlet UISwitch *proxySwitch;
- (IBAction)dismissBtn:(id)sender;

@end
