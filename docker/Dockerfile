## https://github.com/marsjtod/demon
## requirements ====
## tensorflow 1.4.0
## cmake 3.7.1
## python 3.5
## cuda 8.0.61 (required for gpu support)
## VTK 7.1 with python3 interface (required for visualizing point clouds)



# ==================================================================
# module list
# ------------------------------------------------------------------
# python        3.6    (apt)
# tensorflow    latest (pip)
# ==================================================================

FROM nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04

ENV LANG C.UTF-8
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \

    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \

    apt-get update 
    # && \

# ==================================================================
# tools
# ------------------------------------------------------------------ 

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y --no-install-recommends \
       build-essential \
       apt-utils \
       ca-certificates \
        wget \
        git \
        vim \
        libssl-dev \
        curl \
        unzip \
        unrar 
        # \
        # && \

ENV DEBIAN_FRONTEND noninteractive
    #git clone --depth 10 https://github.com/Kitware/CMake.git ~/cmake && \
RUN git clone --depth 10 -b v3.7.1 https://github.com/Kitware/CMake ~/cmake && \
    cd ~/cmake && \
    ./bootstrap && \
    make -j"$(nproc)" install 
    # && \

# ==================================================================
# python
# ------------------------------------------------------------------

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y --no-install-recommends \
        software-properties-common \
        && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update 
    # && \
    
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y --no-install-recommends \
        python3.5 \
        python3.5-dev \
        python3-distutils-extra \
        && \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python3.5 ~/get-pip.py && \
    ln -s /usr/bin/python3.5 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.5 /usr/local/bin/python 
    # && \

RUN python -m pip --no-cache-dir install --upgrade \
        setuptools \
        && \
    python -m pip --no-cache-dir install --upgrade \
        numpy \
        cloudpickle \
        Cython \
        tqdm \
        jupyter
        # \
        # && \

# ==================================================================
# tensorflow
# ------------------------------------------------------------------

RUN python -m pip --no-cache-dir install --upgrade \
#        tensorflow-gpu==1.4.0
        tensorflow==1.4.0
        # \
        # && \


# ==================================================================
# pip install for project
# ------------------------------------------------------------------
RUN python -m pip --no-cache-dir install --upgrade \
        pillow \
        matplotlib \
        pandas \
        h5py \
        scipy \
        scikit-image \
        xarray


# ** install minieigen

# apt-get install -y libboost-python-dev
# apt-get install libeigen3-dev
# RUN python -m pip --no-cache-dir install --upgrade \
#         minieigen
#pip install git+https://github.com/eudoxos/minieigen.git
#RUN git clone https://github.com/eudoxos/minieigen.git 
    # && \
    # g++ -ansi src/minieigen.cpp src/double-conversion/*.cc -o minieigen.so -shared -fPIC `pkg-config python --cflags` -lboost_python -I/usr/include/eigen3

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y --no-install-recommends \
    libboost-python-dev \
    libeigen3-dev \
    python-minieigen && \    
    pip install minieigen

# # ==================================================================
# # config & cleanup
# # ------------------------------------------------------------------

RUN ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*

## === installation for multi_vi_h5~~~~
# https://github.com/marsjtod/demon/tree/master/multivih5datareaderop
# 1. hdf5 1.8.16
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libhdf5-dev 

SHELL ["/bin/bash", "-c"]

# 2. OpenCV 3.2.0 
# https://hub.docker.com/r/victorhcm/opencv/dockerfile
RUN \
    cd ~ && \
    wget https://github.com/Itseez/opencv/archive/3.2.0.zip && \
    unzip 3.2.0.zip && \
    mv ~/opencv-3.2.0/ ~/opencv/ && \
    rm -rf ~/3.2.0.zip 
    
    #&& \
RUN \
    cd ~ && \
    wget https://github.com/opencv/opencv_contrib/archive/3.2.0.zip -O 3.2.0-contrib.zip && \
    unzip 3.2.0-contrib.zip && \
    mv opencv_contrib-3.2.0 opencv_contrib && \
    rm -rf ~/3.2.0-contrib.zip 
    #&& \

# mars : no cuda => -D WITH_CUDA=OFF, no vtk => -D WITH_VTK=OFFcd 
RUN \
    cd ~/opencv && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_C_EXAMPLES=OFF \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D WITH_CUDA=OFF \
        -D WITH_VTK=OFF \
        -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
        -D BUILD_EXAMPLES=ON .. 
        #&& \

RUN \
    cd ~/opencv/build && \
    make -j $(nproc) && \
    make install && \
    ldconfig && \

    # clean opencv repos
    rm -rf ~/opencv/build && \
    rm -rf ~/opencv/3rdparty && \
    rm -rf ~/opencv/doc && \
    rm -rf ~/opencv/include && \
    rm -rf ~/opencv/platforms && \
    rm -rf ~/opencv/modules && \
    rm -rf ~/opencv_contrib/build && \
    rm -rf ~/opencv_contrib/doc

# # 3. bild multi_vi_h5
# RUN cd ~/demon-sfm && \
#     mkdir build
#     cd build
#     cmake ..
#     make

# ==================================================================
# demon-sfm source setup
# ------------------------------------------------------------------

# git clone --recursive https://github.com/lmb-freiburg/demon.git
# cmake .. # add '-DBUILD_WITH_CUDA=OFF' to build without gpu support
# (optional) run 'ccmake .' here to adjust settings for gpu code generation
# make
# pew add $DEMON_DIR/lmbspecialops/python # add to python path
# export PYTHONPATH="${PYTHONPATH}:$DEMON_DIR/lmbspecialops/python"

# # ** build lmbspecialops
# #ENV DEMON_DIR=$PWD/demon && \
# ENV DEMON_DIR=/workspace/demon-sfm
# #RUN mkdir $DEMON_DIR/lmbspecialops/build && \
# RUN cd $DEMON_DIR/lmbspecialops/build && \
#     cmake -DBUILD_WITH_CUDA=OFF .. && \
#     make

# # ** download weights
# RUN cd $DEMON_DIR/weights && \
#     ./download_weights.sh

### Multiview H5 data reader
# cd $DEMON_DIR # change to the demon root directory

# mkdir build 
# cd build 

# pew in demon_venv
# cmake ..
# make

# # run example
# RUN cd $DEMON_DIR/examples && \
# # for evaluation
#     python evaluation.py

# mars : module in/out sample
# # opens a window with the depth map (and the point cloud if vtk is available)
#     # python example.py

ENV PYTHONPATH="${PYTHONPATH}:$DEMON_DIR/lmbspecialops/python"
# mars !!! for python module lmbspecialops
# # export PYTHONPATH="${PYTHONPATH}:/workspace/demon-sfm/lmbspecialops/python"

EXPOSE 7222