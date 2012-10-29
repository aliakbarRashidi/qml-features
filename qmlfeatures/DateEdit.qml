import QtQuick 1.1
import QtDesktop 0.1
import QmlFeatures 1.0
import "common/utils.js" as QmlFeatureUtils

FocusScope {
    id: dateEdit
    width: dateField.width
    height: dateField.height
    focus: false
    property date date
    property alias font: dateField.font
    property string dateFormat: "dd.MM.yyyy"
    property alias inputMask: dateField.inputMask
    property alias textColor: dateField.textColor
    property alias fieldWidth: dateField.width
    property alias fieldHeight: dateField.height
    property Item  ___datePicker

    onFocusChanged: {
        if (dateEdit.activeFocus)
            dateField.forceActiveFocus();
    }

    function fnOpenCalendar(myFocus) {
        if (!myFocus) {
            fnCloseCalendar(date, false)
        } else {
            var theDate = QmlUtil.parseDate(dateField.text, dateFormat)

            if (!QmlFeatureUtils.fnIsValidDate(date)) {
                theDate = new Date()
            }

            var container = QmlFeatureUtils.fnGetItemRoot(dateField)

            ___datePicker = datePicker.createObject(container,
                                                    {dateField: dateField,
                                                        pickedDate: theDate, opacity: 0})
            ___datePicker.opacity = 1
            dateField.cursorPosition = 0

        }
    }

    function fnCloseCalendar(pickedDate, clear) {
        if (Qt.isQtObject(___datePicker)) {
            ___datePicker.opacity = 0
            ___datePicker.destroy(500)
        }

        if (clear) dateField.text = ""
        if (QmlFeatureUtils.fnIsValidDate(pickedDate)) {
            dateField.text = Qt.formatDate(pickedDate, dateFormat)
            date = pickedDate
        }

    }

    TextField {
        id:dateField

        Keys.onEscapePressed: fnCloseCalendar(date, true)
        Keys.onReturnPressed: fnCloseCalendar(QmlUtil.parseDate(text, dateFormat), false)
        Keys.onTabPressed: {
            fnCloseCalendar(QmlUtil.parseDate(text, dateFormat), false)
            event.accepted = false
        }

        onActiveFocusChanged: {
            if (!parent.focus)
                fnOpenCalendar(parent.focus)
        }
    }
    CursorArea {
        anchors.fill: parent

        cursor: Qt.ArrowCursor
    }
    Image {
        source: "images/calendar.svg"
        width: 16
        height: 16
        anchors.verticalCenter: dateField.verticalCenter
        anchors.right: dateField.right
        anchors.rightMargin: 5

        MouseArea {
            anchors.fill: parent
            onClicked: fnOpenCalendar(true)
        }

    }


    Component {
        id: datePicker
        DatePicker {
            Component.onCompleted: {
                opacity = 1
                var pos = dateField.mapToItem(parent, dateField.x, dateField.y)
                x = pos.x+20
                y = pos.y + dateField.height + 15
            }

            onDayPicked: {
                fnCloseCalendar(pickedDate, false)
            }

            Behavior on opacity {
                NumberAnimation { duration: 200}
            }

            CursorArea {
                anchors.fill: parent
                cursor: CursorArea.ArrowCursor
            }
        }

    }

}
