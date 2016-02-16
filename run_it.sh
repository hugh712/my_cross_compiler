#!/bin/bash


##############
#create folder
mkdir pi_pross

################################
#download packages via wget-list
#wget --input-file=wget-list --continue --directory-prefix=./pi_cross

##################
#get package names
BINUTILS_PATH=$(ls pi_pross | grep binutils.* | sed 's/.tar.*//I')
GCC_PATH=$(ls pi_pross | grep gcc.* | sed 's/.tar.*//I')
K_HEADER_PATH=$(ls pi_pross | grep linux.* | sed 's/.tar.*//I')
GLIBC_PATH=$(ls pi_pross | grep glibc.* | sed 's/.tar.*//I')
MPFR_PATH=$(ls pi_pross | grep mpfr.* | sed 's/.tar.*//I')

#be careful of  GMP package, there is an 'a' after the package name
GMP_PATH=$(ls pi_pross | grep gmp.* | sed 's/[a-z].tar.*//I')
MPC_PATH=$(ls pi_pross | grep mpc.* | sed 's/.tar.*//I')
ISL_PATH=$(ls pi_pross | grep isl.* | sed 's/.tar.*//I')
CLOOG_PATH=$(ls pi_pross | grep cloog.* | sed 's/.tar.*//I')


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
cd pi_pross
echo "packages untar..."
#for f in *.tar*; do tar xf $f; done



#################
#check file exist
error_unm=0
pwd
if [  -d "$BINUTILS_PATH" ];then
	echo "folder not found! $BINUTILS_PATH"; exit 1
elif [  -d "$GCC_PATH" ];then
	echo "folder not found! $GCC_PATH"; exit 1
elif [  -d  "$K_HEADER_PATH" ];then
          echo "folder not found! $K_HEADER_PATH"; exit 1
elif [  -d  "$GLIBC_PATH" ];then
          echo "folder not found! $GLIBC_PATH "; exit 1
elif [  -d  "$MPFR_PATH" ];then
          echo "folder not found! $MPFR_PATH "; exit 1
elif [  -d "$GMP_PATH" ];then
          echo "folder not found! $GMP_PATH "; exit 1
elif [  -d "$MPC_PATH" ];then
          echo "folder not found! $MPC_PATH "; exit 1
elif [  -d "$ISL_PATH"  ];then
          echo "folder not found! $ISL_PATH "; exit 1
elif [  -d  "$CLOOG_PATH" ];then
          echo "folder not found! $CLOOG_PATH "; exit 1
fi

###############
#set enviroment
export TARGET=arm-linux-gnueabihf


#build symbolic link
cd $GCC_PATH
ln -s ../$MPFR_PATH mpfr
ln -s ../$GMP_PATH gmp
ln -s ../$MPC_PATH mpc
ln -s ../$ISL_PATH isl
ln -s ../$CLOOG_PATH cloog






