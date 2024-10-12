#ifdef RCT_NEW_ARCH_ENABLED
#import "GraphicsView.h"

#import <react/renderer/components/RNGraphicsViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNGraphicsViewSpec/EventEmitters.h>
#import <react/renderer/components/RNGraphicsViewSpec/Props.h>
#import <react/renderer/components/RNGraphicsViewSpec/RCTComponentViewHelpers.h>

#import <MetalKit/MetalKit.h>

#import "RCTFabricComponentsPlugins.h"
#import "Utils.h"
#import "Renderer.h"

using namespace facebook::react;

@interface GraphicsView () <RCTGraphicsViewViewProtocol>

@end

@implementation GraphicsView {
    MTKView * _view;
    id<MTKViewDelegate> _renderer;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<GraphicsViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const GraphicsViewProps>();
        _props = defaultProps;
        
        _view = [[MTKView alloc] initWithFrame:frame device:MTLCreateSystemDefaultDevice()];
        
        _renderer = [[Renderer alloc] init:_view];
        
        _view.delegate = _renderer;
        _view.clearColor = MTLClearColorMake(1.0, 1.0, 0.8, 1.0);
        
        self.contentView = _view;
    }
    
    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<GraphicsViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<GraphicsViewProps const>(props);

    if (oldViewProps.color != newViewProps.color) {
        NSString * colorToConvert = [[NSString alloc] initWithUTF8String: newViewProps.color.c_str()];
        [_view setBackgroundColor: [Utils hexStringToColor:colorToConvert]];
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> GraphicsViewCls(void)
{
    return GraphicsView.class;
}

@end
#endif
