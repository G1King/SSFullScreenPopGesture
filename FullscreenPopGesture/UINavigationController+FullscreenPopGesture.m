//
//  UINavigationController+FullscreenPopGesture.m
//  FullscreenPopGesture
//
//  Created by Sobf Sunshinking on 16/12/12.
//  Copyright © 2016年 SOBF. All rights reserved.
//

#import "UINavigationController+FullscreenPopGesture.h"
#import <objc/runtime.h>

@interface ss_FullPopGesture : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic,weak) UINavigationController * navgationController;
@end
@implementation ss_FullPopGesture

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    
    if (self.navgationController.viewControllers.count <= 1) {
        return  NO;
    }
    UIViewController  * topVC = self.navgationController.viewControllers.lastObject;
    if (topVC.ss_interativePopDisEnable) {
        return  NO;
    }
    
    
    CGPoint begin = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat distance = topVC.ss_MaxAllowedInitialDistanceToLeftEdge;
    if (distance > 0 && begin.x > distance) {
        return  NO;
    }
    
    if ([[self.navgationController valueForKeyPath:@"_isTransitioning"] boolValue]) {
        return  NO;
    }
    
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    
    if (translation.x<=0) {
        return  NO;
    }
    
    
    return  YES;
}
@end

typedef void(^ss_ViewControllerWillAppearInjectBlock)(UIViewController * viewcontroller , BOOL animated);
@interface UIViewController (FullscreenPopGesturePriviate)

@property (nonatomic,copy) ss_ViewControllerWillAppearInjectBlock block;

@end

@implementation UIViewController (FullscreenPopGesturePriviate)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originSelector = @selector(viewWillAppear:);
        
        SEL swizzSelector = @selector(ss_viewWillAppear:);
        
        Method originMethod =  class_getInstanceMethod(class, originSelector);
        
        Method swizzMethod =  class_getInstanceMethod(class, swizzSelector);
        
        BOOL success = class_addMethod(class, originSelector, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
        if (success) {
            class_replaceMethod(class, swizzSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        }else{
            method_exchangeImplementations(originMethod, swizzMethod);
        }
    });
    
    
}

-(void)ss_viewWillAppear:(BOOL)animated{
    [self ss_viewWillAppear:animated];
    if (self.block) {
        self.block(self,animated);
    }
}
-(ss_ViewControllerWillAppearInjectBlock)block{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)setBlock:(ss_ViewControllerWillAppearInjectBlock)block{
    objc_setAssociatedObject(self, @selector(block), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end

@implementation UIViewController (FullscreenPopGesture)
-(BOOL)ss_interativePopDisEnable{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
-(void)setSs_interativePopDisEnable:(BOOL)ss_interativePopDisEnable{
    objc_setAssociatedObject(self, @selector(ss_interativePopDisEnable), @(ss_interativePopDisEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)ss_navgiationBarIsHidden{
    
    return  [objc_getAssociatedObject(self, _cmd) boolValue];
}
-(void)setSs_navgiationBarIsHidden:(BOOL)ss_navgiationBarIsHidden{
    objc_setAssociatedObject(self, @selector(ss_navgiationBarIsHidden), @(ss_navgiationBarIsHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(CGFloat)ss_MaxAllowedInitialDistanceToLeftEdge{

#if CGFLOAT_IS_DOUBLE
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
#else
    return [objc_getAssociatedObject(self, _cmd) floatValue];
#endif


}
-(void)setSs_MaxAllowedInitialDistanceToLeftEdge:(CGFloat)ss_MaxAllowedInitialDistanceToLeftEdge{
    
    objc_setAssociatedObject(self, @selector(ss_MaxAllowedInitialDistanceToLeftEdge), @(MAX(0, ss_MaxAllowedInitialDistanceToLeftEdge)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation UINavigationController (FullscreenPopGesture)
+(void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originSelector = @selector(pushViewController:animated:);
        
        SEL swizzSeletor = @selector(ss_pushViewController:animated:);
        
        Method originMethod = class_getInstanceMethod(class , originSelector);
        
        Method swifzzMehod = class_getInstanceMethod(class, swizzSeletor);
        BOOL success = class_addMethod(class, originSelector, method_getImplementation(swifzzMehod), method_getTypeEncoding(swifzzMehod));
        if (success) {
            class_replaceMethod(class, swizzSeletor, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        }else{
            method_exchangeImplementations(originMethod, swifzzMehod);
        }
        
    });
    
}
-(void)ss_pushViewController:(UIViewController *)viewcontroller animated:(BOOL)animated{
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.ss_PanGestureReconizer]) {
        //  不包含的  添加自己的
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.ss_PanGestureReconizer];
        
        NSMutableArray * array = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id target = [array.firstObject valueForKey:@"target"];
        SEL action =  NSSelectorFromString(@"handleNavigationTransition:");
        self.ss_PanGestureReconizer.delegate = self.newPopGestureDelegate;
        [self.ss_PanGestureReconizer addTarget:target action:action];
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self setBaseNavigationBarAppearIfNeed:viewcontroller];
    
    if (![self.viewControllers containsObject:viewcontroller]) {
        [self ss_pushViewController:viewcontroller animated:animated];
    }
}
-(void)setBaseNavigationBarAppearIfNeed:(UIViewController *)vc{
    if (!self.ss_viewcontrillersbaseNavgationBarAppearEnable) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    ss_ViewControllerWillAppearInjectBlock block = ^(UIViewController * vc ,BOOL animated){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
        [strongSelf setNavigationBarHidden:vc.ss_navgiationBarIsHidden animated:animated];
        }
        
    };
    
    vc.block = block;
    UIViewController * disappearVC = self.viewControllers.lastObject;
    if (disappearVC && !disappearVC.block) {
        disappearVC.block = block;
    }
}
-(UIPanGestureRecognizer *)ss_PanGestureReconizer{
    UIPanGestureRecognizer * ges = objc_getAssociatedObject(self, _cmd);
    if (!ges) {
        ges = [[UIPanGestureRecognizer alloc]init];
        ges.maximumNumberOfTouches = 1;
        objc_setAssociatedObject(self, _cmd, ges, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ges;
}
-(ss_FullPopGesture *)newPopGestureDelegate{
    ss_FullPopGesture * delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [[ss_FullPopGesture alloc]init];
        delegate.navgationController = self;
        objc_setAssociatedObject(self, _cmd,  delegate , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}
-(BOOL)ss_viewcontrillersbaseNavgationBarAppearEnable{
    NSNumber * num = objc_getAssociatedObject(self, _cmd);
    if (num) {
        return num.boolValue;
    }
    self.ss_viewcontrillersbaseNavgationBarAppearEnable = YES;
    return YES;
}
-(void)setSs_viewcontrillersbaseNavgationBarAppearEnable:(BOOL)ss_viewcontrillersbaseNavgationBarAppearEnable{
    objc_setAssociatedObject(self, @selector(ss_viewcontrillersbaseNavgationBarAppearEnable),@( ss_viewcontrillersbaseNavgationBarAppearEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
