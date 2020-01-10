import QtQuick 2.9
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.11
import org.iplusbot.Qt 1.0

ApplicationWindow {
    visible: true
    width: 1024
    height: 600
    id: app
    title: "迦智条形码识别器调试工具"
    x: (Screen.width - app.width) / 2
    y: (Screen.height - app.height) / 2
//    visibility: Window.FullScreen

    Barcode {
        id: bcr

        onReceived: {
            console.log(command, data)

            if (command === 'IMAGE.SEND') {
                image.source = data
                imageArea.isRefreshing = false
            }

            if (command === 'TRIGGER ON') {
                showError(data)
            }
        }

        onError: {
            showError(message)
            imageArea.isRefreshing = false
        }
    }

    Timer {
        id: timer;
    }

//    property int workMode: 0

    function min(left, right) {
        return left < right ? left: right
    }

    function showError(message) {
        errorMessage.text = message;
        error.open();
    }

    function showSerialConfig() {
        if (bcr.mode === 0) {
            if (bcr.isOpen()) {
                showError("请先关闭串口")
            } else {
                serialConfig.open();
            }
        }
    }

    function showRosConfig() {
        if (bcr.mode !== 0) {
            rosConfig.open()
        }
    }

    function setTimeout(delay, func) {
        timer.repeat = false;
        timer.interval = delay;
        timer.triggeredOnStart = false
        timer.triggered.connect(func)
        timer.start()
    }

    function toggleBCR() {
        if (bcr.opened) bcr.close()
        else bcr.open()
    }

    function quit() {
        app.close()
    }

    menuBar: MenuBar {
        id: mainMenu

        width: parent.width

        Menu {
            title: qsTr("文件(&F)")

            Action {
                text: bcr.opened ? qsTr("断开(&C)"): qsTr("连接(&C)")

                onTriggered: {
                    toggleBCR()
                }
            }

            Action {
                text: qsTr("退出(&Q)")
                onTriggered: {
                    quit()
                }
            }
        }

        Menu {
            title: qsTr("编辑(&E)")
            Menu {
                title: qsTr("模式切换(&S)")

                MenuItem {
                    text: qsTr("串口模式(&P)")
                    onClicked:  {
                       bcr.setMode(0)
                    }
                }

                MenuItem {
                    text: qsTr("对接模式(&R)")
                    onClicked:  {
                       bcr.setMode(1)
                    }
                }
            }
        }
        Menu {
            title: qsTr("工具(&T)")

            MenuItem {
                text:bcr.mode === 0 ? qsTr("串口设置"): qsTr("对接参数设置")
                onClicked: {
                    if (bcr.mode === 0) showSerialConfig()
                    else showRosConfig()
                }
            }
        }
        Menu {
            title: qsTr("帮助(&H)")
            Action {
                text: "关于(&B)"
            }
        }

    }

    Rectangle {
        id: left
        width: 66
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        color: "#666"

        property int currentIndex: swiper.currentIndex

        Column {
            anchors.fill: parent

            Button {
                height: 40
                text: qsTr("图像")
                width: parent.width
                checked: left.currentIndex === 0
                background: Rectangle {
                    color: parent.checked ? "#333": parent.hovered ? "#777": "#666"
                }

                onClicked: {
                    swiper.setCurrentIndex(0)
                }
            }

            Button {
                height: 40
                text: qsTr("配置")
                width: parent.width
                checked: left.currentIndex === 1

                background: Rectangle {
                     color: parent.checked ? "#333": parent.hovered ? "#777": "#666"
                }

                onClicked: {
                    swiper.setCurrentIndex(1)
                }
            }

            Button {
                height: 40
                text: qsTr("调试")
                width: parent.width
                checked: left.currentIndex === 2
                background: Rectangle {
                     color: parent.checked ? "#333": parent.hovered ? "#777": "#666"
                }

                onClicked: {
                    swiper.setCurrentIndex(2)
                }
            }
        }
    }

    SwipeView {

        id: swiper
        anchors.fill: parent
        anchors.leftMargin: 66

        currentIndex: left.currentIndex


        orientation: Qt.Vertical

        Page {
            title: "camera"

            background:  Rectangle {
                color: "brown"

                Rectangle {
                    id: imageArea
                    color: "lightgray"

                    x: 8
                    y: 8
                    width: 320
                    height: 240

                    property bool isRefreshing: false
                    property bool refreshVisible: false

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: {
                            imageArea.refreshVisible  = refreshButton.hovered || true
                        }

                        onExited: {
                            imageArea.refreshVisible = refreshButton.hovered || false
                        }

                    }

                    Image {
                        id: image
                        source: ""
                        anchors.fill: parent
                        anchors.margins: 8
                    }

                    Button {
                        id: refreshButton
                        width: 44
                        height: 44
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 8

                        visible: imageArea.refreshVisible
                        background: Rectangle {
                            color: "gray"
                            radius: 22
                            Image {
                                anchors.fill: parent
                                source: "qrc:/assets/refresh.png"


                                RotationAnimation on rotation {
                                    running: imageArea.isRefreshing
                                    loops: Animation.Infinite
                                    from: 0
                                    to: 360
                                    duration: 1000
                                }
                            }
                        }

                        onClicked: {
                            imageArea.isRefreshing = true
                            bcr.execute("IMAGE.SEND")
                        }
                    }
                }

                Rectangle {
                    id: right
                    color: "#666"
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: expand ? parent.width * 0.2: 10

                    property bool expand: false

                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom

                        width: 10
                        color: "#333"

                        Button {

                            id: rightSimplifyButton
                            hoverEnabled: true

                            width: parent.width
                            height: parent.height

                            background: Rectangle {
                                color: parent.hovered ? "#333" :"#666"
                            }

                            onClicked:  {
                                right.expand = !right.expand
                            }

                        }
                    }
                }

            }
        }


        Page {
            title: "Home"
            background: Rectangle {
                color: "green"
            }
        }

        Page {
            title: "config"
            background: Rectangle {
                color: "purple"
            }
        }
    }

    Rectangle {
        id: status
        color: "#555"
        height: 28
        width: parent.width
        anchors.bottom: parent.bottom

        Row {
            spacing: 8
            leftPadding: 8


            Text {
                color: "white"
                text: bcr.opened ? qsTr("已连接"): qsTr("未连接")

                MouseArea {
                    anchors.fill: parent
                    onClicked:  {
                        toggleBCR()
                    }
                }
            }

            Rectangle {
                color: "transparent"
                height: parent.height
                width: parent.height
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    anchors.centerIn: parent
                    color: bcr.opened ? "cyan": "gray"
                }
            }


            Text {
                color: "white"
                text: bcr.mode === 0 ? qsTr("串口模式"): qsTr("对接模式")
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        if (mouse.button === Qt.LeftButton) {
                            if (bcr.mode === 0) {
                                showSerialConfig()
                            } else {
                                showRosConfig()
                            }
                        }

                        if (mouse.button === Qt.RightButton) {
                            modeSwitch.open()
                        }
                    }
                }
            }


            Text {
                color: "white"
                text: bcr.mode === 0 ? qsTr("端口: %1    波特率: %2    数据位: %3    停止位: %4    校验位: %5")
                                       .arg(bcr.port)
                                       .arg(bcr.baud)
                                       .arg(bcr.databits)
                                       .arg(bcr.stopbits)
                                       .arg(bcr.parity)
                                     : qsTr("发送主题: %1    接收主题： %2")
                                       .arg(bcr.txTopic)
                                       .arg(bcr.rxTopic)

            }

        }
    }



    Popup {
        id: serialConfig
        width: 512
        height: 300
        x: (app.width - width) / 2
        y: (app.height - height) / 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent


        background: Rectangle {
            color: "#1859b5"



            Rectangle {
                height: 44
                anchors.top: parent.top
                width: parent.width
                color: "#333"


                Text {
                    color: "white"
                    text: qsTr("串口设置")
                    anchors.leftMargin: 8
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Button {
                    width: 44
                    height: 44
                    anchors.right: parent.right
                    anchors.rightMargin: 44

                    text: "√"


                    background: Rectangle {
                        color: "#4b80f3"
                    }

                    onClicked: {
                        serialConfig.close()
                        bcr.setPort(cbxPort.currentText)
                        bcr.setBaud(cbxBaud.currentText)
                        bcr.setDatabits(cbxDatabits.currentText)
                        bcr.setStopbits(cbxStopbits.currentText)
                        bcr.setParity(cbxParity.currentText)
                    }
                }

                Button {
                    width: 44
                    height: 44
                    anchors.right: parent.right

                    text: "×"
                    font.pixelSize: 22
                    background: Rectangle {
                        color: "green"
                    }
                    onClicked: {
                        serialConfig.close()
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 44
                color: "transparent"

                Column {
                    anchors.centerIn:  parent

                    Row {
                        spacing: 20
                        Text {
                            color: "white"
                            height: parent.height
                            text: qsTr("串口号: ")
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        ComboBox {
                            id: cbxPort
                            width: 200
                            editable: true
                            model: ["/dev/ttyS0", "/dev/ttyS1", "/dev/ttyS3"]

                            currentIndex: model.indexOf(bcr.port)

                        }
                    }

                    Row {
                        spacing: 20
                        Text {
                            color: "white"
                            height: parent.height
                            text: qsTr("波特率: ")
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        ComboBox {
                            id: cbxBaud
                            width: 200
                            model: ["1200", "2400", "4800", "9600", "19200", "38400",  "57600", "115200"]
                            currentIndex: model.indexOf(bcr.baud)

                        }
                    }

                    Row {
                        spacing: 20
                        Text {
                            color: "white"
                            height: parent.height
                            text: qsTr("数据位: ")
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        ComboBox {
                            id: cbxDatabits
                            width: 200
                            model: ["5", "6", "7", "8", "9"]
                            currentIndex: model.indexOf(bcr.databits)

                        }
                    }

                    Row {
                        spacing: 20
                        Text {
                            color: "white"
                            height: parent.height
                            text: qsTr("停止位: ")
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        ComboBox {
                            id: cbxStopbits
                            width: 200
                            model: ["1", "1.5", "2"]
                            currentIndex: model.indexOf(bcr.stopbits)

                        }
                    }

                    Row {
                        spacing: 20
                        Text {
                            color: "white"
                            height: parent.height
                            text: qsTr("校验位: ")
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        ComboBox {
                            id: cbxParity
                            width: 200
                            model: ["无校验", "奇校验", "偶校验"]

                            currentIndex: model.indexOf(bcr.parity)

                        }
                    }
                }
            }
        }
    }

    Popup {
        id: rosConfig
        width: 512
        height: 200
        x: (app.width - width) / 2
        y: (app.height - height) / 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent

        background: Rectangle {
            color: "#1859b5"
            Rectangle {
                height: 44
                anchors.top: parent.top
                width: parent.width
                color: "#333"

                Text {
                    color: "white"
                    text: qsTr("对接ROS参数设置")
                    anchors.leftMargin: 8
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Button {
                    width: 44
                    height: 44
                    anchors.right: parent.right
                    anchors.rightMargin: 44

                    text: "√"


                    background: Rectangle {
                        color: "#4b80f3"
                    }
                    onClicked: {
                        rosConfig.close()
                    }
                }

                Button {
                    width: 44
                    height: 44
                    anchors.right: parent.right

                    text: "×"
                    font.pixelSize: 22
                    background: Rectangle {
                        color: "green"
                    }
                    onClicked: {
                        rosConfig.close()
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 44
                color: "transparent"
                Column {
                    spacing: 8
                    anchors.centerIn: parent
                    Row {
                        spacing: 20
                        Text {
                            color: "white"
                            height: 44
                            text: qsTr("发送Topic: ")
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Rectangle {
                            color: "transparent"
                            height: 44
                            width: 280
                            border.color: "gray"
                            TextEdit {
                                id: txTopicText
                                anchors.fill: parent
                                color: "white"
                                font.pointSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                Text {
                                    anchors.fill: parent
                                    color: "gray"
                                    text: '/jzhw/serial/bcr/tx'
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    visible: txTopicText.text.length === 0
                                }
                            }
                        }
                    }

                    Row {
                        spacing: 20
                        Text {
                            color: "white"
                            height: 44
                            text: qsTr("接收Topic: ")
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Rectangle {
                            color: "transparent"
                            height: 44
                            width: 280
                            border.color: "gray"
                            TextEdit {
                                id: rxTopicText
                                color: "white"
                                font.italic: true
                                font.pointSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                anchors.fill: parent
                                Text {
                                    anchors.fill: parent
                                    color: "gray"
                                    text: '/jzhw/serial/bcr/rx'
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    visible: rxTopicText.text.length === 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: modeSwitch

        width: 220
        height: 88
        x: (app.width - width) / 2
        y: (app.height - height) / 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent
        background: Rectangle {
            color: "#1859b5"
            Rectangle {
                height: 36
                width: parent.width
                anchors.top: parent.top
                color: "#333"

                Text {
                    color: "white"
                    text: qsTr("模式切换")
                    anchors.leftMargin: 8
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Button {
                    width: 36
                    height: 36
                    anchors.right: parent.right

                    text: "×"
                    font.pixelSize: 22
                    background: Rectangle {
                        color: "green"
                    }
                    onClicked: {
                        modeSwitch.close()
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 36
                color: "transparent"

                Row {
                    anchors.centerIn: parent

                    RadioButton {
                        text: qsTr("串口模式")
                        checked: bcr.mode === 0
                        onCheckedChanged: {
                            if (checked) {
                                bcr.setMode(0)
                                modeSwitch.close()
                            }
                        }
                    }

                    RadioButton {
                        text: qsTr("对接模式")
                        checked: bcr.mode === 1
                        onCheckedChanged: {
                            if (checked) {
                                bcr.setMode(1)
                                modeSwitch.close()
                            }
                        }
                    }
                }
            }


        }

    }

    Popup {
        id: error
        width: app.width * 0.6
        height: 44
        x: (app.width - width) * 0.5
        y: 1

        background: Rectangle {
            color: "#333"
            radius: 6

            Text {
                text: ""
                color: "red"
                id: errorMessage
                font.pointSize: 12
                anchors.centerIn: parent
                verticalAlignment: Text.AlignVCenter
            }
        }

        onOpened: {
            setTimeout(1000, function() {
                error.close();
            })
        }
    }

}

/*##^## Designer {
    D{i:11;invisible:true}
}
 ##^##*/
