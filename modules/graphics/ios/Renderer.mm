#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
#import <ModelIO/ModelIO.h>
#import <simd/simd.h>
#import "Renderer.h"

matrix_float4x4 rotationMatrixX(float angle) {
    float s = sinf(angle);
    float c = cosf(angle);
    
    matrix_float4x4 matrix = (matrix_float4x4){
        (vector_float4){1, 0,  0, 0},
        (vector_float4){0, c,  s, 0},
        (vector_float4){0, -s, c, 0},
        (vector_float4){0, 0,  0, 1}
    };
    
    return matrix;
}

matrix_float4x4 rotationMatrixY(float angle) {
    float s = sinf(angle);
    float c = cosf(angle);
    
    matrix_float4x4 matrix = (matrix_float4x4){
        (vector_float4){c,  0, -s, 0},
        (vector_float4){0,  1,  0, 0},
        (vector_float4){s,  0,  c, 0},
        (vector_float4){0,  0,  0, 1}
    };
    
    return matrix;
}

typedef struct {
    matrix_float4x4 rotationX;
    matrix_float4x4 rotationY;
} Uniforms;

@interface Renderer () <MTKViewDelegate>

@end

@implementation Renderer {
    MTKMesh *_mesh;

    id<MTLCommandQueue> _commandQueue;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLTexture> _earthMap;
    id<MTLBuffer> _uniformBuffer;
    
    Uniforms _uniforms;
    
    float _rotationXAngle;
    float _rotationYAngle;
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)gesture;
{
    CGPoint translation = [gesture translationInView:gesture.view];
    
    _rotationXAngle += translation.y * 0.01;
    _rotationYAngle += translation.x * 0.01;
    [self updateUniforms];
    
    [gesture setTranslation:CGPointZero inView:gesture.view];
}

- (void)updateUniforms {
    _uniforms.rotationX = rotationMatrixX(_rotationXAngle);
    _uniforms.rotationY = rotationMatrixY(_rotationYAngle);

    memcpy([_uniformBuffer contents], &_uniforms, sizeof(Uniforms));
}

- (instancetype)init:(MTKView *)view {
    self = [super init];
    
    if (self) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
        pan.minimumNumberOfTouches = 1;
        [view addGestureRecognizer:pan];
        
        MTKMeshBufferAllocator *allocator = [[MTKMeshBufferAllocator alloc] initWithDevice:view.device];
        
        MDLMesh *mdlMesh = [[MDLMesh alloc] initSphereWithExtent:(vector_float3){0.75, 0.75, 0.75} segments:(vector_uint2){50, 50} inwardNormals:NO geometryType:MDLGeometryTypeTriangles allocator:allocator];
        
        NSError *mtkMeshError = nil;
        _mesh = [[MTKMesh alloc] initWithMesh:mdlMesh device:view.device error:&mtkMeshError];
        
        // setup command queue
        _commandQueue = [view.device newCommandQueue];
        
        // setup pipeline state
        NSBundle *podBundle = [NSBundle bundleForClass:[self class]];
        NSString *shaderPath = [podBundle pathForResource:@"Shader" ofType:@"metal"];
        
        NSError *shaderSourceError = nil;
        NSString *shaderSource = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&shaderSourceError];
        
        if (!shaderSourceError) {
            const auto library = [view.device newLibraryWithSource:shaderSource options:nil error:&shaderSourceError];
            
            const auto vertextFunction = [library newFunctionWithName:@"vertex_main"];
            const auto fragmentFunction = [library newFunctionWithName:@"fragment_main"];
            
            const auto pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
            pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
            pipelineDescriptor.vertexFunction = vertextFunction;
            pipelineDescriptor.fragmentFunction = fragmentFunction;
            pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(_mesh.vertexDescriptor);
            
            NSError *pipelineStateError = nil;
            _pipelineState = [view.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&pipelineStateError];
            
            if(pipelineStateError) {
                NSLog(@"Error creating pipeline state: %@", pipelineStateError);
            }
        } else {
            NSLog(@"Error loading shader source: %@", shaderSourceError);
        }
        
        // load texture
        NSString *texturePath = [podBundle pathForResource:@"earthmap" ofType:@"jpg"];
        NSError* textureFileError = nil;
        NSData* data = [NSData dataWithContentsOfFile:texturePath options:0 error:&textureFileError];
        
        NSError *textureLoadError = nil;
        
        MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:view.device];
        
        NSDictionary* textureLoaderOptions = @{
            MTKTextureLoaderOptionSRGB : @NO
        };
        
        _earthMap = [textureLoader newTextureWithData:data options:textureLoaderOptions error:&textureLoadError];
        
        _uniformBuffer = [view.device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];
        _rotationXAngle = 0;
        _rotationYAngle = 0;
        [self updateUniforms];
    }
    
    return self;
}

- (void)drawInMTKView:(MTKView *)view {
    const auto commandBuffer = [_commandQueue commandBuffer];

    const auto commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:view.currentRenderPassDescriptor];
    
    [commandEncoder setRenderPipelineState:_pipelineState];
    [commandEncoder setVertexBuffer:_mesh.vertexBuffers[0].buffer offset:0 atIndex:0];
    [commandEncoder setVertexBuffer:_uniformBuffer offset:0 atIndex:1];
    [commandEncoder setFragmentTexture:_earthMap atIndex:0];
    
    const auto submesh = _mesh.submeshes.firstObject;
    
    [commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:submesh.indexCount indexType:submesh.indexType indexBuffer:submesh.indexBuffer.buffer indexBufferOffset:0];
    
    [commandEncoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    // do nothing
}

@end
