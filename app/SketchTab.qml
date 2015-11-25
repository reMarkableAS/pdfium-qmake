import QtQuick 2.0
import com.magmacompany 1.0

Rectangle {
    DrawingArea {
        id: drawingArea
        anchors.fill: parent
        currentBrush: DrawingArea.Paintbrush
    }

    Column {
        id: toolBox
        width: 75
        height: 100
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 5
            topMargin: 100
        }
        Rectangle {
            width: parent.width
            height: width
            border.width: 1

            Image {
                anchors.fill: parent
                anchors.margins: 5
                source: (drawingArea.currentBrush === DrawingArea.Paintbrush) ?
                            "qrc:/icons/paintbrush.png" : "qrc:/icons/pencil.png"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    penToolList.visible = !penToolList.visible
                }
            }
        }
        Rectangle {
            width: parent.width
            height: width
            color: "white"
            border.width: 1

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "CLEAR"
                font.pointSize: 7
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        drawingArea.clear()
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: width
            color: "white"
            border.width: 1

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "UNDO"
                font.pointSize: 7
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        drawingArea.undo()
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: width
            color: "white"
            border.width: 1

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "REDO"
                font.pointSize: 7
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        drawingArea.redo()
                    }
                }
            }
        }


        Rectangle {
            id: zoomTool
            width: parent.width
            height: width
            border.width: 1

            property int zoomQuadrant: -1

            function zoomIn(quadrant) {
                if (quadrant === zoomQuadrant) {
                    drawingArea.setZoom(0, 0, 1, 1)
                    zoomQuadrant = -1
                } else if (quadrant === 0) {
                    drawingArea.setZoom(0, 0, 0.5, 0.5)
                    zoomQuadrant = 0
                } else if (quadrant === 1) {
                    drawingArea.setZoom(0.5, 0, 0.5, 0.5)
                    zoomQuadrant = 1
                } else if (quadrant === 2) {
                    drawingArea.setZoom(0, 0.5, 0.5, 0.5)
                    zoomQuadrant = 2
                } else if (quadrant === 3) {
                    drawingArea.setZoom(0.5, 0.5, 0.5, 0.5)
                    zoomQuadrant = 3
                }
            }

            Image {
                width: parent.width / 2
                height: width
                anchors.left: parent.left
                anchors.top: parent.top
                source: zoomTool.zoomQuadrant === 1 ? "qrc:/icons/zoom-out.png" : "qrc:/icons/zoom-in.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        zoomTool.zoomIn(1)
                    }
                }
            }
            Image {
                width: parent.width / 2
                height: width
                anchors.right: parent.right
                anchors.top: parent.top
                property bool zoomedIn: false
                source: zoomTool.zoomQuadrant === 3 ? "qrc:/icons/zoom-out.png" : "qrc:/icons/zoom-in.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        zoomTool.zoomIn(3)
                    }
                }
            }
            Image {
                width: parent.width / 2
                height: width
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                property bool zoomedIn: false
                source: zoomTool.zoomQuadrant === 0 ? "qrc:/icons/zoom-out.png" : "qrc:/icons/zoom-in.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        zoomTool.zoomIn(0)
                    }
                }
            }
            Image {
                width: parent.width / 2
                height: width
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                property bool zoomedIn: false
                source: zoomTool.zoomQuadrant === 2 ? "qrc:/icons/zoom-out.png" : "qrc:/icons/zoom-in.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        zoomTool.zoomIn(2)
                    }
                }
            }
        }
    }

    Row {
        id: penToolList
        visible: false
        height: 75
        width: 300
        anchors {
            top: toolBox.top
            left: toolBox.right
        }

        Rectangle {
            id: thickBrushSelect
            height: parent.height
            width: height
            border.width: 1

            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: "qrc:/icons/paintbrush.png"
            }


            MouseArea {
                anchors.fill: parent
                onClicked: {
                    drawingArea.currentBrush = DrawingArea.Paintbrush
                    penToolList.visible = false
                }
            }
        }

        Rectangle {
            id: thinBrushSelect
            height: parent.height
            width: height
            border.width: 1


            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: "qrc:/icons/pencil.png"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    drawingArea.currentBrush = DrawingArea.Pencil
                    penToolList.visible = false
                }
            }
        }
    }
}

