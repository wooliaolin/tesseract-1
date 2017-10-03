#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$BASE_DIR"/build
SRC_DIR="$BASE_DIR"/src
TESSERACT_DIR="$BASE_DIR"/tesseract

mkdir $SRC_DIR
mkdir $BUILD_DIR

echo
echo '################################################################'
echo '# Building ZLib                                                #'
echo '################################################################'

# Clean up old files
cd $SRC_DIR/zlib
git clean -fx

./configure --solo --static
make install prefix=$BUILD_DIR

if [ ! -f $BUILD_DIR/include/zlib.h ]; then 
    echo "ZLib build failed. Exiting."
    exit 1
fi


echo
echo '################################################################'
echo '# Building LibJPEG                                             #'
echo '################################################################'

cd $SRC_DIR/libjpeg
git clean -fx

./configure --disable-shared --prefix=$BUILD_DIR
make install

if [ ! -f $BUILD_DIR/include/jpeglib.h ]; then 
    echo "LibJPEG build failed. Exiting."
    exit 1
fi


echo
echo '################################################################'
echo '# Building LibPNG                                              #'
echo '################################################################'

cd $SRC_DIR/libpng
git clean -fx

./autogen.sh
./configure --disable-shared --disable-static --prefix=$BUILD_DIR \
CXXFLAGS="-I$BUILD_DIR/include" \
CPPFLAGS="-I$BUILD_DIR/include"
make check
make install

if [ ! -f "$BUILD_DIR/include/libpng16/png.h" ]; then 
    echo "LibPNG build failed. Exiting."
    exit 1
fi


echo
echo '################################################################'
echo '# Building LibTiff                                             #'
echo '################################################################'

cd $SRC_DIR/libtiff
git clean -fx

./autogen.sh
./configure --disable-shared --disable-static --prefix=$BUILD_DIR \
CXXFLAGS="-I$BUILD_DIR/include" \
CPPFLAGS="-I$BUILD_DIR/include"
make check
make install

if [ ! -f "$BUILD_DIR/lib/libtiff.a" ]; then 
    echo "LibPNG build failed. Exiting."
    exit 1
fi


echo
echo '################################################################'
echo '# Building Leptionica                                          #'
echo '################################################################'

cd $SRC_DIR/leptonica
git clean -fx

./autobuild

./configure --disable-shared --disable-static --prefix=$BUILD_DIR --without-giflib --without-libwebp --without-libopenjpeg \
LDFLAGS="-L$BUILD_DIR/lib" \
CXXFLAGS="-I$BUILD_DIR/include -I$BUILD_DIR/include/libpng16" \
CPPFLAGS="-I$BUILD_DIR/include -I$BUILD_DIR/include/libpng16"

make install

if [ ! -f $SRC_DIR/leptonica/src/.libs/liblept.a ]; then 
    echo 'Leptonica build failed. Exiting.'
    exit 1
fi


echo
echo '################################################################'
echo '# Building Tesseract                                           #'
echo '################################################################'

cd $SRC_DIR/tesseract
git clean -fx

rm -rf $TESSERACT_DIR
mkdir $TESSERACT_DIR
 
./autogen.sh

./configure --disable-shared --disable-static --prefix=$TESSERACT_DIR --with-extra-libraries=$BUILD_DIR/lib \
CXXFLAGS="-I$BUILD_DIR/include -I$BUILD_DIR/include/libpng16 -I$BUILD_DIR/include/leptonica" \
CPPFLAGS="-I$BUILD_DIR/include -I$BUILD_DIR/include/libpng16 -I$BUILD_DIR/include/leptonica" \
LDFLAGS="-L$BUILD_DIR/lib" \
PKG_CONFIG_LIBDIR=$BUILD_DIR/lib/pkgconfig

make install

if [ ! -x $TESSERACT_DIR/bin/tesseract ]; then
    echo "Tesseract build failed. Exiting."
    exit 1
fi

echo
echo '################################################################'
echo '# Tesseract successfully built                                 #'
echo '################################################################'
