
OpenDayLight[1]（简写为ODL）的硼Boron版本于2016-09-21正式发布，但在github中稳定的源码版本（stable-boron）在前几天已开放。作为一款开源SDN网络控制器，依托于强大的社区支持以及丰富的功能特性，ODL成为了目前主流的SDN网络控制器开发平台。不仅为开发者提供了大量的网络管理功能，而且藉由MD-SAL(模型驱动的服务层), 给独立的网络应用提供了完善的二次开发接口。由于OpenDaylight架构的复杂性和多样性，以及ODL上官方wiki文档更新的比较缓慢，往往给开发者带来很多的困难。
下面我们以最新的版本硼Boron为例，讲解ODL的入门应用开发技术，此开发同样适用于前几个版本，本文暂不提及硼版本的新功能特性及性能的加强，主要是以硼版本（最新版本）总结简单的开发实例流程，给ODL入门开发者提供一个更新的版本支持。
一、介绍
1.1 ODL应用开发
ODL做为网络控制器, 将网络设备和应用程序连接起来。通过南向接口(例如OpenFlow协议等)管理和控制实际的网络物理设备, 通过北向接口(例如RESTConf形式的接口)向外部应用程序提供信息获取和操作下发的功能。如下图所示:
 
图1-1 ODL和APP
对于南向接口, 设备厂商会比较关注; 应用开发主要集中于北向接口。本文我们只关注于北向接口的APP的开发。
开发ODL的应用有两种模式：如下图所示
	模式一 外部应用，应用通过ODL提供的RESTful接口使用ODL提供的全部功能
	模式二 内部应用, 应用内嵌于ODL中, 同时向外部暴露RESTful接口以供外部程序调用
 
图1-2 应用开发模式
采用RESTful接口的应用开发和传统的开发模式类似，不再详细说明。完全使用RESTful的方式，当业务逻辑复杂时，可能会导致调用RESTful接口过多影响性能而且开发复杂。另一方面, ODL提供的RESTful接口不一定能满足业务逻辑要求, 此时，就需要模式二的ODL内部应用开发, 然后通过自定义的RESTful接口向外暴露功能。
1.2 OSGi简介
OSGi[2]是采用Java语言的一种面向服务的组件模型, 它提供了模块化为基础开发应用的基本架构。模块可以动态加载/卸载，向外暴露功能和隐藏内部实现细节等, 模块在称为容器的环境中运行。OSGi的实现有Apache Felix, Equinox , Spring DM 等.
OpenDaylight基于OSGi的实现Apache Karaf（Apache Felix的一个子项目）来构造系统。 模块也称为bundle, ODL的内部应用就是一个个的bundle, 它们放置在ODL目录的system子目录下, 以maven的存储库形式组织。借助于OSGi的架构, ODL中的内部应用可以动态加载和卸载, 系统具有很好的灵活性和可扩展性, 这对于大型系统而言是非常重要的。
模块不仅向外提供接口, 而且需要使用其它模块提供的功能, 也即模块之间具有依赖性。因此ODL内部应用的开发除了专注于功能, 而且对不同的ODL生产版本，需要配置不同的依赖。
二、 ODL之硼Boron版本应用开发
此部分内容主要来自于ODL的DOC，并提供github链接，获取stable-boron稳定版本（https://github.com/opendaylight/controller/archive/stable/boron.zip）。

2.1 开发环境搭建
开发环境配置如下:
1) 64位Linux系统，4G以上内存, 16G以上硬盘剩余空间(如果编译ODL发行版的话)
2) JDK8, maven-3.3.x
3) 环境变量设置(设置JAVA_HOME, M2_HOME, PATH变量设置, MAVEN_OPTS选项设置等, 略)
export JAVA_HOME=…
export MAVEN_OPTS="-Xmx1024m"
2.2 开发示例项目
0) 获取ODL的maven配置文件(用于maven编译时下载ODL的相应jar文件)
# cp ~/.m2/settings.xml ~/.m2/settings.xml.old
  # wget -q -O - https://raw.githubusercontent.com/opendaylight/odlparent/stable/boron/settings.xml > ~/.m2/settings.xml
1)	用maven生成项目框架(设项目为hello)
# mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller \
-DarchetypeArtifactId=opendaylight-startup-archetype \
-DarchetypeRepository=https://nexus.opendaylight.org/content/repositories/public/ \
-DarchetypeCatalog=https://nexus.opendaylight.org/content/repositories/public/archetype-catalog.xml
(输入如下内容)
Define value for property 'groupId': : org.test.hello
Define value for property 'artifactId': : hello
Define value for property 'package':  org.test.hello: : 
Define value for property 'classPrefix':  Hello: : 
Define value for property 'copyright': : TEST Inc.
上述步骤完成后, 在当前目录下面会生成hello目录, 即为我们的APP目录.
2) 修改依赖项(针对硼Boron版本)
# cd hello (进入hello项目目录)
# 依次打开文件: pom.xml, api/pom.xml, artifacts/pom.xml, features/pom.xml, impl/pom.xml, it/pom.xml, karaf/pom.xml, 修改内容(其中features/pom.xml修改多处)
按照下面列出的各自修改对应的依赖的版本号: 
odlparent(odlparent-lite): 1.7.0-Boron
 binding-parent: 0.9.0-Boron
 mdsal.model: 0.9.0-Boron
 mdsal: 1.4.0-Boron
 restconf: 1.4.0-Boron
 yangtools: 1.0.0-Boron
 dlux: 0.4.0-Boron
 config-parent: 0.5.0-Boron
 mdsal-it-parent: 1.4.0-Boron
 karaf-parent: 1.7.0-Boron
例如文件features/pom.xml, 修改后如下(加粗部分):
<parent>
    <groupId>org.opendaylight.odlparent</groupId>
    <artifactId>features-parent</artifactId>
    <version>1.7.0-Boron</version>
    <relativePath/>
  </parent>
……
<properties>
    <mdsal.model.version>0.9.0-Boron</mdsal.model.version>
    <mdsal.version>1.4.0-Boron</mdsal.version>
    <restconf.version>1.4.0-Boron</restconf.version>
    <yangtools.version>1.0.0-Boron</yangtools.version>
    <dlux.version>0.4.0-Boron</dlux.version>
    <configfile.directory>etc/opendaylight/karaf</configfile.directory>
  </properties>
2)	编译和运行
#mvn clean install
#./karaf/target/assembly/bin/karaf
进入ODL控制台,输入如下命令可以看到结果:
opendaylight-user@root>feature:list -i | grep hello
opendaylight-user@root>log:display | grep Hello
3)	添加基于yang模型的RPC接口, 并编译运行
添加接口并编译的内容看ODL的文档, 略.
访问URL: http://:8181/apidoc/explorer/index.html , 用户名密码admin/admin.
可以看到hello-world RPC接口, 输入{"input": { "name":"Good day"}} , 可以看到结果。

 
Curl访问RPC验证:
#curl --user "admin":"admin" \
-H "Accept: application/json" \
-H "Content-type: application/json" \
-X POST --data "{'hello:input': { 'name':'Good day ODL'}}" \
 http://localhost:8181/restconf/operations/hello:hello-world
2.3 安装到ODL生产版本
有两种方法: 方法一为将当前生成hello项目的bundle拷贝到已经正常部署运行的ODL的硼版本上; 方法二为重新编译一个包含hello项目的ODL发行版。
1) 方法一: 手动拷贝bundle
由于ODL以OSGi的方式组织, 因此项目hello也是一个OSGi的bundle. 在ODL中, bundle位于ODL发行版的目录的system/子目录下, 并且各个bundle以maven的包形式组织。我们hello项目正常编译运行后, hello的bundle存在于当前hello目录下面的karaf/target/assembly/system下面(其它很多bundle不要拷贝), 我们从此目录拷贝hello自己的bundle到ODL的发行版即可。
（1）拷贝: 假设当前正常部署运行的ODL发行版位于: /home/guest/distribution-karaf-0.5.0-Boron
当前的hello项目位于/home/guest/bin/hello
那么拷贝命令如下:
#cp -Ru /home/guest/bin/hello/karaf/target/assembly/system/org/bupt  /home/guest/distribution-karaf-0.5.0-Boron/system/org
（2） 查看hello的maven路径:
#cd hello (进入hello项目目录)
#cat ./karaf/target/assembly/etc/org.apache.karaf.features.cfg
查看这一行:featuresRepositories
在最后有hello的mvn路径: "mvn:org.test.odl/hello-features/1.0.0-SNAPSHOT/xml/features"
（3）运行ODL并添加和安装hello的bundle:
#cd /home/guest/distribution-karaf-0.5.0-Boron
#./bin/karaf (启动ODL运行, 或者以干净模式启动: ./bin/karaf clean)
#opendaylight@root> feature:repo-add mvn:org.test.odl/hello-features/1.0.0-SNAPSHOT/xml/features
# opendaylight@root> feature:install odl-hello-ui
# opendaylight@root> feature:list | grep hello
# opendaylight@root> log:display | grep Hello
可以看到运行结果正常。
(移除bundle)
# opendaylight@root> feature:repo-remove mvn:org.bupt.siwind.odl/hello-features/1.0.0-SNAPSHOT/xml/features
2) 方法二: 编译hello项目到ODL发行版中
（1） 编译ODL发行版:
#git clone https://git.opendaylight.org/gerrit/integration/distribution.git
#git tag
#git checkout release/boron  (切换需要的版本)
#mvn mvn clean install
编译成功后在当前目录下的distribution-karaf\target下面有压缩包形式的发行版:
distribution-karaf-0.5.0-Boron.tar.gz, distribution-karaf-0.5.0-Boron.zip
当前目录下的distribution-karaf\target\assembly为解压缩后的karaf执行版本
（2）记录hello项目的信息
# cat <hello项目的目录>/features/pom.xml
 (记录hello-feature的版本等信息)
# cat <hello项目的目录>/karaf/target/assembly/etc/org.apache.karaf.features.cfg
 (记录hello的mvn路径: "mvn:org.test.odl/hello-features/1.0.0-SNAPSHOT/xml/features")
（3） 添加hello的bundle信息
此步骤之前，确保hello编译运行和测试例运行通过, 并且用mvn clean install 安装其bundle到了.m2/repository下面。
在当前的distribution目录下面, 修改如下两个pom.xml文件
# vim features-index/pom.xml , 添加如下内容:
	    <dependency>
          <groupId>org.test.odl</groupId>
          <artifactId>hello-features</artifactId>
          <version>1.0.0-SNAPSHOT</version>
          <classifier>features</classifier>
          <type>xml</type>
        </dependency>
# vim features-index/src/main/resources/features.xml, 添加如下内容:
<repository>mvn:org.test.odl/hello-features/1.0.0-SNAPSHOT/xml/features</repository>
（4）重新编译发行版
#mvn clean install
 
3. 结论
本文介绍了目前2016最新的ODL硼Boron版本的应用开发基础步骤, 其也适用于其它版本的开发， 以及介绍了一些OSGi相关的背景技术; 增加了将应用集成到发行版ODL的方法，和简单的RPC接口示例。
4. FAQ
1) 不能在ODL发行版中正常加载hello项目
A: 查看是否hello的各个pom.xml中定义的依赖版本符合当前运行的ODL发行版
2) 编译ODL的integration/distribution发行版时, 某些依赖的bundle不能下载
A: 查看报错的是哪个bundle, 这里是ODL的仓储, 用git自行下载此bundle源码, 编译到本机的.m2/repository中.
例如： 
# git clone https://git.opendaylight.org/gerrit/${PROJECT}.git
# cd {PROJECT}
# mvn clean install
