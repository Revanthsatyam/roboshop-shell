log=/tmp/roboshop.log

func_apppreq() {
  echo -e "\e[35m>>>>>>>>> Create ${component} Service <<<<<<<<<<\e[0m"
  cp ${component}.service /etc/systemd/system/${component}.service &>>${log}

  echo -e "\e[35m>>>>>>>>> Create Application User <<<<<<<<<<\e[0m"
  useradd roboshop &>>${log}

  echo -e "\e[35m>>>>>>>>> Cleanup Existing Application Content <<<<<<<<<<\e[0m"
  rm -rf /app &>>${log}

  echo -e "\e[35m>>>>>>>>> Create Application Directory <<<<<<<<<<\e[0m"
  mkdir /app &>>${log}

  echo -e "\e[35m>>>>>>>>> Download Application Content <<<<<<<<<<\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}

  echo -e "\e[35m>>>>>>>>> Extract Application Content <<<<<<<<<<\e[0m"
  cd /app
  unzip /tmp/${component}.zip &>>${log}
  cd /app
}

func_systemd() {
  echo -e "\e[35m>>>>>>>>> Start ${component} Service <<<<<<<<<<\e[0m"
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  systemctl restart ${component} &>>${log}
}

func_schema_setup() {
  if [ "${schema_type}" == "mongodb" ]; then
    echo -e "\e[35m>>>>>>>>> Install Mongo Client <<<<<<<<<<\e[0m"
    yum install mongodb-org-shell -y &>>${log}

    echo -e "\e[35m>>>>>>>>> Load ${component} Schema <<<<<<<<<<\e[0m"
    mongo --host mongodb.rdevops74.online </app/schema/${component}.js &>>${log}
  fi

  if [ "${schema_type}" == "mysql" ]; then
    echo -e "\e[35m>>>>>>>>> Install MySql Client <<<<<<<<<<\e[0m"
    yum install mysql -y &>>${log}

    echo -e "\e[35m>>>>>>>>> Load Schema <<<<<<<<<<\e[0m"
    mysql -h mysql.rdevops74.online -uroot -pRoboShop@1 < /app/schema/${component}.sql &>>${log}
  fi
}

func_nodejs() {
  log=/tmp/roboshop.log

  echo -e "\e[35m>>>>>>>>> Create MongoDB Repo <<<<<<<<<<\e[0m"
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}

  echo -e "\e[35m>>>>>>>>> Install NodeJS Repos <<<<<<<<<<\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}

  echo -e "\e[35m>>>>>>>>> Install NodeJS <<<<<<<<<<\e[0m"
  yum install nodejs -y &>>${log}

  func_apppreq

  echo -e "\e[35m>>>>>>>>> Download NodeJS Dependencies <<<<<<<<<<\e[0m"
  npm install &>>${log}

  func_schema_setup

  func_systemd
}

func_java() {
  echo -e "\e[35m>>>>>>>>> Install Maven <<<<<<<<<<\e[0m"
  yum install maven -y &>>${log}

  func_apppreq

  echo -e "\e[35m>>>>>>>>> Build ${component} Service <<<<<<<<<<\e[0m"
  mvn clean package &>>${log}
  mv target/${component}-1.0.jar ${component}.jar &>>${log}

  func_schema_setup

  func_systemd
}

func_python() {
  echo -e "\e[35m>>>>>>>>> Build ${component} Service <<<<<<<<<<\e[0m"
  yum install python36 gcc python3-devel -y &>>${log}

  func_apppreq

  echo -e "\e[35m>>>>>>>>> Build ${component} Service <<<<<<<<<<\e[0m"
  pip3.6 install -r requirements.txt &>>${log}

  func_systemd
}

func_golang() {
  echo -e "\e[35m>>>>>>>>> Install Golang <<<<<<<<<<\e[0m"
  yum install golang -y &>>${log}

  func_apppreq

  echo -e "\e[35m>>>>>>>>> Build Golang <<<<<<<<<<\e[0m"
  go mod init dispatch &>>${log}
  go get &>>${log}
  go build &>>${log}

  func_systemd
}