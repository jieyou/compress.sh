compress.sh
===========

一个web站点用的无损压缩图片的工具，它区分图片类型并使用对应的压缩个工具将它压缩

===========

github上没有调格式，具体请移步http://youyodf.sinaapp.com/archives/361

这篇文章讲给出一套对网页内使用的图片的无损压缩的方法通常来说，网页上的图片分为这4类 jpg格式、png格式、一帧的gif格式、多帧的gif格式参考《高性能网站进阶指南》里面的办法，我将这些工具一一下载编译安装好，并写了一个脚本，读者按照我的方法并使用这个脚本可以完成图片压缩工具的快速部署和使用。

安装

首先，你需要一台unix或者liunx机器，用如下操作来一个一个安装

1.pngcrush

这个工具用来压缩png

1.下载

下载地址为: http://pmt.sourceforge.net/pngcrush/
点击左上角的Download，进入下载页面，复制安装包的连接地址（http://sourceforge.net/projects/pmt/files/latest/download?source=files）

wget http://sourceforge.net/projects/pmt/files/latest/download?source=files
2.解压

下载后的文件为pngcrush-1.7.41.tar.xz；
要进行两次解压：

xz -d pngcrush-1.7.41.tar.xz
tar -xvf pngcrush-1.7.41.tar
解压后的文件夹名称为pngcrush-1.7.41

3.编译运行

cd pngcrush-1.7.41
make
编译完成后会出现
-rwxr-xr-x 1 root root 472987 12-05 19:14 pngcrush
即可执行的程序算是成功
在当前路径下输入

./pngcrush
会出现版本以及help信息，代表安装成功。
为了使它在任何路径都可以直接使用
可以给它增加一个”软链“

cd /usr/local/sbin
ln -s /search/pngcrush-1.7.41/pngcrush pngcrush
这样就可以在任意路径使用pngcrush命令

2.jpegtran的部署

1.下载

wget http://www.ijg.org/files/jpegsrc.v8d.tar.gz
2.解压

tar xzvf jpegsrc.v8d.tar.gz
3.编译安装

cd jpeg-8d
vi install.txt #这个路径下有一个安装提示，install.txt 按照里面的操作步骤执行即可
./configure
make -n install # 或者make 即可
会发现/usr/bin/下已经有了jpegtran

jpegtran -copy none -optimize src.jpg >dest.jpg
可以试试是否安装成功

3.ImageMagick

wget http://www.imagemagick.org/download/linux/CentOS/x86_64/ImageMagick-6.8.0-7.x86_64.rpm
rpm -Uvh ImageMagick-6.8.0-7.x86_64.rpm
我遇到的情况是报错缺少依赖库的支持
用

rpm -Uvh ImageMagick-6.8.0-7.i386.rpm --nodeps --force
虽然不报错了但是没有安装成功
报错缺少的lib文件依次安装好后再执行

rpm -Uvh ImageMagick-6.8.0-7.i386.rpm
就没问题了

4.gifsicle

wget http://www.lcdf.org/gifsicle/gifsicle-1.68.tar.gz
tar -xvf gifsicle-1.68.tar.gz
cd gifsicle-1.68
./configure
make
此时/usr/local/bin/已经有gifsicle，即已安装成功

 

写一个脚本将它们串起来操作，并且能自动区分图片文件类型

随后我写了一个shell脚本来区分图片文件类型并使用对用的压缩工具压缩

源代码托管到了github上：https://github.com/jieyou/compress.sh

将compress.sh下载下来后，用下面的方法使用：

1.建立工作文件夹，将compress.sh拷贝至这个文件夹

2.测试使用

在上述目录下有一个测试用的图片包的文件夹，名称为test_img_bak，用于我自己调试，对于新用户，你依然可以使用它来测试使用方法

rsync -atv test_img_bak/* test_img/ #复制test_img_bak里面的图片文件到test_img，请注意，不要直接修改test_img_bak里面的文件
sh compress.sh test_img #使用脚本压缩test_img文件夹内的各类图片文件、
3.压缩你自己的图片

本节以使用svn管理项目的图片源文件为例，别的方式也可以
使用compress.sh来压缩你自己的图片
首先建立并进入svn_dir目录，以你自己的名字建立一个文件夹并进入该文件夹，如

mkdir svn_dir
cd svn_dir
mkdir foo
cd foo

然后将你的项目文件里的图片文件夹check out出来

svn co http://your_imgs_path/your_app_name/images
然后运行压缩脚本

cd .. #退回到 /search/youyo
sh compress.sh foo your_app_name/images #压缩你的项目文件里面的图片
svn ci --m ‘after compress’ #压缩后提交到svn
4.高级用法，将一帧的gif转换为png

对于一帧的图像，png在各个方面都胜于gif，在压缩率上也是，因此，我建议对于一帧的非动画的图标，尽量使用png而不是gif
在sh时，带入第二个参数“gif2png”可以将一帧的gif转换为png格式

sh compress.sh test_img gif2png #使用脚本压缩test_img文件夹内的各类图片文件，并且将一帧的gif转换为png格式以便于获得更大的压缩率
不用担心，所有被转换为png格式的gif都会在终端提示你，如
“test_img/gif_one_frame.gif convert to png;compress ratio is 67.78%”

它压缩了什么

请注意，这个工具以任何算法压缩的任何格式的图像文件都是无损的

1.对于jpg或jpeg

剥离元数据（如注释、应用程序内部信息---如photoshop、EXIT-----如相机型号、拍摄日期等）
对霍夫曼表进行优化，等

2.对于png

删除除了控制透明的alpha块的其它所有块
尝试减少调色板中的颜色数量
使用超过100种算法来压缩，不冗述

3.对于多帧gif

将动画里连续帧的重复像素删除
压缩索引颜色表，等

4.对于单帧gif

如果有gif2png参数，则转换为png后再使用png的算法压缩
如果没有gif2png参数，则算法同多帧gif
