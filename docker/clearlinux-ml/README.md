Intel CPU Optimized Machine Learning Dockerfile based on Clear Linux
================

根據 [Clear Linux Dockerfile - Intel MKL 版本](https://github.com/clearlinux/dockerfiles/tree/master/stacks/dlrs/mkl) 增修 Tensorflow 的 CPU 指令集編譯 Flags 支援。

編譯
-----
```
docker build -t <自訂標籤名>:mkl .
```

從 Dockerhub 直接下載影像檔
------------------------------
```
docker pull eeptman/clrlnx-ml:mkl
```

執行
----------------------------------
```
docker run --rm -it eeptman/clrlnx-ml:mkl
```
