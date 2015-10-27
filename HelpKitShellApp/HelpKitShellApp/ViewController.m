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
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test10"]];
    }else{
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test1_ipad"]];
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
        self.backgroundIndex = 11;
    }
    
    [self updateImage];
}

-(void)nextBackground
{
    self.backgroundIndex = (self.backgroundIndex + 1) % 12;
    [self updateImage];
}

-(void)updateImage
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        switch (self.backgroundIndex) {
            case 0:
                [self.imageView setImage:[UIImage imageNamed:@"etsy"]];
                break;
            case 1:
                [self.imageView setImage:[UIImage imageNamed:@"test1"]];
                break;
            case 2:
                [self.imageView setImage:[UIImage imageNamed:@"test2"]];
                break;
            case 3:
                [self.imageView setImage:[UIImage imageNamed:@"test3"]];
                break;
            case 4:
                [self.imageView setImage:[UIImage imageNamed:@"test4"]];
                break;
            case 5:
                [self.imageView setImage:[UIImage imageNamed:@"test5"]];
                break;
            case 6:
                [self.imageView setImage:[UIImage imageNamed:@"test6"]];
                break;
            case 7:
                [self.imageView setImage:[UIImage imageNamed:@"test7"]];
                break;
            case 8:
                [self.imageView setImage:[UIImage imageNamed:@"test8"]];
                break;
            case 9:
                [self.imageView setImage:[UIImage imageNamed:@"test9"]];
                break;
            case 10:
                [self.imageView setImage:[UIImage imageNamed:@"test10"]];
                break;
            case 11:
                [self.imageView setImage:[UIImage imageNamed:@"test11"]];
                break;
            default:
                break;
        }
    }else{
        switch (self.backgroundIndex) {
            case 0:
                [self.imageView setImage:[UIImage imageNamed:@"test1_ipad"]];
                break;
            case 1:
                [self.imageView setImage:[UIImage imageNamed:@"test2_ipad"]];
                break;
            case 2:
                [self.imageView setImage:[UIImage imageNamed:@"test3_ipad"]];
                break;
            case 3:
                [self.imageView setImage:[UIImage imageNamed:@"test4_ipad"]];
                break;
            case 4:
                [self.imageView setImage:[UIImage imageNamed:@"test5_ipad"]];
                break;
            case 5:
                [self.imageView setImage:[UIImage imageNamed:@"test6_ipad"]];
                break;
            case 6:
                [self.imageView setImage:[UIImage imageNamed:@"test7_ipad"]];
                break;
            case 7:
                [self.imageView setImage:[UIImage imageNamed:@"test8_ipad"]];
                break;
            case 8:
                [self.imageView setImage:[UIImage imageNamed:@"test9_ipad"]];
                break;
            case 9:
                [self.imageView setImage:[UIImage imageNamed:@"test10_ipad"]];
                break;
            default:
                break;
        }
    }
}

@end
