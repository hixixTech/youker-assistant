/*
 * Copyright (C) 2013 ~ 2014 National University of Defense Technology(NUDT) & Kylin Ltd.
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

#ifndef SYSTEMAPPLICATION_H
#define SYSTEMAPPLICATION_H
#include <QDeclarativeView>
#include "tray.h"
#include "alertdialog.h"
#include <QDBusInterface>
#include <QDBusConnection>
#include <QtGui>

//#include "toplevel.h"
//#include <QPixmap>
class IhuApplication : public QWidget
{
    Q_OBJECT
public:
    explicit IhuApplication(QWidget *parent = 0);
    virtual ~IhuApplication();
    void setup();
    void showQMLWidget();

private:
    //关联QML界面
    QDeclarativeView *viewer;
//    QPixmap m_shadow;
    //系统托盘
    Tray *tray;

//    TopLevel *mTopLevel;
public slots:
    //主界面显示和隐藏
    void showOrHideMainPage();

//protected:
//    void paintEvent(QPaintEvent *e);
//    void showEvent(QShowEvent *e);
};

#endif // SYSTEMAPPLICATION_H
