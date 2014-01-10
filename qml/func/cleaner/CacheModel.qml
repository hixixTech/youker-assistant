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

Item {
    id:root
    width: parent.width
    height: 435
    property string title: qsTr("Deep cleaning up the system cache")//深度清理系统缓存
    property string description: qsTr("Deep cleaning up the system cache, to save disk space")//深度清理系统缓存，节省磁盘空间！
    property string btnFlag: "cache_scan"//扫描或者清理的标记：cache_scan/cache_work
    property bool aptresultFlag: false//判断apt扫描后的实际内容是否为空，为空时为false，有内容时为true
    property bool softresultFlag: false//判断soft扫描后的实际内容是否为空，为空时为false，有内容时为true
    property int aptNum//扫描后得到的apt的项目总数
    property int softNum//扫描后得到的soft的项目总数
    property bool splitFlag: true//传递给CacheDelegate.qml,为true时切割字符串，为false时不切割字符串
    property bool flag: false//记录是清理后重新获取数据（true），还是点击开始扫描后获取数据（false）
    property int spaceValue: 20
    property int apt_arrow_show: 0//传递给CacheDelegate.qml是否显示伸缩图标，为1时显示，为0时隐藏
    property int soft_arrow_show: 0//传递给CacheDelegate.qml是否显示伸缩图标，为1时显示，为0时隐藏
    property bool apt_expanded: false//传递给CacheDelegate.qml,觉得伸缩图标是扩展还是收缩
    property bool soft_expanded: false//传递给CacheDelegate.qml,觉得伸缩图标是扩展还是收缩
    property bool apt_maincheck: true
    property bool soft_maincheck: true
    property bool apt_showNum: false//决定apt的扫描结果数是否显示
    property bool soft_showNum: false//决定soft的扫描结果数是否显示
    property bool aptEmpty: false//决定是否显示扫描内容为空的状态图
    property bool softEmpty: false//决定是否显示扫描内容为空的状态图
    property int mode: 0//扫描模式：0表示两者都扫描，1表示只选中了apt，2表示只选中了soft
    ListModel { id: aptmainModel }
    ListModel { id: aptsubModel }
    ListModel { id: softmainModel }
    ListModel { id: softsubModel }

    Connections
    {
        target: sessiondispatcher
        onAppendContentToCacheModel: {
            //QString flag, QString path, QString fileFlag, QString sizeValue
            if(flag == "apt") {
                aptsubModel.append({"itemTitle": path, "desc": fileFlag, "number": sizeValue});
                root.aptNum += 1;
                systemdispatcher.set_cache_args(path);
            }
            else if(flag == "software-center") {
                softsubModel.append({"itemTitle": path, "desc": fileFlag, "number": sizeValue});
                root.softNum += 1;
                systemdispatcher.set_cache_args(path);
            }
        }
        onTellQMLCaheOver: {
            aptmainModel.clear();
            softmainModel.clear();
//            doingImage.visible = false;
            //软件包缓存清理           Apt缓存路径：/var/cache/apt/archives
            aptmainModel.append({"mstatus": root.apt_maincheck ? "true": "false",
                             "itemTitle": qsTr("Cleanup Package Cache"),
                             "picture": "../../img/toolWidget/apt-min.png",
                             "detailstr": qsTr("Apt Cache Path: /var/cache/apt/archives")})//软件包缓存清理//
            //软件中心缓存清理       软件中心缓存：
            softmainModel.append({"mstatus": root.soft_maincheck ? "true": "false",
                             "itemTitle": qsTr("Cleanup Software Center Cache"),
                             "picture": "../../img/toolWidget/software-min.png",
                             "detailstr": qsTr("Software Center Cache Path: ") + sessiondispatcher.getHomePath() + "/.cache/software-center"})

            if(root.aptNum != 0) {
                root.aptresultFlag = true;//扫描的实际有效内容存在
            }
            else {
                if(root.mode == 0 || root.mode == 1) {
                    root.aptEmpty = true;
                }
                root.aptresultFlag = false;//扫描的实际有效内容不存在
            }
            if(root.softNum != 0) {
                root.softresultFlag = true;//扫描的实际有效内容存在
            }
            else {
                if(root.mode == 0 || root.mode == 2) {
                    root.softEmpty = true;
                }
                root.softresultFlag = false;//扫描的实际有效内容不存在
            }

            if(root.aptresultFlag == false) {
                root.apt_showNum = false;
                root.apt_expanded = false;//伸缩箭头不扩展
                root.apt_arrow_show = 0;//伸缩箭头不显示
            }
            else if(root.aptresultFlag == true) {
                root.apt_showNum = true;
                root.apt_expanded = true;//伸缩箭头扩展
                root.apt_arrow_show = 1;//伸缩箭头显示
            }
            if(root.softresultFlag == false) {
                root.soft_showNum = false;
                root.soft_expanded = false;//伸缩箭头不扩展
                root.soft_arrow_show = 0;//伸缩箭头不显示
            }
            else if(root.softresultFlag == true) {
                root.soft_showNum = true;
                root.soft_expanded = true;//伸缩箭头扩展
                root.soft_arrow_show = 1;//伸缩箭头显示
            }

            if(root.aptresultFlag == false && root.softresultFlag == false) {
                root.state = "AptWorkEmpty";
                if(root.flag == false) {//点击扫描时的获取数据，此时显示该对话框
                    //友情提示：      扫描内容为空，无需清理！
                    sessiondispatcher.showWarningDialog(qsTr("Tips:"), qsTr("The scan results are empty, no need to clean up !"), mainwindow.pos.x, mainwindow.pos.y);
                }
                else {//清理apt后的重新获取数据，此时不需要显示对话框
                    root.flag = false;
                }
            }
            else {
                if(root.flag == false) {//点击扫描时的获取数据，此时显示该对话框
                    toolkits.alertMSG(qsTr("Scan completed!"), mainwindow.pos.x, mainwindow.pos.y);//扫描完成！
                }
                else {//清理software后的重新获取数据，此时不需要显示对话框
                    root.flag = false;
                }
                root.state = "AptWork";
                actionBtn.text = qsTr("Begin cleanup");//开始清理
                root.btnFlag = "cache_work";
                backBtn.visible = true;
//                rescanBtn.visible = true;
            }
            scrollItem.height = (root.aptNum + 1) * 40 + (root.softNum + 1) * 40 + root.spaceValue*2;
            //扫描完成后恢复按钮的使能
            actionBtn.enabled = true;
        }
    }

    Component.onCompleted: {
        //软件包缓存清理           Apt缓存路径：/var/cache/apt/archives
        aptmainModel.append({"mstatus": root.apt_maincheck ? "true": "false",
                         "itemTitle": qsTr("Cleanup Package Cache"),
                         "picture": "../../img/toolWidget/apt-min.png",
                         "detailstr": qsTr("Apt Cache Path: /var/cache/apt/archives")})
        //软件中心缓存清理       软件中心缓存：
        softmainModel.append({"mstatus": root.soft_maincheck ? "true": "false",
                         "itemTitle": qsTr("Cleanup Software Center Cache"),
                         "picture": "../../img/toolWidget/software-min.png",
                         "detailstr": qsTr("Software Center Cache Path: ") + sessiondispatcher.getHomePath() + "/.cache/software-center"})
    }

    Connections
    {
        target: systemdispatcher
        onFinishCleanWorkError: {//清理出错时收到的信号
            if (btnFlag == "cache_work") {
                if (msg == "cache") {
//                    doingImage.visible = false;
                    root.state = "AptWorkError";
                    //清理过程中发生错误，解禁按钮
                    actionBtn.enabled = true;
                    toolkits.alertMSG(qsTr("Cleanup abnormal!"), mainwindow.pos.x, mainwindow.pos.y);//清理出现异常！
                }
            }
        }
        onFinishCleanWork: {//清理成功时收到的信号
            if (root.btnFlag == "cache_work") {
//                doingImage.visible = false;
                if (msg == "") {
                    //清理取消，解禁按钮
                    actionBtn.enabled = true;
                    toolkits.alertMSG(qsTr("Cleanup interrupted!"), mainwindow.pos.x, mainwindow.pos.y);//清理中断！
                }
                else if (msg == "cache") {
                    root.state = "AptWorkFinish";
                    toolkits.alertMSG(qsTr("Cleared!"), mainwindow.pos.x, mainwindow.pos.y);//清理完毕！
                    //清理完毕后重新获取数据
                    root.flag = true;
                    if(root.apt_maincheck && root.soft_maincheck) {
                        aptmainModel.clear();
                        softmainModel.clear();
                        //软件包缓存清理           Apt缓存路径：/var/cache/apt/archives
                        aptmainModel.append({"mstatus": root.apt_maincheck ? "true": "false",
                                         "itemTitle": qsTr("Package cache cleanup"),
                                         "picture": "../../img/toolWidget/apt-min.png",
                                         "detailstr": qsTr("Apt Cache Path: /var/cache/apt/archives")})
                        //软件中心缓存清理       软件中心缓存：
                        softmainModel.append({"mstatus": root.soft_maincheck ? "true": "false",
                                         "itemTitle": qsTr("Software Center buffer cleaning"),
                                         "picture": "../../img/toolWidget/software-min.png",
                                         "detailstr": qsTr("Software Center Cache Path: ") + sessiondispatcher.getHomePath() + "/.cache/software-center"})
                        systemdispatcher.clear_cache_args();
                        aptsubModel.clear();//内容清空
                        softsubModel.clear();//内容清空
                        root.aptNum = 0;//隐藏滑动条
                        root.softNum = 0;//隐藏滑动条
                        root.mode = 0;
                        sessiondispatcher.cache_scan_function_qt(sessiondispatcher.get_cache_arglist());
                    }
                    else {
                        if(root.apt_maincheck) {
                            aptmainModel.clear();
                            //软件包缓存清理           Apt缓存路径：/var/cache/apt/archives
                            aptmainModel.append({"mstatus": root.apt_maincheck ? "true": "false",
                                             "itemTitle": qsTr("Package cache cleanup"),
                                             "picture": "../../img/toolWidget/apt-min.png",
                                             "detailstr": qsTr("Apt Cache Path: /var/cache/apt/archives")})
                            systemdispatcher.clear_cache_args();
                            aptsubModel.clear();//内容清空
                            softsubModel.clear();//内容清空
                            root.aptNum = 0;//隐藏滑动条
                            root.softNum = 0;//隐藏滑动条
                            root.mode = 1;
                            sessiondispatcher.cache_scan_function_qt("apt");
                        }
                        else if(root.soft_maincheck) {
                            softmainModel.clear();
                            //软件中心缓存清理       软件中心缓存：
                            softmainModel.append({"mstatus": root.soft_maincheck ? "true": "false",
                                             "itemTitle": qsTr("Software Center buffer cleaning"),
                                             "picture": "../../img/toolWidget/software-min.png",
                                             "detailstr": qsTr("Software Center Cache Path: ") + sessiondispatcher.getHomePath() + "/.cache/software-center"})
                            systemdispatcher.clear_cache_args();
                            aptsubModel.clear();//内容清空
                            softsubModel.clear();//内容清空
                            root.aptNum = 0;//隐藏滑动条
                            root.softNum = 0;//隐藏滑动条
                            root.mode = 2;
                            sessiondispatcher.cache_scan_function_qt("software-center");
                        }
                    }
                    //清理成功完成，解禁按钮
                    actionBtn.enabled = true;
                }
            }
        }
    }

    //背景
    Image {
        source: "../../img/skin/bg-bottom-tab.png"
        anchors.fill: parent
    }

    //titlebar
    Row {
        id: titlebar
        spacing: 20
        width: parent.width
        anchors { top: parent.top; topMargin: 20; left: parent.left; leftMargin: 27 }
        Image {
            id: apt_refreshArrow
            source: "../../img/toolWidget/cache.png"
            Behavior on rotation { NumberAnimation { duration: 200 } }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            Text {
                width: 500
                text: root.title
                wrapMode: Text.WordWrap
                font.bold: true
                font.pixelSize: 14
                color: "#383838"
            }
            Text {
                width: 500
                text: root.description
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                color: "#7a7a7a"
            }
        }
    }

    Row{
        anchors { top: parent.top; topMargin: 20;right: parent.right ; rightMargin: 40 }
        spacing: 20
        Row {
            spacing: 20    
            anchors.verticalCenter: parent.verticalCenter
//            AnimatedImage {
//                id: doingImage
//                anchors.verticalCenter: parent.verticalCenter
//                width: 16
//                height: 16
//                visible: false
//                source: "../../img/icons/move.gif"
//            }
            Common.StyleButton {
                id: backBtn
                visible: false
                anchors.verticalCenter: parent.verticalCenter
                wordname: qsTr("Back")//返回
                width: 40
                height: 20
                onClicked: {
                    root.aptEmpty = false;
                    root.softEmpty = false;
                    if(root.apt_maincheck == false) {
                        root.apt_maincheck = true;
                    }
                    if(root.soft_maincheck == false) {
                        root.soft_maincheck = true;
                    }
                    systemdispatcher.clear_cache_args();
                    root.apt_showNum = false;
                    root.soft_showNum = false;
                    aptmainModel.clear();
                    softmainModel.clear();
                    //软件包缓存清理           Apt缓存路径：/var/cache/apt/archives
                    aptmainModel.append({"mstatus": root.apt_maincheck ? "true": "false",
                                     "itemTitle": qsTr("Package cache cleanup"),
                                     "picture": "../../img/toolWidget/apt-min.png",
                                     "detailstr": qsTr("Apt Cache Path: /var/cache/apt/archives")})
                    //软件中心缓存清理       软件中心缓存：
                    softmainModel.append({"mstatus": root.soft_maincheck ? "true": "false",
                                     "itemTitle": qsTr("Software Center buffer cleaning"),
                                     "picture": "../../img/toolWidget/software-min.png",
                                     "detailstr": qsTr("Software Center Cache Path: ") + sessiondispatcher.getHomePath() + "/.cache/software-center"})
                    aptsubModel.clear();//内容清空
                    root.aptNum = 0;//隐藏滑动条
                    root.apt_arrow_show = 0;//伸缩图标隐藏
                    softsubModel.clear();//内容清空
                    root.softNum = 0;//隐藏滑动条
                    root.soft_arrow_show = 0;//伸缩图标隐藏
                    scrollItem.height = 2 * 40 + root.spaceValue*2;
                    root.state = "AptWorkAGAIN";//按钮的状态恢复初始值
                }
            }
        }
        Common.Button {
            id: actionBtn
            width: 120
            height: 39
            hoverimage: "green1.png"
            text: qsTr("Start scanning")//开始扫描
            fontsize: 15
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                //扫描过程中禁用按钮
                actionBtn.enabled = false;
                root.aptEmpty = false;
                root.softEmpty = false;
//                console.log("-----------");
//                console.log(root.apt_maincheck);
//                console.log(root.soft_maincheck);

                if (root.btnFlag == "cache_scan") {//扫描
                    root.flag = false;

                    if(root.apt_maincheck && root.soft_maincheck) {//software-center
//                        doingImage.visible = true;
                        root.mode = 0;
                        root.aptNum = 0;
                        root.softNum = 0;
                        sessiondispatcher.cache_scan_function_qt(sessiondispatcher.get_cache_arglist());
                    }
                    else {
                        if(root.apt_maincheck) {
//                            doingImage.visible = true;
                            root.mode = 1;
                            root.aptNum = 0;
                            sessiondispatcher.cache_scan_function_qt("apt");
                        }
                        else if(root.soft_maincheck) {
//                            doingImage.visible = true;
                            root.mode = 2;
                            root.softNum = 0;
                            sessiondispatcher.cache_scan_function_qt("software-center");
                        }
                        else{
                            actionBtn.enabled = true;
                            //友情提示：        对不起，您没有选择需要扫描的内容，请确认！
                            sessiondispatcher.showWarningDialog(qsTr("Tips:"), qsTr("Sorry, You did not choose the content to be scanned, please confirm!"), mainwindow.pos.x, mainwindow.pos.y);
                        }
                    }
                }
                else if (root.btnFlag == "cache_work") {//清理
                    if(root.aptresultFlag || root.softresultFlag) {//扫描得到的实际内容存在时
                        if(!root.apt_maincheck && !root.soft_maincheck) {
                            //友情提示：        对不起，您没有选择需要清理的内容，请确认！
                            sessiondispatcher.showWarningDialog(qsTr("Tips:"), qsTr("Sorry, You did not choose the content to be cleaned up, please confirm!"), mainwindow.pos.x, mainwindow.pos.y);
                        }
                        else {
//                            doingImage.visible = true;
//                            console.log("33333333333");
//                            console.log(systemdispatcher.get_cache_args());
                            //开始清理时，禁用按钮，等到清理完成后解禁
                            actionBtn.enabled = false;
                            systemdispatcher.clean_file_cruft_qt(systemdispatcher.get_cache_args(), "cache");
                        }
                    }
                }
            }
        }
    }

    //分割条
    Common.Separator {
        id: splitbar
        anchors {
            top: titlebar.bottom
            topMargin: 18
            left: parent.left
            leftMargin: 2
        }
        width: parent.width - 4
    }

    Common.ScrollArea {
        frame:false
        anchors.top: titlebar.bottom
        anchors.topMargin: 30
        anchors.left:parent.left
        anchors.leftMargin: 27
        height: root.height - titlebar.height - 47
        width: parent.width - 27 -2
        Item {
            id: scrollItem
            width: parent.width
            height: 40*2 + root.spaceValue*2
            Column {
                spacing: root.spaceValue
                //垃圾清理显示内容
                ListView {
                    id: aptListView
                    width: parent.width
                    height: root.apt_expanded ? (root.aptNum + 1) * 40 : 40
                    model: aptmainModel
                    delegate: CacheDelegate{
                        sub_num: root.aptNum//root.aptsubNum//1212
                        sub_model: aptsubModel
                        btn_flag: root.btnFlag
                        arrowFlag: "apt"
                        showNum: root.apt_showNum
                        arrow_display: root.apt_arrow_show//为0时隐藏伸缩图标，为1时显示伸缩图标
                        expanded: root.apt_expanded//apt_expanded为true时，箭头向下，内容展开;apt_expanded为false时，箭头向上，内容收缩
                        delegate_flag: root.splitFlag
                        emptyTip: root.aptEmpty
                        //Cleardelegate中返回是否有项目勾选上，有为true，没有为false
                        onCheckchanged: {
//                            root.aptresultFlag = checkchange;
                            root.apt_maincheck = checkchange;
                        }
                        onArrowClicked: {
                            if(cacheFlag == "apt") {//1212
                                if(expand_flag == true) {
                                    root.apt_expanded = true;
                                    if(root.soft_expanded == true) {
                                        scrollItem.height = (root.aptNum + 1) * 40 + (root.softNum + 1) * 40 + root.spaceValue*2;
                                    }
                                    else {
                                        scrollItem.height = (root.aptNum + 2) * 40 + root.spaceValue*2;
                                    }
                                }
                                else {
                                    root.apt_expanded = false;
                                    if(root.soft_expanded == true) {
                                        scrollItem.height = (root.softNum + 2) * 40 + root.spaceValue*2;
                                    }
                                    else {
                                        scrollItem.height = 2* 40 + root.spaceValue*2;
                                    }
                                }
                            }
                        }
                    }
                    cacheBuffer: 1000
                    opacity: 1
                    spacing: 10
                    snapMode: ListView.NoSnap
                    boundsBehavior: Flickable.DragOverBounds
                    currentIndex: 0
                    preferredHighlightBegin: 0
                    preferredHighlightEnd: preferredHighlightBegin
                    highlightRangeMode: ListView.StrictlyEnforceRange
                }
                //垃圾清理显示内容
                ListView {
                    id: softListView
                    width: parent.width
                    height: root.soft_expanded ? (root.softNum + 1) * 40 : 40
                    model: softmainModel
                    delegate: CacheDelegate{
                        sub_num: root.softNum
                        sub_model: softsubModel
                        btn_flag: root.btnFlag
                        showNum: root.soft_showNum
                        arrowFlag: "soft"
                        arrow_display: root.soft_arrow_show//为0时隐藏伸缩图标，为1时显示伸缩图标
                        expanded: root.soft_expanded//soft_expanded为true时，箭头向下，内容展开;soft_expanded为false时，箭头向上，内容收缩
                        delegate_flag: root.splitFlag
                        emptyTip: root.softEmpty
                        //Cleardelegate中返回是否有项目勾选上，有为true，没有为false
                        onCheckchanged: {
//                            root.softresultFlag = checkchange;
                            root.soft_maincheck = checkchange;
                        }
                        onArrowClicked: {
                            if(cacheFlag == "soft") {//1212
                                if(expand_flag == true) {
                                    root.soft_expanded = true;
                                    if(root.apt_expanded == true) {
                                        scrollItem.height = (root.aptNum + 1) * 40 + (root.softNum + 1) * 40 + root.spaceValue*2;
                                    }
                                    else {
                                        scrollItem.height = (root.softNum + 2) * 40 + root.spaceValue*2;
                                    }
                                }
                                else {
                                    root.soft_expanded = false;
                                    if(root.apt_expanded == true) {
                                        scrollItem.height = (root.aptNum + 2) * 40 + root.spaceValue*2;
                                    }
                                    else {
                                        scrollItem.height = 2* 40 + root.spaceValue*2;
                                    }
                                }
                            }
                        }
                    }
                    cacheBuffer: 1000
                    opacity: 1
                    spacing: 10
                    snapMode: ListView.NoSnap
                    boundsBehavior: Flickable.DragOverBounds
                    currentIndex: 0
                    preferredHighlightBegin: 0
                    preferredHighlightEnd: preferredHighlightBegin
                    highlightRangeMode: ListView.StrictlyEnforceRange
                }
            }
        }
    }

    states: [
        State {
            name: "AptWork"
            PropertyChanges { target: actionBtn; text:qsTr("Begin cleanup")}//开始清理
            PropertyChanges { target: root; btnFlag: "cache_work" }
            PropertyChanges { target: backBtn; visible: true}
//            PropertyChanges { target: rescanBtn; visible: true}
        },
        State {
            name: "AptWorkAGAIN"
            PropertyChanges { target: actionBtn; text:qsTr("Start scanning") }//开始扫描
            PropertyChanges { target: root; btnFlag: "cache_scan" }
            PropertyChanges { target: backBtn; visible: false}
//            PropertyChanges { target: rescanBtn; visible: false}
        },
        State {
            name: "AptWorkError"
            PropertyChanges { target: actionBtn; text:qsTr("Start scanning") }//开始扫描
            PropertyChanges { target: root; btnFlag: "cache_scan" }
            PropertyChanges { target: backBtn; visible: false}
//            PropertyChanges { target: rescanBtn; visible: false}
        },
        State {
            name: "AptWorkFinish"
            PropertyChanges { target: actionBtn; text:qsTr("Start scanning") }//开始扫描
            PropertyChanges { target: root; btnFlag: "cache_scan" }
            PropertyChanges { target: backBtn; visible: false}
//            PropertyChanges { target: rescanBtn; visible: false}
        },
        State {
            name: "AptWorkEmpty"
            PropertyChanges { target: actionBtn; text:qsTr("Start scanning")}//开始扫描
            PropertyChanges { target: root; btnFlag: "cache_scan" }
            PropertyChanges { target: backBtn; visible: false}
//            PropertyChanges { target: rescanBtn; visible: false}
        }
    ]
}
