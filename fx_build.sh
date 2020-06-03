#! /usr/bin/bash
MYOBJ_DIR=
ICEWEASEL_TREE=`pwd -W 2>/dev/null || pwd`
FIND_FILE=".mozconfig"
if [ ! -f "$FIND_FILE" ]; then
  [[ -f mozconfig32 ]] && cp mozconfig32 $FIND_FILE 2>/dev/null || cp mozconfig64 $FIND_FILE 2>/dev/null
fi
if [ ! -f "$FIND_FILE" ]; then
  echo $FIND_FILE not exist!
  exit 1;
fi
FIND_STR="ac_add_options --target=i686-pc-mingw32"
if [ "$OS" != "Windows_NT" ]; then
  PATH=$PATH:~/.cargo/bin
  MYOBJ_DIR=obju-linux64
  PYTHON_SCRIPT=_virtualenvs/init/bin
  MAKE=make
else
  if [ `grep -c "^$FIND_STR" $FIND_FILE` -ne '0' ];then
    [[ -n $MY_OBJ ]] && MYOBJ_DIR=$MY_OBJ || MYOBJ_DIR=obju32-release
  else
    [[ -n $MY_OBJ ]] && MYOBJ_DIR=$MY_OBJ || MYOBJ_DIR=obju64-release
  fi
  PYTHON_SCRIPT=_virtualenvs/init/Scripts
  MAKE=mozmake
fi

rm -f ./configure
rm -f ./configure.old
autoconf-2.13
rm -rf ../$MYOBJ_DIR
mkdir ../$MYOBJ_DIR && cd ../$MYOBJ_DIR
$ICEWEASEL_TREE/configure --enable-profile-generate=cross
$MAKE -j4
if [ "$?" != "0" ]; then
  echo First compilation failed. > error.log
  exit 1;
fi

$MAKE package
if [ "$?" != "0" ]; then
  echo First package failed. > error.log
  exit 1;
fi

if [ -n "$LOCAL_WITH_VC15" ]; then
  JARLOG_FILE=jarlog/en-US.log $PYTHON_SCRIPT/python $ICEWEASEL_TREE/build/pgo/profileserver.py
else
  $PYTHON_SCRIPT/pip install -U selenium
  $PYTHON_SCRIPT/python $ICEWEASEL_TREE/build/pgo/profileserver2.py
fi

ls *.profraw >/dev/null 2>&1
if [ "$?" != "0" ]; then
  echo profileserver.py failed. >> error.log
  exit 1;
fi

$MAKE maybe_clobber_profiledbuild
$ICEWEASEL_TREE/configure --enable-profile-use=cross --enable-lto=cross
$MAKE -j4
if [ "$?" != "0" ]; then
  echo Second compilation failed. >> error.log
  exit 1;
fi
$MAKE package
echo Compile completed!
rm -f $FIND_FILE
