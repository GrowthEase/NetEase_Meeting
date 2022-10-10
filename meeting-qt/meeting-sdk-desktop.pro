TEMPLATE = subdirs

SUBDIRS += \
    meeting-ui-sdk \
    meeting-app

meeting-app.depends = meeting-ui-sdk
