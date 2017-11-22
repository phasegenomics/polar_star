
sudo pip install --upgrade pip
sudo yum -y install python36

virtualenv -p python36 ~/tmp
source ~/tmp/bin/activate
pip install snakemake
