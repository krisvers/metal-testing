build:
	clang++ -std=c++17 $(shell find . -type f -name "*.mm") -Iinclude -Llib -lglfw3 -framework IOKit -framework Cocoa -framework QuartzCore -framework Metal -framework MetalKit -o test
	$(XCODE_TOOLCHAIN)/bin/metal Shader.metal -o Shader.air
