# pku_auto_connect
Auto connect pku gateway, and send the ip address to you by Email.

If the connection is established, then check the ip address.

if not established, then use program "connect" connect the internet, then check the ip address.

If the ip address is different from the previous one(stored in file named "ip_address"),
an Email containing the current ip address will be sended to you malibox.
Then you can just establish ssh link by the ip address.
# modify user account
in auto_connect.sh, set following varibles:

脚本绝对路径,

script_path=/xxx/xxx

PKU 账号和密码,

pku_id=xxxxxxxxxxx

pku_pw=xxxxxxxxxxx

收件人邮箱

export email_reciver=reciver@pku.edu.cn

发送者邮箱

export email_sender=notices@sina.cn

邮箱密码

export email_password=xxxxxxx

使用外部邮箱进行发送需要注意：首先需要开启：POP3/SMTP服务

smtp服务器地址

export email_smtphost=smtp.sina.cn

# Add to crond service
 so you have to add "0 * * * * /bin/bash path_to_this_script" by the command "crontab -e".
 Then the scrip will be called every hour.

# Add to start up service
vim /etc/rc.local, add /bin/bash path_to_this_script to the file.
