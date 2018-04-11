#########################################################################
# File Name: check_connect_send.sh
# Author: Baoming Yan
# mail: bmyan.phy@gmail.com
# Created Time: Tue 09 Jan 2018 09:31:25 PM CST
#########################################################################
#!/bin/bash
# This script is used to check the internet connection.
# If the connection is established, then check the ip address. 
# if not established, then use program "connect" connect the internet, then check the ip address.
# If the ip address is different from the previous one(stored in file named "ip_address"), 
# an Email containting the current ip address will be sended to you malibox.
# Then you can just establish ssh link by the ip address. 
# The script is called by crond service,
# so you have to add "0 * * * * /bin/bash path_to_this_script" by the command "crontab -e". 
# Then the scrip will be called every hour.

# 参数的设置
# 脚本路径位置
script_path=/home/bmyan/tools/pku_auto_connect
# PKU 账号和密码
pku_id=xxxxxxxxxxx
pku_pw=xxxxxxxxxxx
#收件人邮箱
export email_reciver=reciver@pku.edu.cn  
#发送者邮箱  
export email_sender=notices@sina.cn
#邮箱用户名  
export email_username=notices
#邮箱密码  
#使用外部邮箱进行发送需要注意：首先需要开启：POP3/SMTP服务  
export email_password=xxxxxxx
#export file1_path="附件一路径"  
#export file2_path="附件二路径"  
#smtp服务器地址  
export email_smtphost=smtp.sina.cn  
export email_title="IP address"  
#IP 前缀
export ip_pattern="162.105"

# function for sending email. "sudo apt-get install sendemail" is required.
# the username, password, reciver's mail should be filled in the function.
function send_ip()
{
email_content=`/sbin/ifconfig|grep "${ip_pattern}"|head -n 1| cut -d ':' -f 2 | cut -d ' ' -f 1`
sendemail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost}\
	-u ${email_title} -xu ${email_username} -xp ${email_password}\
	-m ${email_content} -o message-charset=utf-8
exit 0
}

# perform the checking and connect process
# previos IP address will be stored in file name "ip_address"

for web in http://www.baidu.com http://www.sina.com.cn
do
	echo "visiting ${web}"
	curl --connect-timeout 5 ${web} > /dev/null 2>&1
	if [ $? == 0 ]; then
		echo "link established."
		ip=`/sbin/ifconfig|grep "${ip_pattern}"|head -n 1| cut -d ':' -f 2 | cut -d ' ' -f 1`
		last_ip=$(cat ${script_path}"/ip_address")
		if [ "$last_ip" != "$ip" ]; then
			echo "ip changed from ${last_ip} to ${ip}"
			echo ${ip} > ${script_path}"/ip_address" 
			send_ip
			echo "send mail"
		fi
	else
		echo "link lost, try reconnecting..."
		${script_path}"/connect" -u ${pku_id} -p ${pku_pw} -c > /dev/null 2>&1
		ip=`${script_path}"/connect" -u ${pku_id} -p ${pku_pw} -g | cut -d ';' -f 2|cut -d ' ' -f 3`
		echo "connected!"
		echo "current ip: $ip"
		last_ip=$(cat ${script_path}"/ip_address")
		if [ "$last_ip" != "$ip" ]; then
			echo "ip changed from ${last_ip} to ${ip}"
			echo ${ip} > ${script_path}"/ip_address"
			send_ip
			echo "send mail"
		fi
	fi
done
