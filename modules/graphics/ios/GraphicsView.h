// This guard prevent this file to be compiled in the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#ifndef GraphicsViewNativeComponent_h
#define GraphicsViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface GraphicsView : RCTViewComponentView
@end

NS_ASSUME_NONNULL_END

#endif /* GraphicsViewNativeComponent_h */
#endif /* RCT_NEW_ARCH_ENABLED */
