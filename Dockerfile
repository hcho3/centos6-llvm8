FROM centos:6

RUN \
  yum -y update && \
  yum install -y tar unzip wget xz git && \
  wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo && \
  yum install -y devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-c++ && \
  wget https://repo.continuum.io/miniconda/Miniconda2-4.3.27-Linux-x86_64.sh && \
  bash Miniconda2-4.3.27-Linux-x86_64.sh -b -p /opt/python && \
  wget -nv -nc https://cmake.org/files/v3.6/cmake-3.6.0-Linux-x86_64.sh --no-check-certificate && \
  bash cmake-3.6.0-Linux-x86_64.sh --skip-license --prefix=/usr

ENV PATH=/opt/python/bin:$PATH
ENV CC=/opt/rh/devtoolset-2/root/usr/bin/gcc
ENV CXX=/opt/rh/devtoolset-2/root/usr/bin/c++
ENV CPP=/opt/rh/devtoolset-2/root/usr/bin/cpp

RUN mkdir -p /packages && cd /packages && \
    wget http://releases.llvm.org/8.0.0/llvm-8.0.0.src.tar.xz && \
    tar xvf llvm-8.0.0.src.tar.xz && \
    mkdir -p llvm-8.0.0.src/build && \
    cd llvm-8.0.0.src/build && \
    cmake .. -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON && \
    make -j100 install && \
    cd ../../.. && rm -rfv /packages

COPY entrypoint.sh /scripts/

ENV GOSU_VERSION 1.10

# Install lightweight sudo (not bound to TTY)
RUN set -ex; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

WORKDIR /workspace
ENTRYPOINT ["/scripts/entrypoint.sh"]
