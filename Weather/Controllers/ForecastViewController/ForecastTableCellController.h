//
//  ForecastTableCellController.h
//  Weather
//
//  Created by Ludvik Polak on 27.10.14.
//  Copyright (c) 2014 com.ludvikpolak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForecastTableCellController : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelDayName;
@property (weak, nonatomic) IBOutlet UILabel *labelWeatherDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelTempC;


@end
