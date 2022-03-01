TEMPLATE = subdirs

SUBDIRS += \
    meeting-ui-sdk \
    #meeting-plugins \
    #meeting-plugins-sample \
    meeting-app

meeting-app.depends = meeting-ui-sdk
meeting-plugins-sample.depends = meeting-plugins
