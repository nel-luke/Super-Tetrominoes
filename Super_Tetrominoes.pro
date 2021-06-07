QT += quick quickcontrols2 multimedia network

CONFIG += c++17 qt qmltypes warn_on resources_big

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

win32 {
 LIBS += -LC:\Qt\Tools\openssl_32\lib -lcrypto -lssl
 INCLUDEPATH += C:\Qt\Toolsopenssl_32\include
}

RC_ICONS += resources/textures/icon.ico

wasm {
 QMAKE_LFLAGS += -s BINARYEN_TRAP_MODE=clamp -s TOTAL_STACK=64mb -s TOTAL_MEMORY=192mb
 QTPLUGIN += qsvg
}


INCLUDEPATH += include/
HEADERS = \
    include/c_shapes.h \
    include/tetrogridq.h \
    include/tetroclientq.h
SOURCES = \
    src/main.cpp \
    src/tetrogridq.cpp \
    src/tetroclientq.cpp

RESOURCES = \
    resources/qml/qml.qrc \
    resources/js/js.qrc \
    resources/textures/textures.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_NAME = "Custom"
QML_IMPORT_PATH += "/"
QML_IMPORT_MAJOR_VERSION = 1

DISTFILES +=
