//
//  ViewController.m
//  ZYAutoResizeLabel
//
//  Created by zhuyongqing on 2017/4/13.
//  Copyright © 2017年 zhuyongqing. All rights reserved.
//

#import "ViewController.h"
#import "ZYAutoLabel.h"
#import "UIView+ITTAdditions.h"
@interface ViewController ()<UIGestureRecognizerDelegate>{
    NSOperationQueue *_renderQueue;
}

@property(nonatomic,strong) UIView *labelBack;

@property(nonatomic,strong) ZYAutoLabel *autoLabel;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor grayColor];
    
    _renderQueue = [[NSOperationQueue alloc] init];
    [_renderQueue setMaxConcurrentOperationCount:1];
    
    _labelBack = [[UIView alloc] init];
    _labelBack.frame = CGRectMake(0, 0, self.view.z_width * 2, 100);
    _labelBack.backgroundColor = [UIColor redColor];
    _labelBack.layer.allowsEdgeAntialiasing = YES;
    [self.view addSubview:_labelBack];
    
    _autoLabel = [[ZYAutoLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    _autoLabel.text = @"AUTOLABEL";
    [_labelBack addSubview:_autoLabel];
    
    _labelBack.z_height = _autoLabel.z_height;
    
    _autoLabel.center = CGPointMake(_labelBack.z_width/2, _labelBack.z_height/2);
    
    _labelBack.center = self.view.center;
    
    
    [_autoLabel addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
    
    [_autoLabel addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
    
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotation.delegate = self;
    [_labelBack addGestureRecognizer:rotation];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    [_labelBack addGestureRecognizer:pinch];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


- (void)handleRotation:(UIGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        [self setAnchorPoint:CGPointMake(.5, .5) forView:_labelBack];
        
        if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]]) {
            
            [_renderQueue cancelAllOperations];
            [_renderQueue addOperationWithBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGFloat rotation = [(UIRotationGestureRecognizer *)gesture rotation];
                    _labelBack.transform = CGAffineTransformRotate(_labelBack.transform, rotation);
                    [(UIRotationGestureRecognizer *)gesture setRotation:0];
                });
            }];
            
            
        }else{
            //缩放
            _autoLabel.scale = [(UIPinchGestureRecognizer *)gesture scale];
            
            [(UIPinchGestureRecognizer *)gesture setScale:1.0];
            
        }
        
        
    }
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"center"]) {
        
    }
    
    if ([keyPath isEqualToString:@"bounds"]) {
        
        CGRect bounds = _labelBack.bounds;
        CGFloat oldHeight = bounds.size.height;
        
        bounds.size.height = _autoLabel.bounds.size.height;
        _labelBack.bounds = bounds;
         CGFloat offsetY = oldHeight - bounds.size.height;
        [self setAnchorPoint:CGPointMake(.5, _autoLabel.layer.anchorPoint.y) forView:_labelBack];
        if (_autoLabel.layer.anchorPoint.y == 1) {
            _autoLabel.z_centerY -= offsetY;
        }
        if (_labelBack.layer.anchorPoint.y == .5) {
            _autoLabel.z_centerY = _labelBack.bounds.size.height/2;
        }
        
       
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
