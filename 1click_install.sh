#!/bin/bash
# set -e
function apt_config() {
    # 这段代码的工作原理是尝试运行git命令。如果git命令不存在，那么command -v git将返回一个非零的退出状态，
    # if语句就会执行then后面的代码块。
    if ! command -v git &> /dev/null
    then
        # 1. 安装git
        sudo apt install git -y
    else
        echo "git is installed."
    fi

    if grep -q "zsh$" /etc/shells; then
        echo "zsh is installed."
    else
        # 2. 安装zsh
        sudo apt install zsh -y
    fi

}

function yum_config() {
    if ! command -v git &> /dev/null
    then
        # 1. 安装git
        sudo yum install git-core -y
    else
        echo "git is installed."
    fi

    # 判断zsh是否已经安装
    if grep -q "zsh$" /etc/shells; then
        echo "zsh is installed."
    else
        # 2. 安装zsh
        echo "input your password to install dependent packages"
        sudo yum install zsh -y
    fi
}

function mac_config() {
    if ! command -v git &> /dev/null
    then
        # 1. 安装git
        brew install git
    else
        echo "git is installed."
    fi

    # 判断zsh是否已经安装
    if grep -q "zsh$" /etc/shells; then
        echo "zsh is installed."
    else
        # 2. 安装zsh
        brew install zsh
    fi

}

function other_config() {
    command -v git &> /dev/null
    git_status=$?
    grep -q "zsh$" /etc/shells
    zsh_status=$?

    if [ "$git_status" = 0 ] && [ "$zsh_status" = 0 ] ;
    then
        echo "continueing"
    else
        echo "git or zsh is not installed. Please install git and zsh. Exiting"
        exit
    fi
}

echo "you may need to input your password to install some dependent packages(git zsh)"

# 使用uname -s获取操作系统名称
os_name=$(uname -s)

if [ "$os_name" == "Darwin" ]; then
    echo "Mac Configuration."
    mac_config
elif [ "$os_name" == "Linux" ]; then

    command -v apt --version &> /dev/null
    apt_status=$?
    command -v yum --version &> /dev/null
    yum_status=$?
    if [ "$apt_status" = 0 ];
    then
        apt_config
    elif [ "$yum_status" = 0 ];
    then
        yum_config
    else
        echo "apt and yum are not working. "
        other_config
    fi      
else
    echo "This is not a Mac or Linux. Exiting"
    exit
fi



# 进入用户目录
cd || exit

# Git 可能无法验证清华镜像服务器的 SSL 证书。
# 这并不意味着证书有问题，但可能是自签名的，或者由一个不在您的操作系统的 CA 列表中的机构/公司签名的。
if  ! command -v "sslverify=$(git config --global --get http.sslverify)"
    then
        if [ -z "$sslverify" ]; then
            # 将其设置为false
            git config --global http.sslverify false
        else
            if [ "$sslverify" == "true" ]; then
            sslverify_old=$sslverify
            # 先关掉这个验证
            git config --global http.sslverify false
            fi
        fi
    fi

# 下载oh-my-zsh安装脚本
git clone https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git

# 执行oh-my-zsh安装脚本
cd ohmyzsh/tools || exit
REMOTE=https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git sh install.sh <<EOF
Y
EOF
# 这里是为了跳过安装过程中的输入提示，直接输入Y

# 创建zsh插件目录(如果不存在，git可能出现bug)
mkdir "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
mkdir "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting·"

# 安装zsh-autosuggestions插件， 使用南京大学的镜像
git clone https://mirror.nju.edu.cn/git/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# 安装zsh-syntax-highlighting插件 使用南京大学的镜像
git clone https://mirror.nju.edu.cn/git/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# 如果之前是true，就把它改回去
if [ "$sslverify_old" == "true" ]; then 
    git config --global http.sslverify true
fi

# 切换到用户的根目录
cd || exit
# 修改.zshrc文件中的plugins配置
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' .zshrc

# 清理安装文件
rm -rf ~/ohmyzsh


if [[ $SHELL == *zsh* ]]; then
    echo "zsh is already the default shell."
else
    # 设置默认终端
    echo "you may need to input your password to set zsh as default shell"
    sudo chsh -s "$(which zsh)" "$(whoami)"
fi
echo "please relogin to make configration take effect"
