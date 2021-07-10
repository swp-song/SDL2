#!/bin/sh

CURRENT_FOLDER=`pwd`
SDL2_VERSION="2.0.14"
FRAMEWORK_NAME="SDL2"
FRAMEWORK_EXT=".framework"
FRAMEWORK="$FRAMEWORK_NAME$FRAMEWORK_EXT"
OUTPUT_FOLDER="/$CURRENT_FOLDER/$FRAMEWORK"
OUTPUT_INFO_PLIST_FILE="$OUTPUT_FOLDER/Info.plist"
OUTPUT_HEADER_FOLDER="$OUTPUT_FOLDER/Headers"
OUTPUT_UMBRELLA_HEADER="$OUTPUT_HEADER_FOLDER/SDL2.h"
OUTPUT_MODULES_FOLDER="$OUTPUT_FOLDER/Modules"
OUTPUT_MODULES_FILE="$OUTPUT_MODULES_FOLDER/module.modulemap"

SCRATCH=$CURRENT_FOLDER/$FRAMEWORK_NAME-$SDL2_VERSION/'build-scripts'/'platform'/
ARCHS="arm64-ios armv7-ios armv7s-ios i386-sim x86_64-sim"

SOURCE="SDL2-$SDL2_VERSION"

function Download () {
    if [ ! -r $SOURCE ]
	then
        echo $SOURCE
		echo 'SDL2 source not found. Trying to download...'
		curl https://www.libsdl.org/release/$SOURCE.tar.gz | tar xj \
			|| exit 1
	fi
}

function Build() {
    cd $CURRENT_FOLDER/$FRAMEWORK_NAME-$SDL2_VERSION/"build-scripts"/
    ./iosbuild.sh
    cd $CURRENT_FOLDER
    echo "Build Complete"
}

function CreateFramework() {
  rm -rf $OUTPUT_FOLDER
  mkdir -p $OUTPUT_HEADER_FOLDER $OUTPUT_MODULES_FOLDER
}

function MergeStaticLibrary() {
    local files=""
    for ARCH in $ARCHS; do
        folder="$SCRATCH/$ARCH"
        echo $folder
        name="$FRAMEWORK_NAME$ARCH.a"
        cp $(find $folder -name "libSDL2.a") $name
        files="$files $name"
    done
    echo $files
    
    lipo -create $files -o $FRAMEWORK_NAME

    for file in $files; do
        rm -rf $file
    done
    mv $FRAMEWORK_NAME $OUTPUT_FOLDER

    lipo -info $OUTPUT_FOLDER/$FRAMEWORK_NAME
}

function CopyHeader() {

    local include_folder="$(pwd)/$FRAMEWORK_NAME-$SDL2_VERSION/include"
    for folder in "$include_folder"/*; do
        local folder_name=`basename $folder`

        local verstion_file_name="$folder_name$VERSION_NEW_NAME"
        
        local input=$include_folder/$folder_name
        cp $input $OUTPUT_HEADER_FOLDER
    done
}

# COPY MISSING inttypes.h
function CopyInttype() {
  local file="$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/clang/include/inttypes.h"
	cp $file $OUTPUT_HEADER_FOLDER
	find $OUTPUT_HEADER_FOLDER -type f -exec sed -i '' "s/<inttypes.h>/\"inttypes.h\"/g" {} \;
}

function CreateModulemapAndUmbrellaHeader() {

cat > $OUTPUT_UMBRELLA_HEADER <<EOF

#import <CoreHaptics/CoreHaptics.h>
#import <GameController/GameController.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>
#import <SDL2/SDL.h>
FOUNDATION_EXPORT double SDL2VersionNumber;
FOUNDATION_EXPORT const unsigned char SDL2VersionString[];

EOF

cat > $OUTPUT_MODULES_FILE <<EOF
framework module $FRAMEWORK_NAME { 
    umbrella header "SDL2.h"

    export *
    module * { export * }
}
EOF
}

function CreateInfoPlist() {
    
  LOCALIZATION_DEVELOPMENT_REGION='$(DEVELOPMENT_LANGUAGE)'
  EXECUTABLE_FILE="SDL2"
  BUNDLE_ID="com.drem-song.sdl2"
  BUNDLE_NAME="SDL2"
  BUNDLE_PACKAGE_TYPE='$(PRODUCT_BUNDLE_PACKAGE_TYPE)'
  BUNDLE_SHORT_VERSION_STRING=$SDL2_VERSION

  cat > $OUTPUT_INFO_PLIST_FILE <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$LOCALIZATION_DEVELOPMENT_REGION</string>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_FILE</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$BUNDLE_NAME</string>
    <key>CFBundlePackageType</key>
    <string>$BUNDLE_PACKAGE_TYPE</string>
    <key>CFBundleShortVersionString</key>
    <string>$BUNDLE_SHORT_VERSION_STRING</string>
    <key>CFBundleVersion</key>
    <string>$BUNDLE_SHORT_VERSION_STRING</string>
</dict>
</plist>
EOF

}

Download
Build
CreateFramework
MergeStaticLibrary
CopyHeader
CreateModulemapAndUmbrellaHeader
CopyInttype
CreateInfoPlist

echo "END"
