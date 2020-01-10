#include "barcode.h"

#include <QImage>
#include <QtSerialPort/QSerialPort>

#include <QtDebug>

#include <nlohmann/json.hpp>

namespace bcr {

using nlohmann::json;

struct BarcodeImpl {
    BarcodeImpl() {}
    ~BarcodeImpl() {}

    void open() {
        opened = true;
//        throw std::runtime_error("Open failed: Unknown");
    }

    bool isOpen() const {
        return opened;
    }

    bool isClosed() const {
        return !opened;
    }

    void close() {
        opened = false;
//        throw std::runtime_error("Close failed: Unknown");
    }


    unsigned mode{0};
    bool opened{false};

    struct {
        QString port{"/dev/ttyS3"};
        QSerialPort::BaudRate baud{QSerialPort::Baud115200};
        QSerialPort::DataBits databits{QSerialPort::Data8};
        QSerialPort::StopBits stopbits{QSerialPort::StopBits::OneStop};
        QSerialPort::Parity   parity{QSerialPort::NoParity};
    } serial;

    struct {
        QString txTopic{"/jzhw/serial/bcr/tx"};
        QString rxTopic{"/jzhw/serial/bcr/rx"};
    } ros;
};


Barcode::Barcode()
    : impl(std::make_shared<BarcodeImpl>()) {

}

Barcode::~Barcode() {
}

unsigned Barcode::mode() const {
    return impl->mode;
}

void Barcode::setMode(unsigned mode) {
    if (impl->mode != mode) {
        impl->mode = mode;
        emit modeChanged(mode);
    }
}

void Barcode::open() {

    if (impl->isClosed()) {
        try {
            impl->open();
            emit openedChanged(true);
        } catch(const std::exception &e) {
            emit error(QString(e.what()));
        }
    }

}

void Barcode::close() {
    if (impl->isOpen()) {
        try {
            impl->close();
            emit openedChanged(false);
        } catch(const std::exception &e) {
            emit error(QString(e.what()));
        }
    }
}

bool Barcode::isOpen() const {
    return impl->opened;
}

void Barcode::execute(const QString& command, const QString &args) {


    if (command == "IMAGE.SEND") {
        emit received(command, "qrc:/assets/refresh.png");
    }

    if (command == "TRIGGER ON") {
        emit received(command, "TM0000191");
    }

    if (command == "GET CAMERA.EXPOSURE") {

    }

    if (command == "SET CAMAERA.EXPOSURE") {

    }

}

QString Barcode::port() const {
    return impl->serial.port;
}

void Barcode::setPort(QString port) {
    if (impl->serial.port != port) {
        impl->serial.port = std::move(port);
        emit portChanged(impl->serial.port);
    }
}

QString Barcode::baud() const {
    return QString::number(impl->serial.baud);
}

void Barcode::setBaud(QString baud) {
    auto baudNumber = baud.toLong();
    auto baudEnum = QSerialPort::UnknownBaud;

    switch (baudNumber) {
    case 1200: case 2400: case 4800: case 9600:
    case 19200: case 38400: case 57600: case 115200:
        baudEnum = QSerialPort::BaudRate(baudNumber);
        break;
    default:
        break;
    }

    if (baudEnum != QSerialPort::UnknownBaud
            &&  baudEnum!= impl->serial.baud) {
        impl->serial.baud = baudEnum;
        emit baudChanged(baud);
    }
}

QString Barcode::databits() const {
    return QString::number(impl->serial.databits);
}

void Barcode::setDatabits(QString databits) {
    auto databitsEnum = QSerialPort::UnknownDataBits;
    auto databitsNumber = databits.toInt();
    switch (databitsNumber) {
    case 5: case 6: case 7: case 8:
        databitsEnum = QSerialPort::DataBits(databitsNumber);
        break;
    default:
        break;
    }

    if (databitsEnum != QSerialPort::UnknownDataBits
            && databitsEnum != impl->serial.databits) {
        impl->serial.databits = databitsEnum;
        emit databitsChanged(databits);
    }
}

QString Barcode::stopbits() const {
    return QString::number(impl->serial.stopbits);
}

void Barcode::setStopbits(QString stopbits) {
    auto stopbitsEnum = QSerialPort::StopBits::UnknownStopBits;

    if (stopbits == "1") stopbitsEnum = QSerialPort::StopBits::OneStop;
    if (stopbits == "1.5") stopbitsEnum = QSerialPort::StopBits::OneAndHalfStop;
    if (stopbits == "2") stopbitsEnum = QSerialPort::StopBits::TwoStop;


    if (stopbitsEnum != QSerialPort::StopBits::UnknownStopBits
            && stopbitsEnum != impl->serial.stopbits) {
        impl->serial.stopbits = stopbitsEnum;
        emit stopbitsChanged(stopbits);
    }
}

QString Barcode::parity() const {
    switch (impl->serial.parity) {
    case QSerialPort::Parity::NoParity :
        return tr("无校验");
    case QSerialPort::Parity::OddParity :
        return tr("奇校验");
    case QSerialPort::Parity::EvenParity :
        return tr("偶校验");
    default:
        break;
    }
    return "";
}

void Barcode::setParity(QString parity) {
    auto parityEnum = QSerialPort::Parity::UnknownParity;

    if (parity == "无校验" || parity == "None") {
        parityEnum = QSerialPort::Parity::NoParity;
    }

    if (parity == "奇校验" || parity == "Odd") {
        parityEnum = QSerialPort::Parity::OddParity;
    }

    if (parity == "偶校验" || parity == "Even") {
        parityEnum = QSerialPort::Parity::EvenParity;
    }

    if (parityEnum != QSerialPort::Parity::UnknownParity && parityEnum != impl->serial.parity) {
        impl->serial.parity = parityEnum;
        emit parityChanged(parity);
    }
}

QString Barcode::txTopic() const {
    return impl->ros.txTopic;
}

void Barcode::setTxTopic(QString topic) {
    if (impl->ros.txTopic != topic) {
        impl->ros.txTopic = std::move(topic);
        emit txTopicChanged(impl->ros.txTopic);
    }
}

QString Barcode::rxTopic() const {
    return impl->ros.rxTopic;
}

void Barcode::setRxTopic(QString topic) {
    if (impl->ros.rxTopic != topic) {
        impl->ros.rxTopic = std::move(topic);
        emit rxTopicChanged(impl->ros.rxTopic);
    }
}
}
