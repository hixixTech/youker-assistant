#!/usr/bin/python
# -*- coding: utf-8 -*-
### BEGIN LICENSE
# Copyright (C) 2013 National University of Defense Technology(NUDT) & Kylin Ltd
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

import logging
import optparse

import dbus
import dbus.mainloop.glib

from gi.repository import GObject
from common.base import VERSION

if __name__ == '__main__':
    parser = optparse.OptionParser(prog="youker-assistant-sudo-daemon",
                                   version="%%prog %s" % VERSION,
                                   description="Youker Assistant is a tool for Ubuntu that makes it easy to configure your system and desktop settings.")

    parser.add_option("-d", "--debug", action="store_true", default=False,
                      help="Generate more debugging information.  [default: %default]")
    options, args = parser.parse_args()

    if options.debug:
        logging.basicConfig(level=logging.DEBUG)

    #TODO make it exist when timeout
    from sudodbus.daemon import SudoDaemon
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    mainloop = GObject.MainLoop()
    SudoDaemon(dbus.SystemBus(), mainloop)
    mainloop.run()