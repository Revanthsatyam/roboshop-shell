log=/tmp/roboshop.log

func_nodejs() {  
  echo -e "\e[36m>>>>>>>>> Create ${component} Service <<<<<<<<<<\e[0m"
  cp ${component}.service /etc/systemd/system/${component}.service &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Create MongoDB Repo <<<<<<<<<<\e[0m"
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Install NodeJS Repos <<<<<<<<<<\e[0m"
  curl -sL https://rpm.noderesource.com/setup_lts.x | bash &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Install NodeJS <<<<<<<<<<\e[0m"
  dnf install nodejs -y &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Create Application User <<<<<<<<<<\e[0m"
  useradd roboshop &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Removing Application Directory <<<<<<<<<<\e[0m"
  rm -rf /app &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Create Application Directory <<<<<<<<<<\e[0m"
  mkdir /app &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Download Application Content <<<<<<<<<<\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Extract Application Content <<<<<<<<<<\e[0m"
  cd /app
  unzip /tmp/${component}.zip &>>${log}
  cd /app
  
  echo -e "\e[36m>>>>>>>>> Download NodeJS Dependencies <<<<<<<<<<\e[0m"
  npm install &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Install Mongo Client <<<<<<<<<<\e[0m"
  dnf install mongodb-org-shell -y &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Load ${component} Schema <<<<<<<<<<\e[0m"
  mongo --host mongodb.rdevops74.online </app/schema/${component}.js &>>${log}
  
  echo -e "\e[36m>>>>>>>>> Start ${component} Service <<<<<<<<<<\e[0m"
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  systemctl restart ${component} &>>${log}
}