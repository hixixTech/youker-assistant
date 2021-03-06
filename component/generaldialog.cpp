/*
 * Copyright (C) 2013 ~ 2015 National University of Defense Technology(NUDT) & Kylin Ltd.
 *
 * Authors:
 *  tang guang   tangguang@kylinos.cn
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


#include "generaldialog.h"
#include "systembutton.h"
#include <QBitmap>
#include <QtMath>

GeneralDialog::GeneralDialog(QWidget *parent, QString text, bool warn, bool showCancel):
    QDialog(parent)
{
    this->setWindowFlags(Qt::FramelessWindowHint | Qt::Dialog);
    this->setAutoFillBackground(true);
    this->setAttribute(Qt::WA_TranslucentBackground);
    this->setFixedSize(340,260);
//    this->setStyleSheet("GeneralDialog{border:1px solid rgba(207, 207, 207, 1);\
//                        border-radius:10px;}");

    QBitmap objBitmap(340,260);
    //QPainter用于在位图上绘画
    QPainter painter(&objBitmap);
    //填充位图矩形框(用白色填充)
    painter.fillRect(rect(),Qt::white);
    painter.setBrush(QColor(0,0,0));
    //在位图上画圆角矩形(用黑色填充)
    painter.drawRoundedRect(this->rect(),10,10);
    //使用setmask过滤即可
    setMask(objBitmap);


    SystemButton *closeBtn = new SystemButton(this);
    closeBtn->loadPixmap(":/sys/res/sysBtn/close_button1.svg");
    closeBtn->setGeometry(QRect(298,12,36,36));
    connect(closeBtn,SIGNAL(clicked()),this,SLOT(onclickCloseBtn()));

    QLabel *iconLabel = new QLabel(this);
    QLabel *textlabel = new QLabel(this);
    QFont font;
    font.setPixelSize(24);
    font.setBold(QFont::Bold);
    if(warn)
    {
        QPixmap icon(":/res/remind.png");
        iconLabel->setPixmap(icon);
        textlabel->setFont(font);
        textlabel->setText(tr("Remind"));
    }
    else
    {
        QPixmap icon(":/res/warning.png");
        iconLabel->setPixmap(icon);
        textlabel->setFont(font);
        textlabel->setText(tr("Warning"));
    }
    iconLabel->setGeometry(QRect(32,48,32,32));
    textlabel->setGeometry(QRect(71,48,100,30));

    contentLabel = new QLabel(this);
    contentLabel->setText(text);
    contentLabel->adjustSize();
    contentLabel->setWordWrap(true);
    contentLabel->setGeometry(QRect(32,103,270,40));

    cancelBtn = new QPushButton(this);
    cancelBtn->setText(tr("Cancel"));
    cancelBtn->setGeometry(QRect(55,180,120,36));
    cancelBtn->setStyleSheet("QPushButton{width:120px;height:36px;\
                             background:rgba(231,231,231,1);\
                             border-radius:4px;font-size:14px;color:black;}\
                             QPushButton:hover{width:120px;height:36px;\
                             background:rgba(67,127,240,1);\
                             border-radius:4px;font-size:14px;color:white;}");
    if(showCancel)
    {
        cancelBtn->hide();
    }
    connect(cancelBtn,SIGNAL(clicked()),this,SLOT(onclickCloseBtn()));

    okBtn = new QPushButton(this);
    okBtn->setText(tr("OK"));
    okBtn->setGeometry(QRect(191,180,120,36));
    okBtn->setStyleSheet("QPushButton{width:120px;height:36px;\
                         background:rgba(231,231,231,1);\
                         border-radius:4px;font-size:14px;color:black;}\
                         QPushButton:hover{width:120px;height:36px;\
                         background:rgba(67,127,240,1);\
                         border-radius:4px;font-size:14px;color:white;}");
    connect(okBtn,SIGNAL(clicked()),this,SLOT(onclickOkBtn()));
}

GeneralDialog::~GeneralDialog()
{

}

void GeneralDialog::paintEvent(QPaintEvent *event)
{
    Q_UNUSED(event)
    QPainterPath path;
    path.setFillRule(Qt::WindingFill);
    path.addRoundRect(10,10,this->width()-20,this->height()-20,5,5);
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing,true);
    painter.fillPath(path,QBrush(Qt::white));
    QColor color(0,0,0,50);
    for(int i = 0 ; i < 10 ; ++i)
    {
        QPainterPath path;
        path.setFillRule(Qt::WindingFill);
        path.addRoundRect(10-i,10-i,this->width()-(10-i)*2,this->height()-(10-i)*2,5,5);
        color.setAlpha(150 - qSqrt(i)*50);
        painter.setPen(color);
        painter.drawPath(path);
    }

    QWidget::paintEvent(event);
}

void GeneralDialog::onclickCloseBtn()
{
    this->reject();
}

void GeneralDialog::onclickOkBtn()
{
    this->accept();
}
