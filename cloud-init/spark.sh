#!/bin/sh
local_user=opc

#java


#spark
cd /opt
sudo wget https://apache.mivzakim.net/spark/spark-3.0.2/spark-3.0.2-bin-hadoop2.7.tgz
sudo tar -xvzf spark-3.0.2-bin-hadoop2.7.tgz
sudo mv /opt/spark-3.0.2-bin-hadoop2.7/ /opt/spark/
sudo rm /opt/spark-3.0.2-bin-hadoop2.7.tgz

sudo echo "export SPARK_HOME=/opt/spark" >> /home/$local_user/.bashrc
sudo echo "export PATH=\$SPARK_HOME/bin:\$PATH" >> /home/$local_user/.bashrc
sudo echo "export PYSPARK_PYTHON=/usr/bin/python3" >> /home/$local_user/.bashrc

#python
sudo yum install -y oracle-epel-release-el7 oracle-release-el7
sudo yum install -y python3

#jupiter
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install pyspark
sudo python3 -m pip install jupyter


echo "export PYSPARK_DRIVER_PYTHON=jupyter" >> /home/$local_user/.bashrc
echo "export PYSPARK_DRIVER_PYTHON_OPTS='notebook'" >> /home/$local_user/.bashrc



#public access
jupyter notebook --generate-config
sudo mv ~/.jupyter/jupyter_notebook_config.py /home/$local_user/.jupyter/jupyter_notebook_config.py
sed -i "s/#c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '*'/" /home/$local_user/.jupyter/jupyter_notebook_config.py

sudo firewall-cmd --permanent --zone=public --add-port=8888-8889/tcp
sudo firewall-cmd --permanent --zone=public --add-port=49152-65535/tcp
sudo systemctl enable  firewalld
sudo systemctl restart  firewalld


