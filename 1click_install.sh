#!/bin/bash
set -e
package1="git"
package2="zsh"

function ubuntu_config() {
    # 使用dpkg -s来检查软件包是否已经安装
    dpkg -s $package1 &> /dev/null

    if [ $? -eq 0 ]; then
        echo "$package1 is installed."
    else
        echo "input your password to install dependent packages"
        # 1. 安装git
        sudo apt install git -y
    fi

    dpkg -s $package2 &> /dev/null

    if [ $? -eq 0 ]; then
        echo "$package2 is installed."
    else
        # 2. 安装zsh
        sudo apt install zsh -y
    fi
}

function centos_config() {

    # 这段代码的工作原理是尝试运行git命令。如果git命令不存在，那么command -v git将返回一个非零的退出状态，
    # if语句就会执行then后面的代码块。
    if ! command -v git &> /dev/null
    then
        echo "input your password to install dependent packages"
        # 1. 安装git
        sudo yum install git -y
    else
        echo "$package1 is installed."
    fi


    # 判断zsh是否已经安装
    if which zsh >/dev/null; then
        echo "Zsh is installed."
    else
        # 2. 安装zsh
        echo "input your password to install dependent packages"
        sudo yum install zsh -y
    fi
}

function mac_config() {
    # 使用brew list来检查软件包是否已经安装
    brew list $package1 &> /dev/null

    if [ $? -eq 0 ]; then
        echo "$package1 is installed."
    else
        echo "input your password to install dependent packages"
        # 1. 安装git
        brew install git
    fi

    # 判断zsh是否已经安装
    if which zsh >/dev/null; then
        echo "Zsh is installed."
    else
        # 2. 安装zsh
        brew install zsh
    fi

}

# 使用uname -s获取操作系统名称
os_name=$(uname -s)

if [ "$os_name" == "Darwin" ]; then
    echo "Mac Configuration."
    mac_config
elif [ "$os_name" == "Linux" ]; then
    # 使用lsb_release -a命令获取发行版的名称
    os_info=$(lsb_release -a 2>/dev/null | grep "Distributor ID:" | cut -d ":" -f2)

    if [[ "$os_info" == *"Ubuntu"* ]] || [[ "$os_info" == *"Debian"* ]]; then
        ubuntu_config
    elif [[ "$os_info" == *"CentOS"* ]] || [[ "$os_info" == *"Red Hat"* ]]; then
        centos_config
    else
        echo "This is not Ubuntu, Debian, CentOS, or Red Hat. Exiting"
        exit
    fi
        
else
    echo "This is not a Mac or Linux. Exiting"
    exit
fi



# 进入用户目录
cd

# 下载oh-my-zsh安装脚本
git clone https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git

# 执行oh-my-zsh安装脚本
cd ohmyzsh/tools
REMOTE=https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git sh install.sh <<EOF
Y
EOF
# 这里是为了跳过安装过程中的输入提示，直接输入Y


# 安装zsh-autosuggestions插件， 使用南京大学的镜像
git clone https://mirror.nju.edu.cn/git/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 安装zsh-syntax-highlighting插件 使用南京大学的镜像
git clone https://mirror.nju.edu.cn/git/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 切换到用户的根目录
cd
# 修改.zshrc文件中的plugins配置
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' .zshrc

# 设置默认终端
echo "input your password to set zsh as default shell"
chsh -s $(which zsh)

echo "please relogin to make configration take effect"
