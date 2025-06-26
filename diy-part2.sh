#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.11.1/g' package/base-files/luci2/bin/config_generate

# iStore - 使用标准 feeds 方式，注释掉原来的 sparse clone 方式
# git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
# git_sparse_clone main https://github.com/linkease/istore luci

# ./scripts/feeds install -d y -p istore luci-app-store