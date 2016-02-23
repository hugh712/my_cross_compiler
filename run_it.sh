#!/bin/bash


#####################
#install all packages
sudo apt-get update
sudo apt-get install g++ make gawk -y
sudo apt-get install vim wget xz-utils -y

##############
#create folder
mkdir pi_cross

#############
#remove only directories

cd pi_cross
rm -R `ls -1 -d */`
rm -rf /opt/cross
cd ..

################################
#download packages via wget-list
wget --input-file=wget-list --continue --directory-prefix=./pi_cross



##################
#get package names
BINUTILS_PATH=$(ls pi_cross | grep binutils.* | sed 's/.tar.*//I')
GCC_PATH=$(ls pi_cross | grep gcc.* | sed 's/.tar.*//I')
K_HEADER_PATH=$(ls pi_cross | grep linux.* | sed 's/.tar.*//I')
GLIBC_PATH=$(ls pi_cross | grep glibc.* | sed 's/.tar.*//I')
MPFR_PATH=$(ls pi_cross | grep mpfr.* | sed 's/.tar.*//I')

#be careful of  GMP package, there is an 'a' after the package name
GMP_PATH=$(ls pi_cross | grep gmp.* | sed 's/.tar.*//I')
MPC_PATH=$(ls pi_cross | grep mpc.* | sed 's/.tar.*//I')
ISL_PATH=$(ls pi_cross | grep isl.* | sed 's/.tar.*//I')
CLOOG_PATH=$(ls pi_cross | grep cloog.* | sed 's/.tar.*//I')


echo "get package names..."
echo $BINUTILS_PATH
echo $GCC_PATH
echo $K_HEADER_PATH
echo $GLIBC_PATH
echo $MPFR_PATH
echo $GMP_PATH
echo $MPC_PATH
echo $ISL_PATH
echo $CLOOG_PATH



#########
#unpacked
cd pi_cross
echo "packages untar..."
for f in *.tar*; do tar xf $f; done



#################
#check file exist
error_unm=0

if [ ! -d "$BINUTILS_PATH" ];then
	echo "folder not found! $BINUTILS_PATH"; exit 1
elif [ !  -d "$GCC_PATH" ];then
	echo "folder not found! $GCC_PATH"; exit 1
elif [ ! -d  "$K_HEADER_PATH" ];then
          echo "folder not found! $K_HEADER_PATH"; exit 1
elif [ ! -d  "$GLIBC_PATH" ];then
          echo "folder not found! $GLIBC_PATH "; exit 1
elif [ ! -d  "$MPFR_PATH" ];then
          echo "folder not found! $MPFR_PATH "; exit 1
elif [ ! -d "$GMP_PATH" ];then
          echo "folder not found! $GMP_PATH "; exit 1
elif [ ! -d "$MPC_PATH" ];then
          echo "folder not found! $MPC_PATH "; exit 1
elif [ ! -d "$ISL_PATH"  ];then
          echo "folder not found! $ISL_PATH "; exit 1
elif [ ! -d  "$CLOOG_PATH" ];then
          echo "folder not found! $CLOOG_PATH "; exit 1
fi

###############
#set enviroment
export TARGET=arm-linux-gnueabihf

#####################
#build symbolic link
cd $GCC_PATH
ln -s ../$MPFR_PATH mpfr
ln -s ../$GMP_PATH gmp
ln -s ../$MPC_PATH mpc
ln -s ../$ISL_PATH isl
ln -s ../$CLOOG_PATH cloog
cd ..

#####################
#create corss compiler path
mkdir -p /opt/cross
export PATH=/opt/cross/bin:$PATH

#####################
#1. build Binutils
mkdir build-binutils
cd build-binutils
../$BINUTILS_PATH/configure --prefix=/opt/cross --target=$TARGET  || { echo 'step 1 -1  failed' ; exit 1; }
make -j32  || { echo 'step 1 -2  failed' ; exit 1; }
make install || { echo 'step 1 -3  failed' ; exit 1; }
cd ..

##########################
#2. install Kernel Header
cd $K_HEADER_PATH
make ARCH=arm INSTALL_HDR_PATH=/opt/cross/$TARGET headers_install || { echo 'step 2 -1  failed' ; exit 1; }
cd ..

############################
#3. C/C++ Compilers
mkdir -p build-gcc
cd build-gcc
../$GCC_PATH/configure --prefix=/opt/cross --target=$TARGET --enable-languages=c,c++ || { echo 'step 3 -1  failed' ; exit 1; }
make -j32 all-gcc  || { echo 'step 3 -2  failed' ; exit 1; }
make install-gcc || { echo 'step 3 -3  failed' ; exit 1; }
cd ..


#############################
#4. Standard C Library Headers and Startup Files
mkdir -p build-glibc
cd build-glibc
../$GLIBC_PATH/configure --prefix=/opt/cross/$TARGET --build=$MACHTYPE --host=$TARGET --target=$TARGET --with-headers=/opt/cross/$TARGET/include libc_cv_forced_unwind=yes
make install-bootstrap-headers=yes install-headers || { echo 'step 4 -1  failed' ; exit 1; }
make -j32 csu/subdir_lib || { echo 'step 4 -2  failed' ; exit 1; }
install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross/$TARGET/lib
$TARGET-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross/$TARGET/lib/libc.so
touch /opt/cross/$TARGET/include/gnu/stubs.h
cd ..


###########################
#5. Compiler Support Library
cd build-gcc
make -j32 all-target-libgcc || { echo 'step 5 -1  failed' ; exit 1; }
make install-target-libgcc || { echo 'step 5 -2  failed' ; exit 1; }
cd ..

###########################
#6. Standard C Library
cd build-glibc
make -j32 || { echo 'step 6 -1  failed' ; exit 1; }
make install || { echo 'step 6 -2  failed' ; exit 1; }
cd ..

#############################
#7. Standard C++ Library
cd build-gcc
make -j32 || { echo 'step 7 -1  failed' ; exit 1; }
make install || { echo 'step 7 -2  failed' ; exit 1; }

cd ..


$TARGET-gcc -v

echo "#include <stdio.h>" > hello_world.c
echo "void main(void){printf(\"hello world\");}">> hello_world.c


$TARGET-gcc -v hello_world.c -o hello_world

readelf -e hello_world | less


