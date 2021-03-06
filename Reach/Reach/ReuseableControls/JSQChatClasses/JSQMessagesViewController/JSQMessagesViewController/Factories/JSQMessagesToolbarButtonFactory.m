//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesToolbarButtonFactory.h"

#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "NSBundle+JSQMessages.h"



@implementation JSQMessagesToolbarButtonFactory

+ (UIButton *)defaultAccessoryButtonItem
{
    UIImage *accessoryImage = [UIImage imageNamed:@"attachment"];//[QMChatResources imageNamed:@"attachment_ic"];
    
    //    UIImage *normalImage = [accessoryImage imageMaskedWithColor:[UIColor lightGrayColor]];
    //    UIImage *highlightedImage = [accessoryImage imageMaskedWithColor:[UIColor darkGrayColor]];
    
    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessoryImage.size.width, 32.0f)];
    [accessoryButton setImage:accessoryImage forState:UIControlStateNormal];
    [accessoryButton setImage:accessoryImage forState:UIControlStateHighlighted];
    
    accessoryButton.contentMode = UIViewContentModeScaleAspectFit;
    accessoryButton.backgroundColor = [UIColor clearColor];

    return accessoryButton;
}

+ (UIButton *)defaultSendButtonItem
{
   // NSString *sendTitle = [NSBundle jsq_localizedStringForKey:@"send"];

    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
//    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
//    [sendButton setTitleColor:[UIColor jsq_messageBubbleBlueColor] forState:UIControlStateNormal];
//    [sendButton setTitleColor:[[UIColor jsq_messageBubbleBlueColor] jsq_colorByDarkeningColorWithValue:0.1f] forState:UIControlStateHighlighted];
//    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

    [sendButton setImage:[UIImage imageNamed:@"sendMsgIcon"] forState: UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    sendButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    sendButton.titleLabel.minimumScaleFactor = 0.85f;
    sendButton.contentMode = UIViewContentModeCenter;
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.tintColor = [UIColor jsq_messageBubbleBlueColor];

    CGFloat maxHeight = 29.0f;

//    CGRect sendTitleRect = [sendTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight)
//                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                                attributes:@{ NSFontAttributeName : sendButton.titleLabel.font }
//                                                   context:nil];
    
    

    sendButton.frame = CGRectMake(0.0f, 0.0f, 33.0f, maxHeight);

    return sendButton;
}

@end
