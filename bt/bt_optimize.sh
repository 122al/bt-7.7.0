#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

echo "
+----------------------------------------------------------------------
| Bt-Panel Optimize
+----------------------------------------------------------------------
| 本脚本用于宝塔面板7.7版本的一键开心，因为脚本造成的问题请自行负责！
+----------------------------------------------------------------------
| 本脚本功能：
|		1.去除强制登陆
|		2.解锁所有付费插件
|		3.设置文件防修改（防止宝塔自动修复）
|		4.去除消息推送与文件校验
|		5.去除各种计算题与延时等待
|		6.去除创建网站自动创建的垃圾文件
|		7.关闭未绑定域名提示页面
|		8.关闭安全入口登录提示页面
|		9关闭活动推荐与在线客服
+----------------------------------------------------------------------
| 安装脚本：curl -sSO https://cdn.jsdelivr.net/gh/122al/bt-7.7.0@latest/install/install_panel.sh && bash install_panel.sh
+----------------------------------------------------------------------
"
while [ "$go" != 'y' ] && [ "$go" != 'n' ]
do
	read -p "请确认你已经安装的版本是7.7，请确认你将开心的宝塔面板用于学习！(y/n): " go;
done

if [ "$go" == 'n' ];then
	exit;
fi

if [ $(whoami) != "root" ];then
	echo "请使用root权限执行命令！"
	exit 1;
fi
if [ ! -d /www/server/panel ] || [ ! -f /etc/init.d/bt ];then
	echo "未安装宝塔面板"
	exit 1
fi 

echo -e "去除强制登陆..."
if [ ! -f /www/server/panel/data/userInfo.json ]; then
	echo "{\"uid\":1000,\"username\":\"admin\",\"serverid\":1}" > /www/server/panel/data/userInfo.json
	sed -i "s|if (bind_user == 'True') {|if (bind_user == 'REMOVED') {|g" /www/server/panel/BTPanel/static/js/index.js
	rm -rf /www/server/panel/data/bind.pl
fi
echo "去除宝塔面板强制绑定账号已完成."
sleep 2


echo -e "解锁所有付费插件..."
#判断plugin.json文件是否存在,存在删除之后再下载,不存在直接下载
plugin_file="/www/server/panel/data/plugin.json"
if [ -f ${plugin_file} ];then
    chattr -i /www/server/panel/data/plugin.json
    rm /www/server/panel/data/plugin.json
    cd /www/server/panel/data
    wget https://raw.githubusercontent.com/122al/bt-7.7.0/main/bt/plugin.json
    chattr +i /www/server/panel/data/plugin.json
else
    cd /www/server/panel/data
    wget https://raw.githubusercontent.com/122al/bt-7.7.0/main/bt/plugin.json
    chattr +i /www/server/panel/data/plugin.json
fi
echo -e "解锁所有付费插件已完成"


echo -e "设置文件防修改..."
#判断repair.json文件是否存在,存在删除之后再下载,不存在直接下载
repair_file="/www/server/panel/data/repair.json"
if [ -f ${repair_file} ];then
    chattr -i /www/server/panel/data/repair.json
    rm /www/server/panel/data/repair.json
    cd /www/server/panel/data
    wget https://raw.githubusercontent.com/122al/bt-7.7.0/main/bt/repair.json
    chattr +i /www/server/panel/data/repair.json
else
    cd /www/server/panel/data
    wget https://raw.githubusercontent.com/122al/bt-7.7.0/main/bt/repair.json
    chattr +i /www/server/panel/data/repair.json
fi
echo -e "设置文件防修改已完成."

echo -e "去除消息推送与文件校验..."
sed -i "/p = threading.Thread(target=check_files_panel)/, /p.start()/d" /www/server/panel/task.py
sed -i "/p = threading.Thread(target=check_panel_msg)/, /p.start()/d" /www/server/panel/task.py
echo -e "去除消息推送与文件校验已完成."


echo -e "去除各种计算题与延时等待..."
Layout_file="/www/server/panel/BTPanel/templates/default/layout.html";
JS_file="/www/server/panel/BTPanel/static/bt.js";
if [ `grep -c "<script src=\"/static/bt.js\"></script>" $Layout_file` -eq '0' ];then
	sed -i '/{% block scripts %} {% endblock %}/a <script src="/static/bt.js"></script>' $Layout_file;
fi;
wget -q https://raw.githubusercontent.com/122al/bt-7.7.0/main/bt/bt.js -O $JS_file;
echo  -e "去除各种计算题与延时等待已完成."

echo -e "去除创建网站自动创建的垃圾文件..."
sed -i "/htaccess = self.sitePath+'\/.htaccess'/, /public.ExecShell('chown -R www:www ' + htaccess)/d" /www/server/panel/class/panelSite.py
sed -i "/index = self.sitePath+'\/index.html'/, /public.ExecShell('chown -R www:www ' + index)/d" /www/server/panel/class/panelSite.py
sed -i "/doc404 = self.sitePath+'\/404.html'/, /public.ExecShell('chown -R www:www ' + doc404)/d" /www/server/panel/class/panelSite.py
echo -e "去除创建网站自动创建的垃圾文件已完成."

echo -e "关闭未绑定域名提示页面..."
sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/class/panelSite.py
if [ -f /www/server/panel/vhost/nginx/0.default.conf ]; then
	sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/vhost/nginx/0.default.conf
fi
echo -e "关闭未绑定域名提示页面已完成."

echo -e "关闭安全入口登录提示页面..."
sed -i "s/return render_template('autherr.html')/return abort(404)/" /www/server/panel/BTPanel/__init__.py
echo -e "关闭安全入口登录提示页面已完成."

echo -e "关闭活动推荐与在线客服..."
if [ ! -f /www/server/panel/data/not_recommend.pl ]; then
	echo "True" > /www/server/panel/data/not_recommend.pl
fi
if [ ! -f /www/server/panel/data/not_workorder.pl ]; then
	echo "True" > /www/server/panel/data/not_workorder.pl
fi
echo -e "关闭活动推荐与在线客服已完成."

/etc/init.d/bt restart

echo -e "=================================================================="
echo -e "\033[32m宝塔面板优化脚本执行完毕\033[0m"
echo -e "=================================================================="
echo  "适用宝塔面板版本：7.7"
echo  "如需还原之前的样子，请在面板首页点击“修复”"
echo -e "=================================================================="

