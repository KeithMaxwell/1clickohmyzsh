# 1clickohmyzsh

一条命令安装oh my zsh。再附加两个常用的插件：语法高亮（zsh-syntax-highlighting）和自动提示（zsh-autosuggestions）。

## Warning

该脚本仅支持在linux/mac上运行，**Windows无法使用**。git和zsh若没有安装，只支持有apt或yum包管理系统自动安装。

如果您的系统基于 Debian/Redhat，您可以尝试运行此脚本，它很可能是可以用的。

如果您的系统已经安装了git以及zsh，则也可以运行此脚本。

## Dependency

请确保`grep` 命令可以在您的计算机上运行。 如果没有，就想办法安装。

请确保您具有 sudo 权限。 没有它就无法工作。

## Note

该脚本中oh my zsh的安装使用的是清华大学的镜像，插件的安装使用的是南京大学的镜像。

## install by 1 command

```shell
curl -L https://raw.githubusercontent.com/KeithMaxwell/1clickohmyzsh/main/1click_install.sh | bash
```

