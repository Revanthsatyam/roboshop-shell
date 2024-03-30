log=/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>> Create Catalogue Service <<<<<<<<<<\e[0m" | tee -a &>>${log}
cp catalogue.service /etc/systemd/system/catalogue.service &>>${log}

echo -e "\e[36m>>>>>>>>> Create MongoDB Repo <<<<<<<<<<\e[0m" | tee -a &>>${log}
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}

echo -e "\e[36m>>>>>>>>> Install NodeJS Repos <<<<<<<<<<\e[0m" | tee -a &>>${log}
curl -sL https://rpm.noderesource.com/setup_lts.x | bash &>>${log}

echo -e "\e[36m>>>>>>>>> Install NodeJS <<<<<<<<<<\e[0m" | tee -a &>>${log}
dnf install nodejs -y &>>${log}

echo -e "\e[36m>>>>>>>>> Create Application User <<<<<<<<<<\e[0m" | tee -a &>>${log}
useradd roboshop &>>${log}

echo -e "\e[36m>>>>>>>>> Removing Application Directory <<<<<<<<<<\e[0m" | tee -a &>>${log}
rm -rf /app &>>${log}

echo -e "\e[36m>>>>>>>>> Create Application Directory <<<<<<<<<<\e[0m" | tee -a &>>${log}
mkdir /app &>>${log}

echo -e "\e[36m>>>>>>>>> Download Application Content <<<<<<<<<<\e[0m" | tee -a &>>${log}
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${log}

echo -e "\e[36m>>>>>>>>> Extract Application Content <<<<<<<<<<\e[0m" | tee -a &>>${log}
cd /app
unzip /tmp/catalogue.zip &>>${log}
cd /app

echo -e "\e[36m>>>>>>>>> Download NodeJS Dependencies <<<<<<<<<<\e[0m" | tee -a &>>${log}
npm install &>>${log}

echo -e "\e[36m>>>>>>>>> Install Mongo Client <<<<<<<<<<\e[0m" | tee -a &>>${log}
dnf install mongodb-org-shell -y &>>${log}

echo -e "\e[36m>>>>>>>>> Load Catalogue Schema <<<<<<<<<<\e[0m" | tee -a &>>${log}
mongo --host mongodb.rdevops74.online </app/schema/catalogue.js &>>${log}

echo -e "\e[36m>>>>>>>>> Start Catalogue Service <<<<<<<<<<\e[0m" | tee -a &>>${log}
systemctl daemon-reload &>>${log}
systemctl enable catalogue &>>${log}
systemctl restart catalogue &>>${log}