# Makefile for iPhone Application for iPhone gcc compiler (SDK Headers)

PROJECTNAME=Explorer
APPFOLDER=$(PROJECTNAME).app
INSTALLFOLDER=$(PROJECTNAME).app
MINIMUMVERSION:=3.0

CC = arm-apple-darwin9-gcc
CPP:=arm-apple-darwin9-g++
LD=$(CC)
SDK = /var/toolchain/sys30

LDFLAGS = -arch arm -lobjc
LDFLAGS += -framework CoreFoundation 
LDFLAGS += -framework Foundation 
LDFLAGS += -framework UIKit 
LDFLAGS += -framework CoreGraphics
//LDFLAGS += -framework AddressBookUI
//LDFLAGS += -framework AddressBook
//LDFLAGS += -framework QuartzCore
//LDFLAGS += -framework GraphicsServices
//LDFLAGS += -framework CoreSurface
//LDFLAGS += -framework CoreAudio
//LDFLAGS += -framework Celestial
//LDFLAGS += -framework AudioToolbox
//LDFLAGS += -framework WebCore
//LDFLAGS += -framework WebKit
//LDFLAGS += -framework SystemConfiguration
//LDFLAGS += -framework CFNetwork
//LDFLAGS += -framework MediaPlayer
//LDFLAGS += -framework OpenGLES
//LDFLAGS += -framework OpenAL
LDFLAGS += -L"$(SDK)/usr/lib"
LDFLAGS += -F"$(SDK)/System/Library/Frameworks"
LDFLAGS += -F"$(SDK)/System/Library/PrivateFrameworks"
LDFLAGS += -bind_at_load
LDFLAGS += -multiply_defined suppress
LDFLAGS += -march=armv6
LDFLAGS += -mcpu=arm1176jzf-s 
LDFLAGS += -mmacosx-version-min=10.5
//LDFLAGS += -dynamiclib

CFLAGS += -I"$(SDK)/usr/include" 
CFLAGS += -std=gnu99 -O0
CFLAGS += -Diphoneos_version_min=$(MINIMUMVERSION)
CFLAGS += -Wno-attributes -Wno-trigraphs -Wreturn-type -Wunused-variable

CPPFLAGS=$CFLAGS

BUILDDIR=./build/$(MINIMUMVERSION)
SRCDIR=./Classes
RESDIR=./Resources
OBJS=$(patsubst %.m,%.o,$(wildcard $(SRCDIR)/*.m))
OBJS+=$(patsubst %.c,%.o,$(wildcard $(SRCDIR)/*.c))
OBJS+=$(patsubst %.mm,%.o,$(wildcard $(SRCDIR)/*.mm))
OBJS+=$(patsubst %.cpp,%.o,$(wildcard $(SRCDIR)/*.cpp))
OBJS+=$(patsubst %.m,%.o,$(wildcard ./*.m))
PCH=$(wildcard *.pch)
RESOURCES=$(wildcard $(RESDIR)/*)
NIBS=$(patsubst %.xib,%.nib,$(wildcard Xib/*.xib))

CFLAGS += $(addprefix -I,$(SRCDIR))

CPPFLAGS=$CFLAGS

all:	$(PROJECTNAME)

$(PROJECTNAME):	$(OBJS) Makefile
	$(LD) $(LDFLAGS) $(filter %.o,$^) -o $@ 

%.o:	%.m %.h $(PCH) $(filter-out $(patsubst %.o,%.h,$(OBJS)), $(wildcard $(SRCDIR)/*.h))
	$(CC) --include $(PCH) -c $(CFLAGS) $< -o $@

%.o:	%.m
	$(CC) --include $(PCH) -c $(CFLAGS) $< -o $@

%.o:	%.c %.h $(PCH)
	$(CC) --include $(PCH) -c $(CFLAGS) $< -o $@

%.o:	%.mm %.h $(PCH) $(filter-out $(patsubst %.o,%.h,$(OBJS)), $(wildcard $(SRCDIR)/*.h))
	$(CPP) --include $(PCH) -c $(CPPFLAGS) $< -o $@

%.o:	%.cpp %.h $(PCH)
	$(CPP) --include $(PCH) -c $(CPPFLAGS) $< -o $@

dist:	$(PROJECTNAME) Makefile Info.plist $(RESOURCES)
	@rm -rf $(BUILDDIR)
	@mkdir -p $(BUILDDIR)/$(APPFOLDER)
ifneq ($(RESOURCES),)
	@-cp -r $(RESOURCES) $(BUILDDIR)/$(APPFOLDER)
	@-$(foreach DIR, .svn .DS_Store .git* , find $(BUILDDIR)/$(APPFOLDER) -name '$(DIR)' -prune -exec rm -rfv {} \;;)
endif
	@cp Info.plist $(BUILDDIR)/$(APPFOLDER)/Info.plist
	@./plutil -key CFBundleExecutable -value $(PROJECTNAME) $(BUILDDIR)/$(APPFOLDER)/Info.plist 
	@./plutil -key CFBundleName -value $(PROJECTNAME) $(BUILDDIR)/$(APPFOLDER)/Info.plist 
	@echo "APPL????" > $(BUILDDIR)/$(APPFOLDER)/PkgInfo
	ldid -S $(PROJECTNAME)
	@mv $(PROJECTNAME) $(BUILDDIR)/$(APPFOLDER)/

install: dist
	@rm -fr /Applications/$(INSTALLFOLDER)
	cp -r $(BUILDDIR)/$(APPFOLDER) /Applications/$(INSTALLFOLDER)
	@./respring
	@echo "Application $(INSTALLFOLDER) installed, please respring device"

uninstall:
	@rm -fr /Applications/$(INSTALLFOLDER)
	@./respring
	@echo "Application $(INSTALLFOLDER) uninstalled, please respring device"

distclean:
	@rm -rf $(BUILDDIR)

clean:
	@rm -f $(OBJS)
	@rm -rf $(BUILDDIR)
	@rm -f $(PROJECTNAME)

.PHONY: all dist install uninstall distclean clean

