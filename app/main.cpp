#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QScreen>
#include <QPainter>

#include "drawingarea.h"
#include "batterymonitor.h"
#include "collection.h"

#ifdef Q_PROCESSOR_ARM
#include "digitizer.h"
#include <epframebuffer.h>

#include <QtPlugin>
Q_IMPORT_PLUGIN(QsgEpaperPlugin)
#endif

int main(int argc, char *argv[])
{
#ifdef Q_PROCESSOR_ARM
    qDebug() << "we're running on an epaper device";
    QCoreApplication::addLibraryPath("/data/lib/");
    qputenv("QMLSCENE_DEVICE", "epaper");
    qputenv("QT_QPA_PLATFORM", "minimal:enable_fonts");
    qputenv("QT_QPA_FONTDIR", "/data/fonts/");
    qputenv("QT_QPA_EVDEV_KEYBOARD_PARAMETERS", "/dev/input/event0");
#endif

    QApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("xochitl"));
    app.setOrganizationName("remarkable");

#ifdef Q_PROCESSOR_ARM
    { // Show loading screen
        QImage *fb = EPFrameBuffer::instance()->framebuffer();
        fb->fill(Qt::white);
        QPainter painter(fb);
        painter.drawText(fb->rect().center(), "Starting...");
        EPFrameBuffer::instance()->sendUpdate(fb->rect(), EPFrameBuffer::Grayscale, EPFrameBuffer::FullUpdate, true);
    }

    if (!Digitizer::initialize("/dev/input/event1")) {
        qWarning() << "Bailing without digitizer";
        return 1;
    }
#endif

    qmlRegisterType<DrawingArea>("com.magmacompany", 1, 0, "DrawingArea");
    qmlRegisterSingletonType<BatteryMonitor>("com.magmacompany", 1, 0, "BatteryMonitor", [](QQmlEngine *, QJSEngine*) -> QObject* {
        return new BatteryMonitor;
    });
    qmlRegisterSingletonType<Collection>("com.magmacompany", 1, 0, "Collection", [](QQmlEngine *, QJSEngine*) -> QObject* {
        return new Collection;
    });

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

