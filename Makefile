MCC = clang

MLIBS = -Llib -lglfw3 -lobjc
MFRAMEWORKS = -framework IOKit -framework Cocoa -framework QuartzCore -framework Metal -framework MetalKit
MFLAGS = -fobjc-arc -std=c11 -Ilib/include -Iinclude

MSRC = $(shell find src -type f -name "*.m")
MOBJ = $(subst .m,.o,$(MSRC))
MBINARY = metal-test

MBUILDDIR = build
MOBJDIR = obj

SHADERDIR = shaders
SHADERSRC = $(shell find $(SHADERDIR) -type f -name "*.metal")

.PHONY: obj build link shaders clean

build: obj link shaders

obj: $(MOBJ)

link:
	$(MCC) $(MLIBS) $(MFRAMEWORKS) $(shell find $(MOBJDIR) -type f -name "*.o") -o $(MBUILDDIR)/$(MBINARY)

shaders:
	$(XCODE_TOOLCHAIN)/bin/metal $(SHADERSRC) -o Shader.air

clean:
	rm -f $(MBUILDDIR)/$(MBINARY)
	rm -f $(shell find $(MOBJDIR) -type f -name "*.o")

%.o: %.m
	$(MCC) $(MFLAGS) -c $< -o obj/$(subst /,_,$@)
