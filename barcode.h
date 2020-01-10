#ifndef BARCODE_H
#define BARCODE_H

#include <QObject>
#include <QVariant>

#include <memory>



namespace bcr {

struct BarcodeImpl;

class Barcode : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(unsigned mode READ mode WRITE setMode NOTIFY modeChanged)

    Q_PROPERTY(bool opened READ isOpen NOTIFY openedChanged)

    Q_PROPERTY(QString port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(QString baud READ baud WRITE setBaud NOTIFY baudChanged)
    Q_PROPERTY(QString databits READ databits WRITE setDatabits NOTIFY databitsChanged)
    Q_PROPERTY(QString stopbits READ stopbits WRITE setStopbits NOTIFY stopbitsChanged)
    Q_PROPERTY(QString parity READ parity WRITE setParity NOTIFY parityChanged)

    Q_PROPERTY(QString txTopic READ txTopic WRITE setTxTopic NOTIFY txTopicChanged)
    Q_PROPERTY(QString rxTopic READ rxTopic WRITE setRxTopic NOTIFY rxTopicChanged)

public:
    Barcode();
    virtual ~Barcode();

    unsigned mode() const;

    QString port() const;
    QString baud() const;
    QString databits() const;
    QString stopbits() const;
    QString parity() const;

    QString txTopic() const;
    QString rxTopic() const;

public slots:

    void setMode(unsigned mode);
    void setPort(QString port);
    void setBaud(QString baud);
    void setDatabits(QString databits);
    void setStopbits(QString stopbits);
    void setParity(QString parity);

    void setTxTopic(QString topic);
    void setRxTopic(QString topic);

    void open();
    void close();

    bool isOpen() const;

    void execute(const QString& command, const QString& args = QString{});

signals:
    void modeChanged(unsigned);
    void openedChanged(bool);

    void portChanged(QString);
    void baudChanged(QString);
    void databitsChanged(QString);
    void stopbitsChanged(QString);
    void parityChanged(QString);

    void txTopicChanged(QString);
    void rxTopicChanged(QString);

    void received(QString command, QVariant data);

    void error(QString message);

private:
    std::shared_ptr<BarcodeImpl> impl;
};

}


#endif
