#!/usr/bin/python
# -*- coding: utf-8 -*-
### BEGIN LICENSE

# Copyright (C) 2013 ~ 2014 National University of Defense Technology(NUDT) & Kylin Ltd
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranties of
# MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program.  If not, see <http://www.gnu.org/licenses/>.
### END LICENSE

import apt
import aptsources.sourceslist
import apt.progress.base as apb
#import threading

class FetchProcess(apb.AcquireProgress):
    '''Fetch Process'''
    def __init__(self, sudoDaemon):
        apb.AcquireProgress.__init__(self)
        self.sudoDaemon = sudoDaemon

    def done(self, item):
        print 'all items download finished'
        self.sudoDaemon.software_fetch_signal("down_done", "")

    def fail(self, item):
        print 'download failed'
        self.sudoDaemon.software_fetch_signal("down_fail", "")

    def fetch(self, item):
        print 'one item download finished'
        self.sudoDaemon.software_fetch_signal("down_fetch", "")

    def ims_hit(self, item):
        print 'ims_hit'

    def media_change(self, media, drive):
        print 'media_change'

    def pulse(self, owner):
# 		print 'owner: ', owner
# 		print '############bytes : ', self.current_bytes
# 		print '@@@@@@@@@@@@total : ', self.total_bytes
# 		print '%%%%%%%%%%%%item : ', self.current_items
# 		print '$$$$$$$$$$$$items : ', self.total_items 
# 		print 'current_cps: ', self.current_cps
# 		print 'elapsed_time: ', self.elapsed_time
# 		print 'fetched_bytes: ', self.fetched_bytes
# 		print 'last_bytes: ', self.last_bytes
        self.sudoDaemon.software_fetch_signal("down_pulse","download_bytes:" + str(self.current_bytes) + ",total_bytes:" + str(self.total_bytes) + ",download_items:" + str(self.current_items) + ",total_items:" + str(self.total_items))

    def start(self):
        # Reset all our values.
        self.current_bytes = 0.0
        self.current_cps = 0.0
        self.current_items = 0
        self.elapsed_time = 0
        self.fetched_bytes = 0.0
        self.last_bytes = 0.0
        self.total_bytes = 0.0
        self.total_items = 0
        print 'fetch progress start ...'
        self.sudoDaemon.software_fetch_signal("down_start", "")

    def stop(self):
        print 'fetch progress stop ...'
        self.sudoDaemon.software_fetch_signal("down_stop", "")


class AptProcess(apb.InstallProgress):
    '''Apt progress'''
    def __init__(self, sudoDaemon):
        apb.InstallProgress.__init__(self)
        self.sudoDaemon = sudoDaemon

    def conffile(self, current, new):
        print 'there is a conffile question'

    def error(self, pkg, errormsg):
        self.sudoDaemon.software_apt_signal("apt_error", "")

    def start_update(self):
        print 'apt process start work'
        self.sudoDaemon.software_apt_signal("apt_start", "")

    def finish_update(self):
        print 'apt process finished'
        self.sudoDaemon.software_apt_signal("apt_stop", "")

    def status_change(self, pkg, percent, status):
        print str(int(percent)) + "%  status : " + status
        self.sudoDaemon.software_apt_signal("apt_pulse", "percent:" + str(int(percent)) + ",status:" + status)

#class AptDaemon(threading.Thread):
class AptDaemon():
    def __init__(self, sudoDaemon):
        #threading.Thread.__init__(self)
        #self.setDaemon(True)
        self.sudoDaemon = sudoDaemon
        self.ca = apt.Cache()
        self.ca.open()
# 		self.pkgNameList = []
# 		for pkg in self.ca:
# 			self.pkgNameList.append(pkg.name)

    # apt-get update
    def apt_get_update(self):
        self.ca.update(fetch_progress=FetchProcess(self.sudoDaemon))

    # apt-get update
    #def apt_get_update(self):
    #    threading.Thread(target=self.apt_get_update_thread, name='AptUpdate').start()

    # get package by pkgName
    def get_pkg_by_name(self, pkgName):
        try:
            return self.ca[pkgName]
        except Exception, e:
            print e
            return "ERROR"

    # install package
    def install_pkg(self, pkgName):
        self.ca.open()
        pkg = self.get_pkg_by_name(pkgName)
        pkg.mark_install()

        try:
            self.ca.commit(FetchProcess(self.sudoDaemon), AptProcess(self.sudoDaemon))
        except Exception, e:
            print e
            print "install err"

    # install package
    #def install_pkg(self, pkgName):
    #    threading.Thread(target=self.install_pkg_thread, args=(pkgName,), name='PkgInstall').start()

    # uninstall package
    def uninstall_pkg(self, pkgName):
        self.ca.open()
        pkg = self.get_pkg_by_name(pkgName)
        pkg.mark_delete()

        try:
            self.ca.commit(None, AptProcess(self.sudoDaemon))
        except Exception, e:
            print e
            print "uninstall err"

    # uninstall package
    #def uninstall_pkg(self, pkgName):
    #    threading.Thread(target=self.uninstall_pkg_thread, args=(pkgName,), name='PkgUninstall').start()

    # update package
    def update_pkg(self, pkgName):
        self.ca.open()
        pkg = self.get_pkg_by_name(pkgName)
        pkg.mark_upgrade()

        try:
            self.ca.commit(FetchProcess(self.sudoDaemon), AptProcess(self.sudoDaemon))
        except Exception, e:
            print e
            print "update err"

    # update package
    #def update_pkg(self, pkgName):
    #    threading.Thread(target=self.update_pkg_thread, args=(pkgName,), name='PkgUpgrade').start()

    # check package status by pkgName, i = installed u = can update n = notinstall
    def check_pkg_status(self, pkgName):
        self.ca.open()
        pkg = self.get_pkg_by_name(pkgName)
        if(pkg == "ERROR"):
            return "ERROR"
        if(pkg.is_installed):
            if(pkg.is_upgradable):
                return "u"
            else:
                return "i"
        else:
            return "n"

    # check packages status by pkgNameList, i = installed u = can update n = notinstall
    def check_pkgs_status(self, pkgNameList):
        self.ca.open()
        pkgStatusDict = {}
        for pkgName in pkgNameList:
            pkg = self.get_pkg_by_name(pkgName)
            if(pkg == "ERROR"):
                continue
            if(pkg.is_installed):
                if(pkg.is_upgradable):
                    pkgStatusDict[pkgName] = "u"
                else:
                    pkgStatusDict[pkgName] = "i"
            else:
                pkgStatusDict[pkgName] = "n"

        return pkgStatusDict

    # check packages status by pkgNameList, i = installed u = can update n = notinstall
    def check_pkgs_status_rtn_list(self, pkgNameList):
        self.ca.open()
        pkgStatusList = []
        for pkgName in pkgNameList:
            pkg = self.get_pkg_by_name(pkgName)
            if(pkg == "ERROR"):
                    continue
            if(pkg.is_installed):
                if(pkg.is_upgradable):
                    pkgStatusList.append(pkgName + ":u")
                else:
                    pkgStatusList.append(pkgName + ":i")
            else:
                pkgStatusList.append(pkgName + ":n")

        self.sudoDaemon.software_check_status_signal(pkgStatusList)
        #return pkgStatusList

    # check packages status by pkgNameList, i = installed u = can update n = notinstall
    #def check_pkgs_status_rtn_list(self, pkgNameList):
    #    threading.Thread(target=self.check_pkgs_status_rtn_list_thread, args=(pkgNameList,), name='PkgStatusList').start()

# 	def get_pkgs_name_list(self):
# 		return self.pkgNameList
# 
# 	def search_pkgs_name(self, pkgName):
# 		if pkgName in self.pkgNameList:
# 			return pkgName
# 		else:
# 			rtns = []
# 			for name in self.pkgNameList:
# 				if name.find(pkgName) >= 0:
# 					rtns.append(name)
# 			return rtns

    # get all source item in /etc/apt/sources.list
    def get_sources(self):
        source = aptsources.sourceslist.SourcesList()
        return source.list

    # add ubuntukylin source in /etc/apt/sources.list
    def add_source_ubuntukylin(self):
        source = aptsources.sourceslist.SourcesList()
        for item in source.list:
            if(item.str().find("deb http://archive.ubuntukylin.com/ubuntukylin") != -1):
                return

        source.add("deb", "http://archive.ubuntukylin.com/ubuntukylin/", "raring main", "")
        source.save()

    # remove ubuntukylin source in /etc/apt/sources.list
    def remove_source_ubuntukylin(self):
        source = aptsources.sourceslist.SourcesList()
        sources = source.list
        for item in sources:
            if(item.str().find("deb http://archive.ubuntukylin.com/ubuntukylin") != -1):
                source.remove(item)
        source.save()

if __name__ == "__main__":
    ad = AptDaemon(None)

# 	print ad.check_pkgs_status(["gedit", "cairo-dock", "unity"])
#	print ad.check_pkgs_status_rtn_list(["gedit", "cairo-dock", "unity", "haha", "hehe"])
# 	ad.apt_get_update()
    ad.add_source_ubuntukylin()
# 	ad.remove_source_ubuntukylin()

    while True:
        print "\ninput your command: "
        cmd = raw_input()
        if cmd == "l":
            for name in ad.pkgNameList:
                print name + "\n"
        elif cmd == "i":
            print "input pkgName to install: "
            pkgName = raw_input()
            ad.install_pkg(pkgName)
        elif cmd == "n":
            print "input pkgName to uninstall: "
            pkgName = raw_input()
            ad.uninstall_pkg(pkgName)
        elif cmd == "u":
            print "input pkgName to update: "
            pkgName = raw_input()
            ad.update_pkg(pkgName)
        elif cmd == "c":
            print "input pkgName to check status: "
            pkgName = raw_input()
            print ad.check_pkg_status(pkgName)
        else:
            print "nothing..."

# 	print ad.get_pkg_by_name('gedit')
    # pnl = ad.getpkglist()
    # print len(pnl)
# 	name1 = ad.search_pkgs_name('wesnoth-1.10-core')
# 	print name1
    # print 'aaa' + str(1)
# 	ad.install_pkg(name1)
# 	ad.uninstall_pkg(name1)
    # p = ad.get_pkg_by_name(name1)
    # print p.id
    # c = AptCache()
    # c.hahaha()
    # print c.hahaha()
    # pkgs = []
    # ca = apt.Cache()
    # i = 0
    # for a in ca:
    # 	i += 1
    # 	pkgs.append(a.name)
            # print a.name
    # print i
    # nanop = ca['nano']
    # print nanop
    # nanop.mark_install()
    # ca.commit()
