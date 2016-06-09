#! /bin/bash

BUILD_DIR=$PWD/build

INSTALL_DIR=$HOME/.local

BINDIR=$INSTALL_DIR/bin

GITLLVM=$PWD/llvm

TOOLS="clang"

PROJECTS="compiler-rt libcxx libcxxabi"

LLVMURL="http://llvm.org/git"

get_deps () {
    get_gcc
    get_python
    get_cmake
    get_source
}

update_llvm () {
    if ! [ -d $GITLLVM ]; then
        get_source
    fi

    cd $GITLLVM
    git pull -r origin $1

    for x in $TOOLS; do
        pull_submodule tools $x $1
    done

    for x in $PROJECTS; do
        pull_submodule projects $x $1
    done
    make_llvm
}

get_source () {
    if ! [ -d $GITLLVM ]; then
        git clone $LLVMURL/llvm $GITLLVM

        for x in $TOOLS; do
            clone_submodule tools $x &
        done

        for x in $PROJECTS; do
            clone_submodule projects $x &
        done
        wait
    fi
}

clone_submodule () {
    git clone $LLVMURL/$2 $GITLLVM/$1/$2
}

pull_submodule () {
    local prev_dir = $PWD
    cd $GITLLVM/$1/$2
    git pull origin $3
    cd $prev_dir
}

get_gcc () {
    if ! [ -x $BINDIR/gcc -a -x $BINDIR/g++ ]; then
        mkdir -p $BUILD_DIR/gcc-build $BUILD_DIR/tarfiles
        wget https://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2 --directory $BUILD_DIR/tarfiles
        tar xvjf $BUILD_DIR/tarfiles/gcc-4.8.2.tar.bz2 --directory $BUILD_DIR
        cd $BUILD_DIR/gcc-4.8.2
        ./contrib/download_prerequisites
        cd $BUILD_DIR/gcc-build
        $PWD/../gcc-4.8.2/configure --prefix=$INSTALL_DIR --enable-languages=c,c++ --disable-multilib
        make
        make install
    fi
}

get_python () {
    if ! hash python2.7 2> /dev/null; then
        wget https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tar.xz --directory $BUILD_DIR/tarfiles
        tar xvf $BUILD_DIR/tarfiles/Python-2.7.11.tar.xz --directory $BUILD_DIR
        cd $BUILD_DIR/Python-2.7.11
        ./configure --prefix=$INSTALL_DIR
        make
        make install
    fi
}

get_cmake () {
    if ! hash cmake 2> /dev/null; then
        wget https://cmake.org/files/v3.6/cmake-3.6.0-rc1.tar.gz --directory $BUILD_DIR/tarfiles
        tar xvzf $BUILD_DIR/tarfiles/cmake-3.6.0-rc1.tar.gz --directory $BUILD_DIR
        cd $BUILD_DIR/cmake-3.6.0-rc1
        ./bootstrap --prefix=$INSTALL_DIR
        make
        make install
    fi
}

make_llvm () {
    mkdir -p $BUILD_DIR/llvm
    cd $BUILD_DIR/llvm
    CC=$BINDIR/gcc CXX=$BINDIR/g++ cmake -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_C_COMPILER=$BINDIR/gcc \
      -DCMAKE_CXX_COMPILER=/$BINDIR/g++ \
      -DPYTHON_HOME=$INSTALL_DIR/lib/python2.7 \
      -DCMAKE_CXX_LINK_FLAGS="-Wl,-rpath,$INSTALL_DIR/lib64 -L$INSTALL_DIR/lib64" \
      -DLLVM_OPTIMIZED_TABLEGEN=y \
      $GITLLVM
    make -j1
    if [ $? -eq 0 ]; then
        make install
    fi
}

main () {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <options>"
        exit 1
    fi

    local install=0
    local update=0
    local version="master"

    for i in $@; do
        case $1 in
            --install)
                install=1
                shift
                ;;
            --version*)
                version="${i#*=}"
                shift
                ;;
            --update)
                update=1
                shift
                ;;
            --help)
                get_help
                exit 0
                ;;
            *)
                echo "Unrecognized option: \"$1\""
                get_help
                exit 1
                ;;
        esac
    done

    mkdir -p $BUILD_DIR
    get_deps

    if [ $update -ne 0 ]; then
        update_llvm $version
    fi

    if [ $install -ne 0 -a $update -eq 0 ]; then
        if [ $version != "master" ]; then
            update_llvm $version
        else
            make_llvm
        fi
    fi
}

main $@
