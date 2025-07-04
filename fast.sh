#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# 移除要替换的包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-netgear
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-serverchan
# rm -rf feeds/luci/applications/luci-app-netdata

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# 添加额外插件
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
git clone --depth=1 https://github.com/destan19/OpenAppFilter package/OpenAppFilter
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata
# Add package/luci-app-wizard
# git clone --depth=1 https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard

# 科学上网插件
git_sparse_clone master https://github.com/vernesong/OpenClash package/luci-app-openclash

# git clone --depth=1 -b main https://github.com/fw876/helloworld package/luci-app-ssr-plus
# git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
# git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# Add a feed source
# echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >> feeds.conf.default
echo 'src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git' >> feeds.conf.default
# echo 'src-git passwall_package https://github.com/xiaorouji/openwrt-passwall-packages' >> feeds.conf.default

# sed -i "/helloworld/d" "feeds.conf.default"
# echo "src-git helloworld https://github.com/fw876/helloworld.git" >> "feeds.conf.default"

#git_sparse_clone main https://github.com/linkease/nas-packages-luci luci/luci-app-ddnsto
#git_sparse_clone master https://github.com/linkease/nas-packages network/services/ddnsto


# iStore - 使用标准 feeds 方式，注释掉原来的 sparse clone 方式
# git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
# git_sparse_clone main https://github.com/linkease/istore luci

# 在线用户
git_sparse_clone main https://github.com/haiibo/packages luci-app-onliner
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by Oemby/g" package/lean/default-settings/files/zzz-default-settings

# 移除默认安装的vsftpd、vlmcsd
sed -i "s/luci-app-vsftpd//g" include/target.mk
sed -i "s/luci-app-vlmcsd//g" include/target.mk

# ./scripts/feeds update helloworld
# ./scripts/feeds install -a -f -p helloworld

./scripts/feeds clean

# echo >> feeds.conf.default
# luci-app-wizard - 网络配置向导 (luci-app-quickstart 的最佳替代)
git clone --depth=1 https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard


# echo 'src-git homeproxy https://github.com/VIKINGYFY/HomeProxy.git' >> feeds.conf.default

# 在现有 feeds.conf.default 末尾添加
sed -i '$a src-git homeproxy https://github.com/VIKINGYFY/HomeProxy.git' feeds.conf.default


# 添加 iStore feeds（推荐的标准方式）
# echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
# git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
# git_sparse_clone main https://github.com/linkease/istore luci-app-store

./scripts/feeds update -a
# 专门安装 iStore（确保正确安装）
# ./scripts/feeds install -d y -p istore luci-app-store
./scripts/feeds install -p homeproxy -a
./scripts/feeds install -a
