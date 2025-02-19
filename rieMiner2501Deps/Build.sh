#!/bin/sh

set -e

curl="curl-8.11.1"
gmp="gmp-6.3.0"

incs="incs"
libs="libs"

if test ${1:-native} = "Deb64" ; then
	target="x86_64-pc-linux-gnu"
	incs="incsDeb64"
	libs="libsDeb64"
	export CC=x86_64-linux-gnu-gcc
	export CXX=x86_64-linux-gnu-g++
elif test ${1:-native} = "Deb32" ; then
	target="i686-pc-linux-gnu"
	incs="incsDeb32"
	libs="libsDeb32"
	export CC=i686-linux-gnu-gcc
	export CXX=i686-linux-gnu-g++
elif test ${1:-native} = "Arm64" ; then
	target="aarch64-pc-linux-gnu"
	incs="incsArm64"
	libs="libsArm64"
	export CC=aarch64-linux-gnu-gcc
	export CXX=aarch64-linux-gnu-g++
elif test ${1:-native} = "Arm32" ; then
	target="arm-pc-linux-gnu"
	incs="incsArm32"
	libs="libsArm32"
	export CC=arm-linux-gnueabihf-gcc
	export CXX=arm-linux-gnueabihf-g++
elif test ${1:-native} = "Win64" ; then
	target="x86_64-w64-mingw32"
	incs="incsWin64"
	libs="libsWin64"
	export CC=x86_64-w64-mingw32-gcc-posix
	export CXX=x86_64-w64-mingw32-g++-posix
	export WINDRES=x86_64-w64-mingw32-windres
elif test ${1:-native} = "Win32" ; then
	target="i686-w64-mingw32"
	incs="incsWin32"
	libs="libsWin32"
	export CC=i686-w64-mingw32-gcc-posix
	export CXX=i686-w64-mingw32-g++-posix
	export WINDRES=i686-w64-mingw32-windres
elif test ${1:-native} = "And64" ; then
	target="aarch64-linux-android"
	incs="incsAnd64"
	libs="libsAnd64"
	export ANDROIDAPI=26
	export NDK=/home/user/dev/android-ndk-r25
	export HOST_TAG=linux-x86_64
	export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
	export CC=$TOOLCHAIN/bin/aarch64-linux-android$ANDROIDAPI-clang
	export CXX=$TOOLCHAIN/bin/aarch64-linux-android$ANDROIDAPI-clang++
elif test ${1:-native} = "And32" ; then
	target="armv7-linux-androideabi"
	incs="incsAnd32"
	libs="libsAnd32"
	export ANDROIDAPI=19
	export NDK=/home/user/dev/android-ndk-r25
	export HOST_TAG=linux-x86_64
	export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
	export CC=$TOOLCHAIN/bin/armv7a-linux-androideabi$ANDROIDAPI-clang
	export CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi$ANDROIDAPI-clang++
fi

mkdir incs
mkdir libs

tar -xf ${curl}.tar.gz
cd ${curl}
./configure --host ${target} --disable-dict --disable-file --disable-ftp --disable-gopher --disable-imap --disable-ldap --disable-ldaps --disable-pop3 --disable-rtsp --disable-smtp --disable-telnet --disable-tftp --without-ssl --without-libssh2 --without-zlib --without-brotli --without-zstd --without-libidn2 --without-librtmp --without-libpsl --disable-headers-api --without-nghttp2 --disable-shared --disable-libcurl-option --disable-alt-svc
make -j $(nproc)

mv include/curl ../incs
mv lib/.libs/libcurl.a ../libs
cd ..

tar -xf ${gmp}.tar.xz
cd ${gmp}
cp configfsf.guess config.guess
cp configfsf.sub   config.sub
if test ${1:-native} = "And32" ; then
	./configure --host ${target} --disable-shared --enable-cxx --enable-fat ABI=32 CFLAGS='-fPIC -m32' CPPFLAGS=-DPIC
else
	./configure --host ${target} --disable-shared --enable-cxx --enable-fat
fi
make -j $(nproc)
mv gmp.h gmpxx.h ../incs
mv .libs/libgmp.a .libs/libgmpxx.a ../libs
cd ..

cp -r nlohmann incs

mv incs ../${incs}
mv libs ../${libs}
rm -r ${curl}
rm -r ${gmp}
