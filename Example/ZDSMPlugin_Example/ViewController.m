//
//  ViewController.m
//  ZDSMPlugin_Example
//
//  Created by Adrian Cayaco on 01/09/2016.
//  Copyright © 2016 Screenmeet. All rights reserved.
//

#import "ViewController.h"

#import "ZDSMPluginManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)startChatButtonWasPressed:(id)sender
{
    [[ZDSMPluginManager sharedManager] showChatWindow:^{
        
    }];
    
    [[ZDSMPluginManager sharedManager] showChatWindowFromViewController:self completion:^{
        
    }];
}

@end
