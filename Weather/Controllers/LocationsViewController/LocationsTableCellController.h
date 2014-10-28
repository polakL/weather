//
//  LocationsTableCellController.h
//  Weather
//
//  Created by Ludvik Polak on 28.10.14.
//  Copyright (c) 2014 com.ludvikpolak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationsTableCellController : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelPlaceName;
@property (weak, nonatomic) IBOutlet UILabel *labelWeatherDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelTempC;

@property (weak, nonatomic) IBOutlet UIImageView *imageSelected;

@end
