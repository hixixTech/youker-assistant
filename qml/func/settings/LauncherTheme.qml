/*
 * Copyright (C) 2013 National University of Defense Technology(NUDT) & Kylin Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import "../common" as Common
import "../bars" as Bars
Rectangle {
    id: launcherthemepage
    property bool on: true
    width: parent.width
    height: 475
    property string fontName: "Helvetica"
    property int fontSize: 12
    property color fontColor: "black"

    property int launcher_size
    property string actiontitle: qsTr("Launcher settings")//启动器设置
    property string actiontext: qsTr("Setting the Launcher display mode, Icon size")//设置启动器的显示模式、图标尺寸

    //背景
    Image {
        source: "../../img/skin/bg-bottom-tab.png"
        anchors.fill: parent
    }

    Component.onCompleted: {
        launcherthemepage.launcher_size = slider.value;
        //将系统初始的Launcher大小写入QSetting配置文件
        sessiondispatcher.write_default_configure_to_qsetting_file("launcher", "size", slider.value);
        if (sessiondispatcher.get_launcher_autohide_qt()) {
            launcherswitcher.switchedOn = true;
            sessiondispatcher.write_default_configure_to_qsetting_file("launcher", "autohide", "true");
        }
        else {
            launcherswitcher.switchedOn = false;
            sessiondispatcher.write_default_configure_to_qsetting_file("launcher", "autohide", "false");
        }

        if (sessiondispatcher.get_launcher_have_showdesktopicon_qt()) {
            showdesktopswitcher.switchedOn = true;
            sessiondispatcher.write_default_configure_to_qsetting_file("launcher", "showicon", "true");
        }
        else {
            showdesktopswitcher.switchedOn = false;
            sessiondispatcher.write_default_configure_to_qsetting_file("launcher", "showicon", "false");
        }
    }

    Column {
        spacing: 10
        anchors.top: parent.top
        anchors.topMargin: 44
        anchors.left: parent.left
        anchors.leftMargin: 80
        Row {
            spacing: 50
            Text {
                 text: launcherthemepage.actiontitle
                 font.bold: true
                 font.pixelSize: 14
                 color: "#383838"
             }
            //status picture
            Common.StatusImage {
                id: statusImage
                visible: false
                iconName: "green.png"
                text: qsTr("Completed")//已完成
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Text {
            width: launcherthemepage.width - 80 - 20
            text: launcherthemepage.actiontext
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            color: "#7a7a7a"
        }
    }


    Row {
        id: settitle
        anchors{
            left: parent.left
            leftMargin: 40
            top: parent.top
            topMargin: 120

        }
        spacing: 5
        Text{
            text: qsTr("Launcher settings")//启动器设置
            font.bold: true
            font.pixelSize: 12
            color: "#383838"
        }
        Rectangle{
            width:700
            height:1
            color:"#b9c5cc"
            anchors.verticalCenter: parent.verticalCenter
        }
    }


    Column {
        spacing: 20
        anchors{
            left: parent.left
            leftMargin: 60
            top: settitle.bottom
            topMargin: 10
        }
        Row {
            spacing: 20
            Common.Label {
                id: launcherlabel
                width: 150
                text: qsTr("Launcher hide mode:")//启动器自动隐藏：
                font.pixelSize: 12
                color: "#7a7a7a"
                anchors.verticalCenter: parent.verticalCenter
            }
            Common.Switch {
                id: launcherswitcher
//                width: launcherlabel.width
                onSwitched: {
                    if (launcherswitcher.switchedOn) {
                        sessiondispatcher.set_launcher_autohide_qt(true);
                    }
                    else if(!launcherswitcher.switchedOn) {
                        sessiondispatcher.set_launcher_autohide_qt(false);
                    }
                }
            }
        }

        Row {
            spacing: 20
            Common.Label {
                id: iconsizelabel
                width: 150
                text: qsTr("Launcher icon size: ")//启动器图标尺寸：
                font.pixelSize: 12
                color: "#7a7a7a"
                anchors.verticalCenter: parent.verticalCenter
            }
            Common.Slider {
                id: slider
                value: sessiondispatcher.get_launcher_icon_size_qt()
                width: 150
                maximumValue: 64
                minimumValue: 32
//                tickmarksEnabled: true
                stepSize: 1
                animated: true
            }

            Text {
                id: displaynum
                text: slider.value
                font.pixelSize: 12
                color: "#7a7a7a"
                anchors.verticalCenter: parent.verticalCenter
            }
            Common.Button {
                id: okBtn
                hoverimage: "green2.png"
                fontsize: 12
                text: qsTr("OK")//确定
                width: 94; height: 29
                onClicked: {
                    if (launcherthemepage.launcher_size != slider.value) {
                        launcherthemepage.launcher_size = slider.value;
                        sessiondispatcher.set_launcher_icon_size_qt(slider.value);
                    }
                }
            }
        }

        Row {
            spacing: 20
            Common.Label {
                id: showdesktoplabel
                width: 150
                text: qsTr("Display desktop icon: ")//显示桌面图标：
                font.pixelSize: 12
                color: "#7a7a7a"
                anchors.verticalCenter: parent.verticalCenter
            }
            Common.Switch {
                id: showdesktopswitcher
//                width: showdesktoplabel.width
                onSwitched: {
                    if (showdesktopswitcher.switchedOn) {
                        sessiondispatcher.set_launcher_have_showdesktopicon_qt(true);
                    }
                    else if(!showdesktopswitcher.switchedOn) {
                        sessiondispatcher.set_launcher_have_showdesktopicon_qt(false);
                    }
                }
            }
        }
    }//Column

    //顶层工具栏
    Bars.TopBar {
        id: topBar
        width: 28
        height: 26
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.leftMargin: 40
        opacity: 0.9
        onButtonClicked: {
            var num = sessiondispatcher.get_page_num();
            if (num == 0)
                pageStack.push(homepage)
            else if (num == 3)
                pageStack.push(systemset)
            else if (num == 4)
                pageStack.push(functioncollection)
        }
    }
    //底层工具栏
    Bars.ToolBar {
        id: toolBar
        showok: false
        showrestore: true
        height: 50; anchors.bottom: parent.bottom; width: parent.width; opacity: 0.9
        onQuitBtnClicked: {
            var num = sessiondispatcher.get_page_num();
            if (num == 0)
                pageStack.push(homepage)
            else if (num == 3)
                pageStack.push(systemset)
            else if (num == 4)
                pageStack.push(functioncollection)
        }
        onRestoreBtnClicked: {
            var defaultsize = sessiondispatcher.read_default_configure_from_qsetting_file("launcher", "size");
            var defaultautohide = sessiondispatcher.read_default_configure_from_qsetting_file("launcher", "autohide");
            var defaultshowicon = sessiondispatcher.read_default_configure_from_qsetting_file("launcher", "showicon");
            var autohideFlag;
            var showiconFlag;
            if(launcherswitcher.switchedOn) {
                autohideFlag = "true";
            }
            else {
                autohideFlag = "false";
            }
            if(showdesktopswitcher.switchedOn) {
                showiconFlag = "true";
            }
            else {
                showiconFlag = "false";
            }

            if((defaultsize == launcherthemepage.launcher_size) && (defaultautohide == autohideFlag) && (defaultshowicon == showiconFlag)) {
                //友情提示：        Launcher已经恢复为默认配置！
                sessiondispatcher.showWarningDialog(qsTr("Tips:"), qsTr("Launcher has been restored to the default configuration!"), mainwindow.pos.x, mainwindow.pos.y);//友情提示：//Launcher已经恢默认配置！
            }
            else {
                if(defaultsize != slider.value) {
                    sessiondispatcher.set_launcher_icon_size_qt(defaultsize);
                    slider.value = defaultsize;
                    launcherthemepage.launcher_size = defaultsize;
                }
                if(defaultautohide != autohideFlag) {
                    if(defaultautohide == "true") {
                        launcherswitcher.switchedOn = true;
                        sessiondispatcher.set_launcher_autohide_qt(true);
                    }
                    else {
                        launcherswitcher.switchedOn = false;
                        sessiondispatcher.set_launcher_autohide_qt(false);
                    }
                }
                if(defaultshowicon != showiconFlag) {
                    if(defaultshowicon == "true") {
                        showdesktopswitcher.switchedOn = true;
                        sessiondispatcher.set_launcher_have_showdesktopicon_qt(true);
                    }
                    else {
                        showdesktopswitcher.switchedOn = false;
                        sessiondispatcher.set_launcher_have_showdesktopicon_qt(false);
                    }
                }
                statusImage.visible = true;
            }
        }
//        onOkBtnClicked: {
//            if (launcherthemepage.launcher_size != slider.value) {
//                launcherthemepage.launcher_size = slider.value;
//                sessiondispatcher.set_launcher_icon_size_qt(slider.value);
//                statusImage.visible = true;
//            }
//        }

        Timer {
             interval: 5000; running: true; repeat: true
             onTriggered: statusImage.visible = false
        }
    }
}
