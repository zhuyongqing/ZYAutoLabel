//
//  ViewControllerB.m
//  ZYAutoResizeLabel
//
//  Created by zhuyongqing on 2017/6/22.
//  Copyright © 2017年 zhuyongqing. All rights reserved.
//

#import "ViewControllerB.h"
#import "UIView+ITTAdditions.h"

@interface ViewControllerB ()

@property(nonatomic,strong) UIView *rotateView;

@property(nonatomic,strong) UIView *backView;



@end

@implementation ViewControllerB

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _backView = [[UIView alloc] init];
    _backView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_backView];
    
    _rotateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    _rotateView.backgroundColor = [UIColor blueColor];
    _rotateView.center = self.view.center;
    [self.view addSubview:_rotateView];
    
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateHandle:)];
    [_rotateView addGestureRecognizer:rotate];
    
    _backView.frame = _rotateView.frame;
    
    UIButton *anchorPointBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [anchorPointBtn setTitle:@"Change" forState:UIControlStateNormal];
    [anchorPointBtn addTarget:self action:@selector(changeAnchorPointAction) forControlEvents:UIControlEventTouchUpInside];
    [anchorPointBtn sizeToFit];
    anchorPointBtn.z_centerX = self.view.z_centerX;
    anchorPointBtn.z_centerY = self.view.z_height - 100;
    [self.view addSubview:anchorPointBtn];
}

- (void)changeAnchorPointAction{
    if (_rotateView.layer.anchorPoint.y == .5) {
        _rotateView.layer.position = CGPointMake(_rotateView.layer.position.x, _rotateView.z_origin.y);
        _rotateView.layer.anchorPoint = CGPointMake(.5, 0);
    }
}

- (void)rotateHandle:(UIRotationGestureRecognizer *)rotate{
    
    if (_rotateView.layer.anchorPoint.y == 0) {
        _rotateView.layer.position = CGPointMake(_rotateView.layer.position.x, _rotateView.z_centerY);
        _rotateView.layer.anchorPoint = CGPointMake(.5, .5);
    }
    
    CGFloat angle = rotate.rotation;
    
    _rotateView.transform = CGAffineTransformRotate(_rotateView.transform, angle);
    
    _backView.frame = _rotateView.frame;
    
    rotate.rotation = 0;
    
    NSLog(@"%@\n-%@\n--%@\n",NSStringFromCGRect(_rotateView.frame),NSStringFromCGPoint(_rotateView.layer.position),NSStringFromCGPoint(_rotateView.center));
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
