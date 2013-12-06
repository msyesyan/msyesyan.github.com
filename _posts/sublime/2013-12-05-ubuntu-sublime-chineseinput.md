---
layout: post
title: "Ubuntu Sublime ChineseInput"
description: ""
category: ""
tags: [sublime, ubuntu, fcitx]
---
{% include JB/setup %}

##一、安装fcitx输入法

### 1.卸载掉ibus输入法
    sudo killall ibus-daemon
    sudo apt-get purge ibus ibus-gtk ibus-gtk3 ibus-pinyin* ibus-sunpinyin ibus-table python-ibus
    rm -rf ~/.config/ibus

### 2.添加fcitx源，并安装fcitx-googlepinyin输入法
    sudo add-apt-repository ppa:fcitx-team/nightly
    sudo apt-get update
    sudo apt-get install fcitx-googlepinyin

### 3.设置fcitx为默认输入发
 **System Settings -> Lanuage Support -> KeyBoard Method Input System -> fcitx**  
 **设置fcitx开机自动启动：search -> startup applications -> add fcitx startup settings,如下图:**

 ![]({{ site.url }}/assets/resources/posts/ubuntu-sublime-chineseinput/startup-settings.png)


##二、配置sublime中文输入法

###1.保存以下代码到文件sublime-imfix.c
    #include <gtk/gtkimcontext.h>
    void gtk_im_context_set_client_window (GtkIMContext *context,
              GdkWindow    *window)
    {
      GtkIMContextClass *klass;
      g_return_if_fail (GTK_IS_IM_CONTEXT (context));
      klass = GTK_IM_CONTEXT_GET_CLASS (context);
      if (klass->set_client_window)
        klass->set_client_window (context, window);
      g_object_set_data(G_OBJECT(context),"window",window);
     
      if(!GDK_IS_WINDOW (window))
        return;
      int width = gdk_window_get_width(window);
      int height = gdk_window_get_height(window);
      if(width != 0 && height !=0)
        gtk_im_context_focus_in(context);
    }

###2.安装C/C++的编译环境和gtk libgtk2.0-dev
    sudo apt-get install build-essential
    sudo apt-get install libgtk2.0-dev

###3.编译成共享库
    gcc -shared -o libsublime-imfix.so sublime_imfix.c  `pkg-config --libs --cflags gtk+-2.0` -fPIC

###4.测试运行
    LD_PRELOAD=./libsublime-imfix.so sublime_text

`注意：sublime_text 为sublime-text安装后的可执行命令，不同版本的名称可能不一样`

###8.拷贝文件到/opt/sublime_text目录下
    sudo cp libsublime-imfix.so /opt/sublime_text/libsublime-imfix.so

###9.打开终端修改/usr/bin/subl

    sudo vim /usr/bin/subl,在第一行加入
    export LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so

###10.修改sublime-text-3.desktop
    sudo vim /usr/share/applications/sublime_text.desk

    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Sublime Text
    GenericName=Text Editor
    Comment=Sophisticated text editor for code, markup and prose
    Exec=/usr/bin/subl %F
    Terminal=false
    MimeType=text/plain;
    Icon=sublime-text
    Categories=TextEditor;Development;
    StartupNotify=true
    Actions=Window;Document;

    [Desktop Action Window]
    Name=New Window
    Exec=/usr/bin/subl -n
    OnlyShowIn=Unity;

    [Desktop Action Document]
    Name=New File
    Exec=/usr/bin/subl --command new_file
    OnlyShowIn=Unity;

##配置完毕


