//
//  ArrangeTableViewCell.h
//  awesomesauce
//
//  Created by Ravi Parikh on 3/7/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ArrangeTableViewCell : UITableViewCell {
	IBOutlet UILabel *cellText;
}

- (void)setLabelText:(NSString *)txt;

@end
