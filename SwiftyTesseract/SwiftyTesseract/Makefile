PNG_VERSION     := 1.6.36
PNG_NAME        := libpng-$(PNG_VERSION)
JPEG_SRC_NAME   := jpegsrc.v9c
# folder name after the JPEG_SRC_NAME archive has been unpacked
JPEG_DIR_NAME   := jpeg-9c
TIFF_NAME       := tiff-4.0.10

TESSERACT_VERSION ?= 4.1.0
TESSERACT_NAME    := tesseract-$(TESSERACT_VERSION)
LEPTONICA_VERSION ?= 1.78.0
LEPTON_NAME       := leptonica-$(LEPTONICA_VERSION)


SRC_DIR = $(shell pwd)
TESSERACT_SRC = $(SRC_DIR)/$(TESSERACT_NAME)
LEPTON_SRC = $(SRC_DIR)/$(LEPTON_NAME)
PNG_SRC   = $(SRC_DIR)/$(PNG_NAME)
JPEG_SRC = $(SRC_DIR)/$(JPEG_DIR_NAME)
TIFF_SRC = $(SRC_DIR)/$(TIFF_NAME)

libtessfiles = libtesseract.a
libleptfiles = liblept.a
libpngfiles = libpng.a
libjpegfiles = libjpeg.a
libtifffiles = libtiff.a

libpngconfig  = $(PNG_SRC)/configure
libjpegconfig = $(JPEG_SRC)/configure
libtiffconfig = $(TIFF_SRC)/configure
libtessautogen = $(TESSERACT_SRC)/autogen.sh
libtessconfig = $(TESSERACT_SRC)/configure
libleptautogen = $(LEPTON_SRC)/autogen.sh
libleptconfig = $(LEPTON_SRC)/configure

XCODE_DEVELOPER_PATH="`xcode-select -p`"
XCODE_DEVELOPER_PATH_BIN=$(XCODE_DEVELOPER_PATH)/usr/bin
TARGET_CXX="$(XCODE_DEVELOPER_PATH_BIN)/g++"
TARGET_CXX_FOR_BUILD="$(XCODE_DEVELOPER_PATH_BIN)/g++"
TARGET_CC="$(XCODE_DEVELOPER_PATH_BIN)/gcc"

index = $(words $(shell a="$(2)";echo $${a/$(1)*/$(1)} ))
swap  = $(word $(call index,$(1),$(2)),$(3))

# platform specific config
#
# make platform=ios
ifeq ($(platform), ios)
	PLATFORM_PREFIX=ios
	SDK_IPHONEOS_PATH=$(shell xcrun --sdk iphoneos --show-sdk-path)
	SDK_IPHONESIMULATOR_PATH=$(shell xcrun --sdk iphonesimulator --show-sdk-path)
	IOS_DEPLOY_TGT="11.0"

	sdks = $(SDK_IPHONEOS_PATH) $(SDK_IPHONESIMULATOR_PATH)
	platform_version_mins = iphoneos-version-min=$(IOS_DEPLOY_TGT) ios-simulator-version-min=$(IOS_DEPLOY_TGT)
	archs_all = arm64 x86_64
	arch_names_all = arm-apple-darwin64 x86_64-apple-darwin
	arch_names = $(foreach arch, $(ARCHS), $(call swap, $(arch), $(archs_all), $(arch_names_all) ) )
	ARCHS ?= $(archs_all)
# make platform=macos
else ifeq ($(platform), macos)
	PLATFORM_PREFIX=macos
	SDK_MACOS_PATH=$(shell xcrun --sdk macosx --show-sdk-path)
	MACOS_DEPLOY_TGT="10.13"

	sdks = $(SDK_MACOS_PATH)
	platform_version_mins = macosx-version-min=$(MACOS_DEPLOY_TGT)
	archs_all = x86_64
	arch_names_all = x86_64-apple-darwin
	arch_names = $(foreach arch, $(ARCHS), $(call swap, $(arch), $(archs_all), $(arch_names_all) ) )
	ARCHS ?= $(archs_all)
# make platform=all
else ifeq ($(platform), all)
	# we will call make for all platforms, so nothing to do for now
endif

# TOOD: Rename SOURCES and maybe SRC_DIR to be more descriptive
SOURCES = $(SRC_DIR)/$(PLATFORM_PREFIX)

IMAGE_LIB_DIR = $(SOURCES)/dependencies/lib/
IMAGE_INC_DIR = $(SOURCES)/dependencies/include
INCLUDE_DIR   = $(shell pwd)/$(PLATFORM_PREFIX)/include
LEPT_INC_DIR  = $(INCLUDE_DIR)
TESS_INC_DIR  = $(INCLUDE_DIR)
LIB_FAT_DIR   = $(shell pwd)/$(PLATFORM_PREFIX)/lib

libpngfolders  = $(foreach arch, $(arch_names), $(PNG_SRC)/$(arch)/)
libjpegfolders = $(foreach arch, $(arch_names), $(JPEG_SRC)/$(arch)/)
libtifffolders = $(foreach arch, $(arch_names), $(TIFF_SRC)/$(arch)/)
libleptfolders = $(foreach arch, $(arch_names), $(LEPTON_SRC)/$(PLATFORM_PREFIX)/$(arch)/)
libtessfolders = $(foreach arch, $(arch_names), $(TESSERACT_SRC)/$(PLATFORM_PREFIX)/$(arch)/)

libpngfolders_all  = $(foreach arch, $(arch_names_all), $(PNG_SRC)/$(arch)/)
libjpegfolders_all = $(foreach arch, $(arch_names_all), $(JPEG_SRC)/$(arch)/)
libtifffolders_all = $(foreach arch, $(arch_names_all), $(TIFF_SRC)/$(arch)/)
libleptfolders_all = $(foreach arch, $(arch_names_all), $(LEPTON_SRC)/$(PLATFORM_PREFIX)/$(arch)/)
libtessfolders_all = $(foreach arch, $(arch_names_all), $(TESSERACT_SRC)/$(PLATFORM_PREFIX)/$(arch)/)

libpngmakefile  = $(foreach folder, $(libpngfolders), $(addprefix $(folder), Makefile) )
libjpegmakefile = $(foreach folder, $(libjpegfolders), $(addprefix $(folder), Makefile) )
libtiffmakefile = $(foreach folder, $(libtifffolders), $(addprefix $(folder), Makefile) )
libleptmakefile = $(foreach folder, $(libleptfolders), $(addprefix $(folder), Makefile) )
libtessmakefile = $(foreach folder, $(libtessfolders), $(addprefix $(folder), Makefile) )

# NEED TO LOOK AT WHERE THIS IS USED imagesmakefile  = $(addprefix $(SOURCES)/, Makefile)

libleptfat = $(LIB_FAT_DIR)/$(libleptfiles)
libtessfat = $(LIB_FAT_DIR)/$(libtessfiles)
libpngfat  = $(LIB_FAT_DIR)/$(libpngfiles)
libjpegfat = $(LIB_FAT_DIR)/$(libjpegfiles)
libtifffat = $(LIB_FAT_DIR)/$(libtifffiles)

libtess    = $(foreach folder, $(libtessfolders), $(addprefix $(folder)lib/, $(libtessfiles)) )
liblept    = $(foreach folder, $(libleptfolders), $(addprefix $(folder)lib/, $(libleptfiles)) )
libpng     = $(foreach folder, $(libpngfolders), $(addprefix $(folder)lib/, $(libpngfiles)) )
libjpeg    = $(foreach folder, $(libjpegfolders), $(addprefix $(folder)lib/, $(libjpegfiles)) )
libtiff    = $(foreach folder, $(libtifffolders), $(addprefix $(folder)lib/, $(libtifffiles)) )

dependant_libs = $(libpngfat) $(libjpegfat) $(libtifffat) $(libleptfat) $(libtessfat)

common_cflags = -arch $(call swap, $*, $(arch_names_all), $(archs_all)) -pipe -no-cpp-precomp -isysroot $$SDKROOT -m$(call swap, $*, $(arch_names_all), $(platform_version_mins)) -O2

ifneq (,$(filter $(platform),ios macos))
.PHONY : all
all : $(dependant_libs)
else
.PHONY : all
all :
	$(MAKE) platform=ios
	$(MAKE) platform=macos
endif

#######################
# Build libtiff and all of its dependencies
#######################
libtiff : $(libtifffat)

$(libtifffat) : $(libtiff)
	mkdir -p $(@D)
	xcrun lipo $(realpath $(addsuffix lib/$(@F), $(libtifffolders_all)) ) -create -output $@
	mkdir -p $(IMAGE_INC_DIR)
	cp -rvf $(firstword $(libtifffolders))include/*.h $(IMAGE_INC_DIR)

$(libtiff) :  $(libtiffmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(TIFF_SRC)/%/Makefile : $(libtiffconfig)
	export SDKROOT="$(call swap, $*, $(arch_names_all), $(sdks))" ; \
	export CFLAGS="$(common_cflags) -fembed-bitcode" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="$$CFLAGS -Wno-deprecated-register"; \
	export LDFLAGS="-L$$SDKROOT/usr/lib/" ; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../configure CXX="$(TARGET_CXX) --target=$*" CC="$(TARGET_CC) --target=$*" --host=$* --enable-fast-install --enable-shared=no --prefix=`pwd` --without-x --with-jpeg-include-dir=$(abspath $(@D)/../../$(JPEG_DIR_NAME)/$*/include) --with-jpeg-lib-dir=$(abspath $(@D)/../../$(JPEG_DIR_NAME)/$*/lib)

libpng : $(libpngfat)

$(libpngfat) : $(libpng)
	mkdir -p $(@D)
	xcrun lipo $(realpath $(addsuffix lib/$(@F), $(libpngfolders_all)) ) -create -output $@
	mkdir -p $(IMAGE_INC_DIR)
	cp -rvf $(firstword $(libpngfolders))include/*.h $(IMAGE_INC_DIR)

$(libpng) : $(libpngmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(PNG_SRC)/%/Makefile : $(libpngconfig)
	export SDKROOT="$(call swap, $*, $(arch_names_all), $(sdks))" ; \
	export CFLAGS="$(common_cflags) -fembed-bitcode" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="$$CFLAGS -Wno-deprecated-register"; \
	export LDFLAGS="-L$$SDKROOT/usr/lib/" ; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../configure CXX="$(TARGET_CXX) --target=$*" CC="$(TARGET_CC) --target=$*" --host=$* --enable-shared=no --prefix=`pwd`

libjpeg : $(libjpegfat)

$(libjpegfat) : $(libjpeg)
	mkdir -p $(@D)
	xcrun lipo $(realpath $(addsuffix lib/$(@F), $(libjpegfolders_all)) ) -create -output $@
	mkdir -p $(IMAGE_INC_DIR)
	cp -rvf $(firstword $(libjpegfolders))include/*.h $(IMAGE_INC_DIR)

$(libjpeg) : $(libjpegmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(JPEG_SRC)/%/Makefile : $(libjpegconfig)
	export SDKROOT="$(call swap, $*, $(arch_names_all), $(sdks))" ; \
	export CFLAGS="$(common_cflags) -fembed-bitcode" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="$$CFLAGS -Wno-deprecated-register"; \
	export LDFLAGS="-L$$SDKROOT/usr/lib/" ; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../configure CXX="$(TARGET_CXX) --target=$*" CC="$(TARGET_CC) --target=$*" --host=$* --enable-shared=no --prefix=`pwd`

#######################
# TESSERACT-OCR
#######################
$(libtessfat) : $(libtess)
	mkdir -p $(LIB_FAT_DIR)
	xcrun lipo $(realpath $(addsuffix lib/$(@F), $(libtessfolders_all)) ) -create -output $@
	mkdir -p $(TESS_INC_DIR)
	cp -rvf $(firstword $(libtessfolders))include/tesseract $(TESS_INC_DIR)

$(libtess) : $(libtessmakefile)
	cd $(abspath $(@D)/..) && $(MAKE) -sj8 && $(MAKE) install

$(TESSERACT_SRC)/$(PLATFORM_PREFIX)/%/Makefile : $(libtessconfig) $(libleptfat)
	export LIBS="-lz -lpng -ljpeg -ltiff" ; \
	export SDKROOT="$(call swap, $*, $(arch_names_all), $(sdks))" ; \
	export CFLAGS="-I$(TESSERACT_SRC)/$(PLATFORM_PREFIX)/$*/ $(common_cflags) -fembed-bitcode" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="-I$(TESSERACT_SRC)/$(PLATFORM_PREFIX)/$*/ $(common_cflags) -Wno-deprecated-register"; \
	export LDFLAGS="-L$$SDKROOT/usr/lib/ -L$(LIB_FAT_DIR) -L$(LEPTON_SRC)/$(PLATFORM_PREFIX)/$*/src/.libs" ; \
	export LIBLEPT_HEADERSDIR=$(TESSERACT_SRC)/$(PLATFORM_PREFIX)/$*/ ; \
	export PKG_CONFIG_PATH=$(LEPTON_SRC)/$(PLATFORM_PREFIX)/$*/ ; \
	export CXX="$(TARGET_CXX) --target=$*" ; \
	export CXX_FOR_BUILD="$(TARGET_CXX_FOR_BUILD) --target=$*" ; \
	export CC="$(TARGET_CC) --target=$*" ; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	ln -s $(LEPTON_SRC)/src/ leptonica ; \
	../../configure CXX="$(TARGET_CXX) --target=$*" CC="$(TARGET_CC) --target=$*" --host=$* --prefix=`pwd` --enable-shared=no --disable-graphics

$(libtessconfig) : $(libtessautogen)
	cd $(@D) && ./autogen.sh 2> /dev/null

#######################
# LEPTONICA
#######################
$(libleptfat) : $(liblept)
	mkdir -p $(LIB_FAT_DIR)
	xcrun lipo $(realpath $(addsuffix lib/$(@F), $(libleptfolders_all)) ) -create -output $@
	mkdir -p $(LEPT_INC_DIR)
	cp -rvf $(firstword $(libleptfolders))include/leptonica $(LEPT_INC_DIR)

$(liblept) : $(libleptmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(LEPTON_SRC)/$(PLATFORM_PREFIX)/%/Makefile : $(libtifffat) $(libpngfat) $(libjpegfat) $(libleptconfig)
	export LIBS="-lz -lpng -ljpeg -ltiff" ; \
	export SDKROOT="$(call swap, $*, $(arch_names_all), $(sdks))" ; \
	export CFLAGS="-I$(INCLUDE_DIR) $(common_cflags) -fembed-bitcode" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="-I$(INCLUDE_DIR) $(common_cflags) -Wno-deprecated-register"; \
	export LDFLAGS="-L$$SDKROOT/usr/lib/ -L$(LIB_FAT_DIR)" ; \
	export PKG_CONFIG_PATH=$(PNG_SRC)/$*/:$(JPEG_SRC)/$*/:$(TIFF_SRC)/$*/ ; \
	export CXX="$(TARGET_CXX) --target=$*" ; \
	export CXX_FOR_BUILD="$(TARGET_CXX_FOR_BUILD) --target=$*" ; \
	export CC="$(TARGET_CC) --target=$*" ; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../../configure CXX="$(TARGET_CXX) --target=$*" CC="$(TARGET_CC) --target=$*" --host=$* --prefix=`pwd` --enable-shared=no --disable-programs --with-zlib --with-libpng --with-jpeg --with-libtiff --without-giflib --without-libwebp

$(libleptconfig) : $(libleptautogen)
	cd $(@D) && ./autogen.sh 2> /dev/null

#######################
# Download dependencies
#######################
$(libtiffconfig) :
	curl http://download.osgeo.org/libtiff/$(TIFF_NAME).tar.gz | tar -xpf-

$(libjpegconfig) :
	curl http://www.ijg.org/files/$(JPEG_SRC_NAME).tar.gz | tar -xpf-

$(libpngconfig) :
	curl -L https://downloads.sourceforge.net/project/libpng/libpng16/$(PNG_VERSION)/$(PNG_NAME).tar.gz | tar -xpf-

$(libtessautogen) :
	curl -LO https://github.com/tesseract-ocr/tesseract/archive/$(TESSERACT_VERSION).zip && unzip -a $(TESSERACT_VERSION).zip

$(libleptautogen) :
	curl http://leptonica.org/source/$(LEPTON_NAME).tar.gz | tar -xpf- ; \

#######################
# Clean
#######################
.PHONY : clean
clean : cleanpng cleantiff cleanjpeg cleanlept cleantess

.PHONY : distclean
distclean : distcleanimages distcleanlept distcleantess

.PHONY : mostlyclean
mostlyclean : mostlycleanpng mostlycleantiff mostlycleanjpeg mostlycleanlept mostlycleantess

.PHONY : cleanpng
cleanpng :
	for folder in $(realpath $(libpngfolders_all) ); do \
		cd $$folder; \
		$(MAKE) clean; \
	done

.PHONY : cleanjpeg
cleanjpeg :
	for folder in $(realpath $(libjpegfolders_all) ); do \
		cd $$folder; \
		$(MAKE) clean; \
	done

.PHONY : cleantiff
cleantiff :
	for folder in $(realpath $(libtifffolders_all) ); do \
		cd $$folder; \
		$(MAKE) clean; \
	done

.PHONY : cleanlept
cleanlept :
	for folder in $(realpath $(libleptfolders_all) ); do \
		cd $$folder; \
		$(MAKE) clean; \
	done ;

.PHONY : cleantess
cleantess :
	for folder in $(realpath $(libtessfolders_all) ); do \
		cd $$folder; \
		$(MAKE) clean; \
	done ;

.PHONY : mostlycleanlept
mostlycleanlept :
	for folder in $(realpath $(libleptfolders) ); do \
		cd $$folder; \
		$(MAKE) mostlyclean; \
	done ;

.PHONY : mostlycleantess
mostlycleantess :
	for folder in $(realpath $(libtessfolders_all) ); do \
		cd $$folder; \
		$(MAKE) mostlyclean; \
	done ;

.PHONY : mostlycleanpng
mostlycleanpng :
	for folder in $(realpath $(libpngfolders) ); do \
		cd $$folder; \
		$(MAKE) mostlyclean; \
	done

.PHONY : mostlycleantiff
mostlycleantiff :
	for folder in $(realpath $(libtifffolders_all) ); do \
		cd $$folder; \
		$(MAKE) mostlyclean; \
	done

.PHONY : mostlycleanjpeg
mostlycleanjpeg :
	for folder in $(realpath $(libjpegfolders_all) ); do \
		cd $$folder; \
		$(MAKE) mostlyclean; \
	done

.PHONY : distcleanimages
distcleanimages :
	-rm -rf $(IMAGE_LIB_DIR)
	-rm -rf $(IMAGE_INC_DIR)
	-rm -rf $(PNG_SRC)
	-rm -rf $(JPEG_SRC)
	-rm -rf $(TIFF_SRC)

PHONY : distcleanlept
distcleanlept :
	-rm -rf $(LEPT_INC_DIR)/leptonica
	-rm -rf $(libleptfat)
	-rm -rf $(LEPTON_SRC)

.PHONY : distcleantess
distcleantess :
	-rm -rf $(TESS_INC_DIR)/tesseract
	-rm -rf $(libtessfat)
	-rm -rf $(TESSERACT_SRC)

.PHONY : FORCE
FORCE :
