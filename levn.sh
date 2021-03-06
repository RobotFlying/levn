#############################################################################################
#
#   This script is used to initialize my linux work environment automately. All the setting
# is just for my need.
#
#   Version:    1.0
#   Author:     BurnedRobot
#   Email:      robotflying777@gmail.com
#   Copyright:  BurnedRobot
#
#   History:
#   2013/06/03  BurnedRobot  First release
#   2013/06/15  BurnedRobot  Use 'expect' tool to implement AUTOINSTALLation
#   2013/07/12  BurnedRobot  Add wget,git,goagent,curl
#   2013/07/14  BurnedRobot  Use functions to simplify this code
#   2013/08/05  BurnedRobot  Add update sources and google_chrome installation
#                            Add goagent, chromium
#   2013/10/04  BurnedRobot  Add whether to change software sources or not
#                            Fix bugs in install_goagent
#   2014/01/16  BurnedRobot  Add hlsearch in .vimrc                         #&1(A:Add,C:Change, D:Delete, M:Move)
#   2014/02/05  BurnedRobot  move all the .vimrc setting into vimrc file.   #&2(A:Add,C:Change, D:Delete, M:Move)
#   2014/02/07  BurnedRobot  Add install_emacs                              #&3(A:Add,C:Change, D:Delete, M:Move)
#
#############################################################################################

#! /bin/bash

#Check the release virsion of linux
function check_version()
{
    if  cat /proc/version | grep -q "Red Hat" ; then echo System is Red Hat!
        INSTALL='yum install'
        SYSTEM='Red Hat'
    elif cat /proc/version | grep -q "Ubuntu" ; then
        echo System is Ubuntu!
        INSTALL='apt-get install'
        SYSTEM='Ubuntu'
    fi
}


#update software sources
function update_sources()
{
    echo "Here will begin update software sources!"
    echo "Please input software sources[163 or sohu or bit]"
    read SOURCE

    if [ "$SYSTEM" == 'Ubuntu' ];
        then ./update_ubuntu_sources.sh $SOURCE
    elif [ "$SYSTEM" == 'Red Hat' ];
        then ./update_red_hat_sources.sh $SOURCE
    fi

}


#function common_installation
#mostly app can be installed by this function
function common_installation()
{
    #Here installs $1
    echo Here are installing $1
    $AUTOINSTALL $1 $PASSWD
    echo
}


#Here installs expect
function install_expect()
{
    echo Here are installing expect...
    sudo $INSTALL expect
    echo
}


##################################################################################################################################################
function init()
{
    check_version

    AUTOINSTALL="./auto_install.sh"

    echo '#! /usr/bin/expect' > $AUTOINSTALL
    echo "spawn sudo $INSTALL " '[lindex $argv 0]' >> $AUTOINSTALL
    echo 'expect "password"' >> $AUTOINSTALL
    echo 'send "[lindex $argv 1]\r"' >> $AUTOINSTALL
    echo 'expect -re "\[./.\]"' >> $AUTOINSTALL
    echo 'send "y\r"' >> $AUTOINSTALL
    echo 'interact' >> $AUTOINSTALL
    chmod +x $AUTOINSTALL

    echo "If you want to update sources[y/N]?"
    read SOURCE_CHECK

    if [ "$SOURCE_CHECK" == 'y' ] || [ "$SOURCE_CHECK" == 'Y' ];
        then update_sources
    elif [ "$SOURCE_CHECK" == 'n' ] || [ "$SOURCE_CHECK" == 'N' ];
        then echo "Software sources dosen\`t change!"
    else
        echo "Input Error!"
        echo "Exit!"
        exit
    fi

    #store the password
    echo "Installation will begin!"
    install_expect
    echo -e "Please input password again:"
    stty -echo
    read PASSWD


}


function clean
{
    #make a clean
    rm $AUTOINSTALL
    clear
    echo Installation Complete!
    stty echo
}


##################################################################################################################################################
#Here installs my favourite editor - vim editor
function install_vim()
{
    $AUTOINSTALL vim $PASSWD
                                                                                                             #&2D
    cp ./vimrc ~/.vimrc                                                                                      #&2A

    install_vundle

    tar -xf tags.tar

    rm -rf ~/.vim/tags

    mv ./tags ~/.vim/
}


#Here installs vim plugin manager - vundle                                                                   #&1A
function install_vundle()                                                                                    #&1A
{                                                                                                            #&1A
    git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle                                      #&1A
                                                                                                             #&2D
                                                                                                             #&2D
    vim +BundleInstall +qall                                                                                 #&1A
                                                                                                             #&1A
}                                                                                                            #&1A


#Here installs openssh
function install_ssh()
{
    echo Here are intalling ssh...
    if [ "$SYSTEM" == 'Red Hat' ];
        then $AUTOINSTALL openssh $PASSWD
    elif [ "$SYSTEM" == 'Ubuntu' ];
        then $AUTOINSTALL openssh-server $PASSWD
    fi
    echo
}


#Here installs g++
function install_gplusplus()
{
    echo Here are intalling g++...
    if [ "$SYSTEM" == 'Red Hat' ];
        then $AUTOINSTALL gcc-c++ $PASSWD
    elif [ "$SYSTEM" == 'Ubuntu' ];
        then $AUTOINSTALL g++ $PASSWD
    fi
    echo
}


#Here installs unrar
function install_unrar()
{
    echo Here are intalling unrar...
    if [ "$SYSTEM" == 'Red Hat' ];
        then sudo rpm -Uvh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-stable.noarch.rpm
         sudo rpm -Uvh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-stable.noarch.rpm 
        $AUTOINSTALL unrar $PASSWD
    elif [ "$SYSTEM" == 'Ubuntu' ];
        then $AUTOINSTALL unrar $PASSWD
    fi
    echo
}


##################################################################################################################################################
#Here installs google-chrome
function install_google_chrome()
{
    echo Here are installing google-chrome...
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    $AUTOINSTALL google-chrome-stable $PASSWD
}


#Here installs chromium
function install_chromium
{
    echo Here are installing chromium...

    if [ "$SYSTEM" == 'Red Hat' ];
        then sudo yum-config-manager --add-repo=http://repos.fedorapeople.org/repos/spot/chromium-stable/fedora-chromium-stable.repo
        sudo yum install chromium -y
    elif [ "$SYSTEM" == 'Ubuntu' ];
        then $AUTOINSTALL chromium-browser $PASSWD
    fi

}


##################################################################################################################################################
#We use this function to judge whether the ~/Desktop directory exist or not
function judge_desktop()
{
    if [ -d ~/Desktop ] ;
        then echo Desktop exist!
    else
        echo ~/Desktop dosen\`t exist.
        echo We create it.
        cd ~
        mkdir Desktop
    fi
}


#Here installs goagent
function install_goagent()
{
    if [ "$SYSTEM" == 'Ubuntu' ];
        then $AUTOINSTALL python-dev $PASSWD
        $AUTOINSTALL libssl-dev $PASSWD
    elif [ "$SYSTEM" == 'Red Hat' ];
        then $AUTOINSTALL python-devel $PASSWD
        $AUTOINSTALL openssl-devel $PASSWD
    fi

    NOW_DIR=$PWD

    # install gevent
    curl -L -O https://github.com/python-greenlet/greenlet/archive/0.4.0.tar.gz && tar xvzpf 0.4.0.tar.gz && cd greenlet-0.4.0 && sudo python setup.py install

    curl -L -O https://github.com/downloads/surfly/gevent/gevent-1.0rc2.tar.gz && tar xvzpf gevent-1.0rc2.tar.gz && cd gevent-1.0rc2 && sudo python setup.py install

    #install openssl
    wget http://www.openssl.org/source/openssl-1.0.1c.tar.gz
    tar zxvf openssl-1.0.1c.tar.gz
    cd openssl-1.0.1c
#设定Openssl 安装，( --prefix )参数为欲安装之目录，也就是安装后的档案会出现在该目录下
    ./config --prefix=/root/openssl
    make && make install

    #install pyopenssl
    wget http://pypi.python.org/packages/source/p/pyOpenSSL/pyOpenSSL-0.13.tar.gz && tar zxvf pyOpenSSL-0.13.tar.gz && cd pyOpenSSL-0.13 && sudo python setup.py install

    judge_desktop

    cd ~/Desktop
    git clone https://github.com/goagent/goagent.git

    cd $NOW_DIR
    sudo rm  -f 0.4.0.tar.gz gevent-1.0rc2.tar.gz -r gevent-1.0rc2 -r greenlet-0.4.0
    sudo rm -f openssl-1.0.1c.tar.gz pyOpenSSL-0.13.tar.gz -r openssl-1.0.1c -r pyOpenSSL-0.13
}


#Here install emacs editor
function install_emacs()                                                                                     #&3A
{                                                                                                            #&3A
    $AUTOINSTALL emacs24 $PASSWD                                                                             #&3A
    $AUTOINSTALL clang-3.4 $PASSWD                                                                           #&3A
    rm -rf ~/.emacs.d                                                                                        #&3A
    git clone https://github.com/redguardtoo/emacs.d.git                                                     #&3A
    mv emacs.d ~/.emacs.d                                                                                    #&3A
    http_proxy=http://127.0.0.1:8087 emacs -nw --batch -l ~/.emacs.d/init.el -f package-refresh-contents     #&3A
    cp bashrc ~/.bashrc                                                                                      #&3A
                                                                                                             #&3A
}                                                                                                            #&3A
##################################################################################################################################################
#main function
function main()
{

    init

    #common_installation array
    #common_array=( "wget" "guake" "ctags" "git" "gcc" "curl" "mysql-server" "cmake" )
    common_array=( "wget" "guake" "ctags" "git" "gcc" "curl" "cmake" )
    common_array_len=${#common_array[@]}

    install_vim
    install_ssh
    install_gplusplus
    install_unrar

    #Here installs wget,guake,ctags,git,gcc,curl,mysql,unrar,g++,cmake
    index=0
    while [ $common_array_len -ne $index ]
    do
        common_installation ${common_array[$index]}
        index=` expr $index + 1`
    done

    #Here installs google-chrome
    #install_google_chrome
    #install_chromium
   
    #Here installs goagent
    #install_goagent

    #Here installs emacs
    install_emacs

    clean
}


function this_test()
{
    init
    #install_goagent
    #install_vim
    install_emacs
    clean
}


##################################################################################################################################################
main
#this_test
