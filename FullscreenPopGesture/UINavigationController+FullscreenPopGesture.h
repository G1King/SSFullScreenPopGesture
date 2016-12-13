//
//  UINavigationController+FullscreenPopGesture.h
//  FullscreenPopGesture
//
//  Created by Sobf Sunshinking on 16/12/12.
//  Copyright © 2016年 SOBF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (FullscreenPopGesture)
@property (nonatomic,strong,readonly) UIPanGestureRecognizer * ss_PanGestureReconizer;
@property (nonatomic,assign) BOOL ss_viewcontrillersbaseNavgationBarAppearEnable;
@end

@interface UIViewController (FullscreenPopGesture)

@property (nonatomic,assign) BOOL ss_interativePopDisEnable;
@property (nonatomic,assign) BOOL ss_navgiationBarIsHidden;
@property (nonatomic,assign) CGFloat ss_MaxAllowedInitialDistanceToLeftEdge;
@end
