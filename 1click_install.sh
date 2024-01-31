#!/bin/bash
set -e





function ubuntu_config() {
    if ! command -v git &> /dev/null
    then
        # 1. 安装git
        sudo apt install git -y
    else
        echo "git is installed."
    fi

    if grep -q "/bin/zsh" /etc/shells; then
        echo "zsh is installed."
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
        # 1. 安装git
        sudo yum install git-core -y
    else
        echo "git is installed."
    fi

    # 判断zsh是否已经安装
    if grep -q "/bin/zsh" /etc/shells; then
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
    if grep -q "/bin/zsh" /etc/shells; then
        echo "zsh is installed."
    else
        # 2. 安装zsh
        brew install zsh
    fi

}


echo "you may need to input your password to install some dependent packages(git zsh)"

# 使用uname -s获取操作系统名称
os_name=$(uname -s)

if [ "$os_name" == "Darwin" ]; then
    echo "Mac Configuration."
    mac_config
elif [ "$os_name" == "Linux" ]; then
    # 这段代码的工作原理是尝试运行git命令。如果git命令不存在，那么command -v git将返回一个非零的退出状态，
    # if语句就会执行then后面的代码块。
    if ! command -v lsb_release -a &> /dev/null
    then
        echo "lsb_release is not working. Please install lsb_release first.Exiting"
        exit
    fi

    # 使用lsb_release -a命令获取发行版的名称
    os_info=$(lsb_release -a 2>/dev/null | grep "Distributor ID:" | cut -d ":" -f2)

    if [[ "$os_info" == *"Ubuntu"* ]] || [[ "$os_info" == *"Debian"* ]]; then
        ubuntu_config
    elif [[ "$os_info" == *"CentOS"* ]] || [[ "$os_info" == *"Red Hat"* ]]; then
        centos_config
    else
        echo "Your os is not Ubuntu, Debian, CentOS, or Red Hat. If you installed git and zsh, you can continue."
        read -p "continue? (y or n)" choice
        if [ "$choice" == "y" ] || [ "$choice" == "yes" ]; then
            echo "continue"
        else
            echo "exiting"
            exit
    fi
        
else
    echo "This is not a Mac or Linux. Exiting"
    exit
fi



# 进入用户目录
cd

# Git 可能无法验证清华镜像服务器的 SSL 证书。
# 这并不意味着证书有问题，但可能是自签名的，或者由一个不在您的操作系统的 CA 列表中的机构/公司签名的。
if  ! command -v sslverify=$(git config --global --get http.sslverify) 
    then
        if [ -z "$sslverify" ]; then
            # 将其设置为false
            git config --global http.sslverify false
        else
            if [ "$sslverify" == "true" ]; then
            # 先关掉这个验证
            git config --global http.sslverify false
            fi
        fi
    fi
sslverify=$(git config --global --get http.sslverify)


sslverify_state=$sslverify



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

# 如果之前是true，就把它改回去
if [ "$sslverify" == "true" ]; then 
    git config --global http.sslverify true
fi

# 切换到用户的根目录
cd
# 修改.zshrc文件中的plugins配置
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' .zshrc

# 清理安装文件
rm -rf ~/ohmyzsh

# 设置默认终端
echo "input your password to set zsh as default shell"
sudo chsh -s $(which zsh) $(whoami)

echo "please relogin to make configration take effect"
