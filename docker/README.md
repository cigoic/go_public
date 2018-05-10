# Dockerfiles

- Dockerfile collection related to Go, Jupyter Notebook, Data Science tools.

Files:

* gophernotes_py3/Dockerfile	- Based on official Tensorflow docker image. Create a new image with Jupyter Notebook + Go + Tensorflow support.
* lgo_py3/Dockerfile		- Based on official Golang docker image. Using lgo(better support ability).

### 測試是否安裝成功

* tf_hello.go
* tf_hello.ipynb		- 這兩個檔案可用來測試 Tensorflow 是否安裝成功
* tf_img_rec.go			- 官方版測試 Go API 範例，使用 Inception 辨識影像

開啟 Terminal 執行命令:
	
	go run tf_hello.go
	go run tf_example.go -dir=/tmp -image=cat.jpeg

### Reference:

lgo - https://github.com/yunabe/lgo


### TODO:

* Refine gophernotes' Dockerfile to adopt content from lgo's Dockerfile.
