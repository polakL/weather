//
//  LocationFindViewController.h
//  Weather
//
//  Created by Ludvik Polak on 28.10.14.
//  Copyright (c) 2014 com.ludvikpolak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationFindViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *viewSearch;

@property (weak, nonatomic) IBOutlet UITextField *textFieldSearch;

- (IBAction)buttonCloseTap:(id)sender;

@end
