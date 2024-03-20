#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_COCOA
#include <GLFW/glfw3native.h>

@interface MetalRenderer : NSObject<MTKViewDelegate>

@end

@implementation MetalRenderer {
	id<MTLDevice> _device;
	id<MTLCommandQueue> _commandQueue;
	id<MTLRenderPipelineState> _pipelineState;
	id<MTLBuffer> _vertexBuffer;
	MTKView *_view;
}

- (instancetype)initWithMetalKitView:(MTKView *)view {
	self = [super init];
	if (self) {
		_view = view;
		_device = [_view device];
		
		_commandQueue = [_device newCommandQueue];
		_view.delegate = self;
		
		[self setupPipeline];
		[self setupVertexBuffer];
	}
	return self;
}

- (void)setupPipeline {
	NSError *error = nil;
	id<MTLLibrary> library = [_device newLibraryWithFile:@"Shader.air" error:&error];
	
	if (!library) {
		NSLog(@"Failed to load Metal library: %@", error);
		return;
	}
	
	id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_shader"];
	id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_shader"];

	MTLVertexDescriptor *vertexDescriptor = [[MTLVertexDescriptor alloc] init];
	vertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
	vertexDescriptor.attributes[0].bufferIndex = 0;
	vertexDescriptor.attributes[0].offset = 0;
	vertexDescriptor.attributes[1].format = MTLVertexFormatFloat3;
	vertexDescriptor.attributes[1].bufferIndex = 0;
	vertexDescriptor.attributes[1].offset = sizeof(float) * 3;
	vertexDescriptor.layouts[0].stride = sizeof(float) * 3 * 2;
	
	MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
	pipelineDescriptor.vertexFunction = vertexFunction;
	pipelineDescriptor.fragmentFunction = fragmentFunction;
	pipelineDescriptor.colorAttachments[0].pixelFormat = _view.colorPixelFormat;
	pipelineDescriptor.vertexDescriptor = vertexDescriptor;
	
	_pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
	if (!_pipelineState) {
		NSLog(@"Failed to create render pipeline state: %@", error);
	}
}

- (void)setupVertexBuffer {
	static const float vertexData[] = {
		0.0f,  1.0f, 0.0f,		1.0f, 1.0f, 0.0f,
	   -1.0f, -1.0f, 0.0f,		1.0f, 0.0f, 1.0f,
		1.0f, -1.0f, 0.0f,		0.0f, 1.0f, 1.0f,
	};
	
	_vertexBuffer = [_device newBufferWithBytes:vertexData length:sizeof(vertexData) options:MTLResourceStorageModeShared];
}

- (void)drawInMTKView:(nonnull MTKView *)view {
	id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
	MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
	
	if (renderPassDescriptor != nil) {
		id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
		[renderEncoder setRenderPipelineState:_pipelineState];
		[renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
		[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
		[renderEncoder endEncoding];
		
		[commandBuffer presentDrawable:view.currentDrawable];
	}
	
	[commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
}

@end

@interface MetalWindowController : NSWindowController

@end

@implementation MetalWindowController {

}

@end

int main(int argc, const char * argv[]) {
	@autoreleasepool {
        if (!glfwInit()) {
            NSLog(@"Failed to initialize GLFW");
            return -1;
        }

        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        if (!device) {
            NSLog(@"Failed to create Metal device");
            return -1;
        }
        
        GLFWwindow* glfwWindow = glfwCreateWindow(800, 600, "Metal GLFW Example", NULL, NULL);
        if (!glfwWindow) {
            NSLog(@"Failed to create GLFW window");
            glfwTerminate();
            return -1;
        }
		
	MTKView *metalView = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, 800, 600) device:device];
        metalView.layer.opaque = YES;
	metalView.device = device;

        MetalRenderer *renderer = [[MetalRenderer alloc] initWithMetalKitView:metalView];

        NSWindow *cocoaWindow = glfwGetCocoaWindow(glfwWindow);
        [cocoaWindow.contentView addSubview:metalView];
        
        while (!glfwWindowShouldClose(glfwWindow)) {
            glfwPollEvents();
            [metalView draw];
        }
        
        glfwDestroyWindow(glfwWindow);
        glfwTerminate();
    }
    return 0;
}
