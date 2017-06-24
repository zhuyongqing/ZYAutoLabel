//
//  ZYAutoLabel.m
//  ImageSlide
//
//  Created by zhuyongqing on 2017/4/6.
//  Copyright © 2017年 zhuyongqing. All rights reserved.
//

#import "ZYAutoLabel.h"
#import "UIView+ITTAdditions.h"

typedef NS_ENUM(NSInteger,ZYAutoLabelTouchType) {
    ZYAutoLabelTouchTypeLeftTop,
    ZYAutoLabelTouchTypeRightTop,
    ZYAutoLabelTouchTypeLeftBottom,
    ZYAutoLabelTouchTypeRifhtBottom,
};

@interface ZYAutoLabel()<UIGestureRecognizerDelegate>{
    UITouch *_lastTouch;
    CGPoint _lastPoint;
    
    CGPoint _viewPoint;
    
    CGRect _defalutRect;
    
    Float64 _scaleX;
    Float64 _scaleY;
    
    float _offSetX;
    float _offSetY;
    
    CGPoint _center;
}

@property(nonatomic,assign) CGFloat translateX;
@property(nonatomic,assign) CGFloat translateY;

@property(nonatomic,strong) UILabel *autoLabel;

@property(nonatomic,strong) UIView *touchView;

@property(nonatomic,strong) UIView *leftTop;

@property(nonatomic,strong) UIView *rightTop;

@property(nonatomic,strong) UIView *leftBottom;


@property(nonatomic,assign) double rotationAngle;

@property(nonatomic,strong) NSOperationQueue *rotationQueue;

@property(nonatomic,strong) UIView *boardView;


@property(nonatomic,assign) ZYAutoLabelTouchType touchType; //



@end

//static inline double radians (double degrees) {return degrees * M_PI/180;}
//static inline double degrees (double radians) {return radians * 180/M_PI;}

//CGFloat angleBetweenPoints(CGPoint first, CGPoint second) {
//    CGFloat height = second.y - first.y;
//    CGFloat width = first.x - second.x;
//    CGFloat rads = atan(height/width);
//    return degrees(rads);
//    //degs = degrees(atan((top - bottom)/(right - left)))
//}

#define KMaxWidth [UIScreen mainScreen].bounds.size.width
#define KMaxHeight [UIScreen mainScreen].bounds.size.height

#define KTouchViewWidth 20
#define KSpace 20
/** 随机色 */
#define KarcRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

@implementation ZYAutoLabel

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
//        self.backgroundColor = [UIColor whiteColor];
//        self.layer.borderColor = [UIColor whiteColor].CGColor;
//        self.layer.borderWidth = 1;
        
        self.rotationQueue = [[NSOperationQueue alloc] init];
        self.rotationQueue.maxConcurrentOperationCount = 1;
        
        _autoLabel = [[UILabel alloc] init];
        _autoLabel.numberOfLines = 0;
        _autoLabel.font = [UIFont systemFontOfSize:100];
        _autoLabel.textColor = KarcRandomColor;
        _autoLabel.textAlignment = NSTextAlignmentCenter;
        _autoLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_autoLabel];
        
        _touchView = [self getTouchView];
        _leftTop = [self getTouchView];
        _rightTop = [self getTouchView];
        _leftBottom = [self getTouchView];
        
        [self addSubview:_leftTop];
        [self addSubview:_leftBottom];
        [self addSubview:_rightTop];
        [self addSubview:_touchView];
        
        _boardView = [[UIView alloc] init];
        _boardView.layer.borderColor = [UIColor whiteColor].CGColor;
        _boardView.backgroundColor = [UIColor clearColor];
        _boardView.opaque = YES;
        _boardView.layer.borderWidth = 1;
        _boardView.layer.allowsEdgeAntialiasing = YES;
        [self addSubview:_boardView];
        
//        UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchAndRotate:)];
//        rotation.delegate = self;
//        [self addGestureRecognizer:rotation];
        
        
//        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchAndRotate:)];
//        [self addGestureRecognizer:pinch];
        _scaleY = 1;
        _scaleX = 1;
        
//        self.layer.anchorPoint = CGPointMake(0, 0);
    }
    return self;
}

#pragma mark - 初始化 设置 文字 大小
- (void)setText:(NSString *)text{
    _text = text;
    CGSize labelSize = [text boundingRectWithSize:CGSizeMake(KMaxWidth, KMaxHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:50]} context:nil].size;
    self.z_size = labelSize;
    
    _defalutRect = self.frame;
    
    _autoLabel.text = text;
    
    _autoLabel.frame = CGRectMake(KSpace, KSpace, self.z_width - KTouchViewWidth*2, self.z_height - KTouchViewWidth*2);
    _boardView.frame = CGRectMake(KSpace/2, KSpace/2, self.z_width - KTouchViewWidth,self.z_height - KTouchViewWidth);
    
    [self layoutAutoLabelTouchViewWithRect:self.bounds];

}


- (void)layoutAutoLabelTouchViewWithRect:(CGRect)bounds{
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    _touchView.frame = CGRectMake(width - KSpace, height - KSpace, KTouchViewWidth, KTouchViewWidth);
    _leftTop.frame = CGRectMake(0, 0, KTouchViewWidth, KTouchViewWidth);
    _rightTop.frame = CGRectMake(width - KSpace, 0, KTouchViewWidth, KTouchViewWidth);
    _leftBottom.frame = CGRectMake(0, height - KSpace, KTouchViewWidth, KTouchViewWidth);
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint point = view.layer.anchorPoint;
    
    if (point.x == anchorPoint.x && point.y == anchorPoint.y) {
        return;
    }
    
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



- (BOOL)isContainsViewWithPoint:(CGPoint)point{
    
    BOOL leftTop = [self jugeTouchView:self.leftTop containPoint:point];
    BOOL rightTop = [self jugeTouchView:self.rightTop containPoint:point];
    BOOL leftBottom = [self jugeTouchView:self.leftBottom containPoint:point];
    BOOL rightBottom = [self jugeTouchView:self.touchView containPoint:point];
    
    if (!leftTop && !leftBottom && !rightTop && !rightBottom) {
        return NO;
    }
    if (leftTop) {
        self.touchType = ZYAutoLabelTouchTypeLeftTop;
    }else if (rightTop){
        self.touchType = ZYAutoLabelTouchTypeRightTop;
    }else if (leftBottom){
        self.touchType = ZYAutoLabelTouchTypeLeftBottom;
    }else if (rightBottom){
        self.touchType = ZYAutoLabelTouchTypeRifhtBottom;
    }
    return YES;
}

- (BOOL)jugeTouchView:(UIView *)touchView containPoint:(CGPoint)point{
    CGRect donwR = [self convertRect:touchView.frame toView:self.selfView];
    donwR = CGRectMake(donwR.origin.x - 10, donwR.origin.y - 10, donwR.size.width + 10, donwR.size.height + 10);
    if (CGRectContainsPoint(donwR, point)) {
        return YES;
    }
    return NO;
}

#pragma mark - 手指点击 移动
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.selfView];
    
    if ([self isContainsViewWithPoint:point]) {
        _lastTouch = touch;
        _lastPoint = point;
        
    }else if(touch.tapCount == 1){
        _viewPoint = point;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.selfView];
    
    if (touch == _lastTouch) {
        
        //改变 锚点
        [self changeTouchViewArchPoint];
        
        CGFloat offsetX = point.x - _lastPoint.x;
        CGFloat offsetY = point.y - _lastPoint.y;
        
        CGPoint anchorPoint = self.layer.anchorPoint;
        
        if (anchorPoint.y == 1) {
            offsetY = _lastPoint.y - point.y;
        }
        
        if (anchorPoint.x == 1) {
            offsetX = _lastPoint.x - point.x;
        }
        
        
        if (self.z_width + offsetX < 50 || self.z_height + offsetY < 30) {
            return;
        }
        
        //改变 大小
        //计算 缩放的 比例
        CGFloat tempScaleX = (self.z_width + offsetX) / self.z_width;
        CGFloat tempScaleY = (self.z_height + offsetY) / self.z_height;
        
        _scaleX *= tempScaleX;
        _scaleY *= tempScaleY;
        
        [self.rotationQueue cancelAllOperations];
        [self.rotationQueue addOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resizeFrame];
            });
        }];
        
        _lastPoint = point;
    }else if(touch.tapCount == 1){
        
        //移动位置
//        CGFloat offsetX = point.x - _viewPoint.x;
//        CGFloat offsetY = point.y - _viewPoint.y;
//        
//        [self.rotationQueue cancelAllOperations];
//        [self.rotationQueue addOperationWithBlock:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                CGAffineTransform t = CGAffineTransformTranslate(self.transform, 0, 0);
//                self.transform = t;
//                self.z_centerX += offsetX;
//                self.z_centerY += offsetY;
//            });
//        }];
        
        _viewPoint = point;
    }
    
}



- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _lastTouch = nil;
    _lastPoint = CGPointZero;
    
    _viewPoint = CGPointZero;
}


#pragma mark - 更新界面大小
- (void)resizeFrame{
    
    self.transform = CGAffineTransformScale(self.transform, 1, 1);
    
    CGRect rect = CGRectZero;
    rect.size.width = _defalutRect.size.width * _scaleX;
    rect.size.height = _defalutRect.size.height * _scaleY;
    self.bounds = rect;
    self.autoLabel.z_size = CGSizeMake(rect.size.width - KSpace*2, rect.size.height - KSpace*2);
    self.autoLabel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.boardView.z_size = CGSizeMake(rect.size.width - KSpace, rect.size.height - KSpace);
    self.boardView.center = self.autoLabel.center;
    
    [self layoutAutoLabelTouchViewWithRect:rect];
}

- (void)setScale:(CGFloat)scale{
    _scale = scale;
    
    [self setAnchorPoint:CGPointMake(.5, .5) forView:self];
    
    _scaleX *= scale;
    _scaleY *= scale;
    [self.rotationQueue cancelAllOperations];
    [self.rotationQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resizeFrame];
        });
    }];
}


- (void)handlePinchAndRotate:(UIGestureRecognizer *)gesture{
//    [gesture isKindOfClass:[UIPinchGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateChanged
    if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateChanged) {
        if (self.layer.anchorPoint.x != 0.5 || self.layer.anchorPoint.y != 0.5) {
            [self changeArchPointToCenter];
        }
        //缩放
        _scaleX *= [(UIPinchGestureRecognizer *)gesture scale];
        _scaleY *= [(UIPinchGestureRecognizer *)gesture scale];
        [self.rotationQueue cancelAllOperations];
        [self.rotationQueue addOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resizeFrame];
            });
        }];
        [(UIPinchGestureRecognizer *)gesture setScale:1.0];
    }else if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateChanged){
        //旋转
        UIView *view = gesture.view;
        if (self.layer.anchorPoint.x != 0.5 || self.layer.anchorPoint.y != 0.5) {
            [self changeArchPointToCenter];
        }
        
        double angle = [(UIRotationGestureRecognizer *)gesture rotation];
        view.transform = CGAffineTransformRotate(view.transform, angle);
        [(UIRotationGestureRecognizer *)gesture setRotation:0];
        
    }

}

- (UIView *)getTouchView{
    UIView *touchView = [[UIView alloc] init];
    touchView.backgroundColor = [UIColor yellowColor];
    touchView.userInteractionEnabled = YES;
    touchView.layer.cornerRadius = KTouchViewWidth/2;
    touchView.clipsToBounds = YES;
    
    return touchView;
}

- (void)changeArchPointToCenter{
    [self setAnchorPoint:CGPointMake(.5, .5) forView:self];
}

- (void)changeTouchViewArchPoint{

    CGPoint anrchPoint;
    
    switch (self.touchType) {
        case ZYAutoLabelTouchTypeLeftTop:{
            anrchPoint = CGPointMake(1, 1);
        }
            
            break;
        case ZYAutoLabelTouchTypeRightTop:{
            anrchPoint = CGPointMake(0, 1);
        }
            break;
        case ZYAutoLabelTouchTypeRifhtBottom:{
            anrchPoint = CGPointMake(0, 0);
        }
            
            break;
        case ZYAutoLabelTouchTypeLeftBottom:{
            anrchPoint = CGPointMake(1, 0);
        }
            
            break;
        default:
            break;
    }
    
    [self setAnchorPoint:anrchPoint forView:self];
    
}
 
@end
