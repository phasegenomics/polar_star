sudo yum -y groupinstall "Development Tools"
sudo yum -y install emacs
sudo yum -y install git 
sudo yum -y install python36
sudo yum -y install go
sudo yum -y install zlib-devel
sudo yum -y install ncurses-devel
sudo yum -y install autoconf
sudo yum -y install bzip2-devel-1.0.6-8.12.amzn1.x86_64
sudo yum -y install xz-devel-5.1.2-12alpha.12.amzn1.x86_64

sudo yum -y install python36-devel
sudo python3.6 -m pip install --upgrade pip
sudo python3.6 -m pip install --upgrade virtualenvwrapper

virtualenv -p python36 ~/py_36_env
source ~/py_36_env/bin/activate
sudo pip-3.6 install snakemake
