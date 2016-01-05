#include "collection.h"
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QSettings>
#include <QTimer>
#include <QElapsedTimer>
#include <QCoreApplication>
#include <QQmlEngine>
#include "page.h"

#define RECENTLY_USED_KEY "RecentlyUsed"

Collection::Collection(QObject *parent) : QObject(parent)
{
#ifdef Q_PROCESSOR_ARM
    m_basePath = "/data/documents/";
#else// Q_PROCESSOR_ARM
    m_basePath = "/home/sandsmark/xo/testdata";
#endif// Q_PROCESSOR_ARM

    connect(QCoreApplication::instance(), SIGNAL(aboutToQuit()), &m_imageloadingThread, SLOT(quit()));
    m_imageloadingThread.start(QThread::LowestPriority);
}

QStringList Collection::folderEntries(QString path) const
{
    if (path.isEmpty()) {
        path = m_basePath;
    }

    QDir dir(path);
    QFileInfoList files = dir.entryInfoList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot);
    QStringList paths;
    for (const QFileInfo file : files) {
        paths.append(file.absoluteFilePath());
    }
    return paths;
}

bool Collection::isFolder(const QString &path, const QString &name) const
{
    return !QFile::exists(m_basePath + '/' + path + '/' + name + '/' + "metadata.dat");
}

QList<QObject *> Collection::getPages(const QString &path)
{
    QList<QObject *> pages;

    QDir dir(path);
    if (!dir.exists()) {
        qWarning() << Q_FUNC_INFO << "Asked for non-existing path" << path;
        return pages;
    }
    QFileInfoList fileList = dir.entryInfoList(QStringList() << "*.png");

    for(const QFileInfo &file : fileList) {
        Page *page = new Page(file.absoluteFilePath());
        page->moveToThread(&m_imageloadingThread);
        //QMetaObject::invokeMethod(page, "loadBackground");
        QTimer::singleShot(100, page, SLOT(loadBackground()));
        QQmlEngine::setObjectOwnership(page, QQmlEngine::JavaScriptOwnership);
        pages.append(page);
    }

    return pages;
}

QStringList Collection::recentlyUsedPaths() const
{
    QSettings settings;
    QStringList recentlyUsed = settings.value(RECENTLY_USED_KEY).toStringList();

    if (recentlyUsed.isEmpty()) {
        return QStringList() << m_basePath + "/Local/dijkstra.pdf"
                             << m_basePath + "/Local/jantu.pdf"
                             << m_basePath + "/Dropbox/images.zip";
    } else {
        return recentlyUsed;
    }
}

QString Collection::thumbnailPath(const QString &documentPath) const
{
    QDir dir(documentPath);
    QFileInfoList fileList = dir.entryInfoList(QStringList() << "*.png", QDir::Files, QDir::Name);
    if (fileList.isEmpty()) {
        qWarning() << Q_FUNC_INFO << "No images in path" << documentPath;
        return QString();
    }
    return fileList.first().absoluteFilePath();
}

QString Collection::title(const QString &documentPath) const
{
    QDir dir(documentPath);
    return dir.dirName();
}
