import QtQuick 2.3
import QtQuick.Window 2.2
import com.magmacompany 1.0

Window {
    id: window
    visible: true
    height: 1200
    width: 1600
    flags: Qt.Dialog

    property string inactiveColor: "black"
    property string fontColor: "black"
    property string inactiveFontColor: "white"

    Item {
        id: rootItem
        anchors.centerIn: parent
        width: (rotation === 0) ? parent.width : parent.height
        height: (rotation === 0) ? parent.height : parent.width
        rotation: Settings.getValue(Settings.Rotation, 270)

        property bool focusMode: false

        function rotateScreen() {
            if (rotation === 270) {
                rotation = 0
            } else {
                rotation = 270
            }
            Settings.setValue(Settings.Rotation, rotation)
        }

        function endsWith(string, suffix) {
            return string.indexOf(suffix, string.length - suffix.length) !== -1
        }

        function openDocument(path) {
            var name = Collection.title(path)
            var index = tabBar.tabModel.indexOf(name)

            if (index === -1) {
                var newIndex = tabBar.tabModel.length + 1
                var createdObject;
                if (endsWith(path, ".pdf")) {
                    createdObject = documentComponent.createObject(viewRoot, {"tabIndex": newIndex})
                    createdObject.documentPath = path
                } else {
                    if (name.lastIndexOf("Sketch", 0) === 0) {
                        createdObject = sketchComponent.createObject(viewRoot, {"tabIndex": newIndex})
                    } else {
                        createdObject = noteComponent.createObject(viewRoot, {"tabIndex": newIndex})
                    }
                    createdObject.documentPath = path

                    createdObject.document = Collection.getDocument(path)
                }

                var tabModel = tabBar.tabModel
                tabModel.push(name)
                tabBar.tabModel = tabModel
                tabBar.currentTab = newIndex
                tabBar.objectList.push(createdObject)
            } else {
                tabBar.currentTab = index + 1
            }
        }

        property bool homeRecentlyClicked: false
        Timer {
            id: homeButtonTimer
            onTriggered: {
                tabBar.currentTab = 0
                rootItem.homeRecentlyClicked = false
            }
            interval: 200
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Home) {
                if (rootItem.focusMode) {
                    rootItem.focusMode = false

                } else if(homeRecentlyClicked) {
                    homeButtonTimer.stop()
                    mainScreen.newNoteClicked()
                    homeRecentlyClicked = false
                } else {
                    homeRecentlyClicked = true
                    homeButtonTimer.restart()
                }
                event.accepted = true
                return
            } else if (event.key === Qt.Key_PowerOff) {
                console.log("Poweroff requested")
                shutdownDialog.visible = true
                event.accepted = true
                return
            }
        }

        Component.onCompleted: forceActiveFocus()

        TabBar {
            id: tabBar
            height: rootItem.focusMode ? 0 : 75
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            tabModel: []
        }

        Component {
            id: documentComponent

            DocumentTab {
                visible: tabBar.currentTab === tabIndex
                anchors.fill: parent

                property int tabIndex
            }
        }

        Component {
            id: noteComponent

            NoteTab {
                visible: tabBar.currentTab === tabIndex
                anchors.fill: parent
                property int tabIndex
            }
        }

        Component {
            id: archiveComponent

            ArchiveView {
                id: archiveView
                visible: (tabBar.currentTab === tabIndex)
                anchors.fill: parent
                property int tabIndex

                onOpenBook: {
                    rootItem.openDocument(path)
                }
            }
        }

        Component {
            id: sketchComponent

            SketchTab {
                visible: tabBar.currentTab === tabIndex
                anchors.fill: parent
                property int tabIndex
            }
        }

        Item {
            id: viewRoot

            anchors {
                top: tabBar.bottom
                right: parent.right
                left: parent.left
                bottom: parent.bottom
            }

            MainScreen {
                id: mainScreen
                anchors.fill: parent
                visible: (tabBar.currentTab === 0)

                onNewNoteClicked: {
                    var newIndex = tabBar.tabModel.length + 1
                    var createdObject = noteComponent.createObject(viewRoot, {"tabIndex": newIndex})
                    createdObject.document = Collection.createDocument("Lined")
                    var tabModel = tabBar.tabModel
                    tabModel.push(Collection.title(createdObject.document.path()))
                    tabBar.tabModel = tabModel
                    tabBar.currentTab = newIndex
                    tabBar.objectList.push(createdObject)
                }

                onNewSketchClicked: {
                    var newIndex = tabBar.tabModel.length + 1
                    var createdObject = sketchComponent.createObject(viewRoot, {"tabIndex": newIndex})
                    createdObject.document = Collection.createDocument("Sketch")
                    var tabModel = tabBar.tabModel
                    tabModel.push(Collection.title(createdObject.document.path()))
                    tabBar.tabModel = tabModel
                    tabBar.currentTab = newIndex
                    tabBar.objectList.push(createdObject)
                }

                onArchiveClicked: {
                    console.time("archiveclicked")
                    var index = tabBar.tabModel.indexOf("ARCHIVE")

                    if (index === -1) {
                        var newIndex = tabBar.tabModel.length + 1
                        var createdObject = archiveComponent.createObject(viewRoot, {"tabIndex": newIndex })
                        var tabModel = tabBar.tabModel
                        tabModel.push("ARCHIVE")
                        tabBar.tabModel = tabModel
                        tabBar.currentTab = newIndex
                        tabBar.objectList.push(createdObject)
                    } else {
                        tabBar.currentTab = index + 1
                    }
                    console.timeEnd("archiveclicked")
                }

                onOpenBook: {
                    rootItem.openDocument(path)
                }
            }

        }

        Rectangle {
            id: debugWindow
            visible: false
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            width: 150
            height: 20

            Text {
                anchors.fill: parent
                text: SystemMonitor.memoryUsed + " MB used"
            }
        }

        Rectangle {
            id: grayOverlay
            anchors.fill: parent
            color: "#7f000000"
            visible: shutdownDialog.visible
        }

        Rectangle {
            id: shutdownDialog
            anchors.centerIn: parent
            width: 750
            height: 400
            border.width: 5
            radius: 10
            color: "white"
            visible: false

            Image {
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    topMargin: parent.height / 4 - height / 2
                }
                source: "qrc:/icons/Power-off.svg"
                height: 50
                width: height
            }

            Text {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.verticalCenter
                }

                text: "Are you sure you want to shut down?"
                font.pointSize: 18
                wrapMode: Text.Wrap
            }

            Item {
                anchors {
                    right: parent.horizontalCenter
                    left: parent.left
                    bottom: parent.bottom
                    top: parent.verticalCenter
                }

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/icons/yes.svg"
                    height: 100
                    width: height
                    MouseArea {
                        enabled: shutdownDialog.visible
                        anchors.fill: parent
                        onClicked: Qt.quit()
                    }
                }
            }

            Item {
                anchors {
                    left: parent.horizontalCenter
                    right: parent.right
                    bottom: parent.bottom
                    top: parent.verticalCenter
                }

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/icons/no.svg"
                    height: 100
                    width: height
                    MouseArea {
                        enabled: shutdownDialog.visible
                        anchors.fill: parent
                        onClicked: shutdownDialog.visible = false
                    }
                }
            }
        }
    }
}
