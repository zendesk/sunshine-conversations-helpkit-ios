//
//  ViewController.m
//  Smooch
//
//  Created by Mike Spensieri on 2015-10-11.
//  Copyright © 2015 Smooch Technologies. All rights reserved.
//

#import "ViewController.h"
#import "SmoochHelpKit.h"

@interface ViewController ()

@property UIImageView* imageView;
@property int backgroundIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 270, self.view.bounds.size.width, 30)];
    [button addTarget:self action:@selector(showTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Show" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    [self.view addSubview:button];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(0, 330, self.view.bounds.size.width, 30)];
    [button addTarget:self action:@selector(showWithHintTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Show+Hint" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    [self.view addSubview:button];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ios_1"]];
    }else{
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_1"]];
    }
    self.imageView.frame = self.view.bounds;
    [self.view addSubview:self.imageView];
    [self.view sendSubviewToBack:self.imageView];
    
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
}

-(void)showTapped
{
    [SmoochHelpKit show];
}

-(void)showWithHintTapped
{
    [SmoochHelpKit showWithGestureHint];
}

-(void)onSwipe:(UISwipeGestureRecognizer*)swipe
{
    if(swipe.direction == UISwipeGestureRecognizerDirectionLeft){
        [self previousBackground];
    }else{
        [self nextBackground];
    }
}

-(void)previousBackground
{
    self.backgroundIndex--;
    if(self.backgroundIndex == -1){
        self.backgroundIndex = 2;
    }
    
    [self updateImage];
}

-(void)nextBackground
{
    self.backgroundIndex = (self.backgroundIndex + 1) % 3;
    [self updateImage];
}

-(void)updateImage
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        switch (self.backgroundIndex) {
            case 0:
                [self.imageView setImage:[UIImage imageNamed:@"ios_1"]];
                break;
            case 1:
                [self.imageView setImage:[UIImage imageNamed:@"ios_2"]];
                break;
            case 2:
                [self.imageView setImage:[UIImage imageNamed:@"ios_3"]];
                break;
            default:
                break;
        }
    }else{
        switch (self.backgroundIndex) {
            case 0:
                [self.imageView setImage:[UIImage imageNamed:@"ipad_1"]];
                break;
            case 1:
                [self.imageView setImage:[UIImage imageNamed:@"ipad_2"]];
                break;
            case 2:
                [self.imageView setImage:[UIImage imageNamed:@"ipad_3"]];
                break;
            default:
                break;
        }
    }
}

@end
