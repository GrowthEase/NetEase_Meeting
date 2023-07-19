// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef VIDEO_RENDER_H
#define VIDEO_RENDER_H

#include <QOpenGLFunctions>
#include <QQuickFramebufferObject>
#include <QVideoFrame>

QT_FORWARD_DECLARE_CLASS(QTimer)
QT_FORWARD_DECLARE_CLASS(QOpenGLTexture)
QT_FORWARD_DECLARE_CLASS(QOpenGLContext)
QT_FORWARD_DECLARE_CLASS(QOpenGLBuffer)
QT_FORWARD_DECLARE_CLASS(QOpenGLShaderProgram)

class I420Render;
class VideoRender : public QQuickFramebufferObject {
    Q_OBJECT
    Q_PROPERTY(QString accountId READ accountId WRITE setAccountId NOTIFY accountIdChanged)
    Q_PROPERTY(bool subVideo READ subVideo WRITE setSubVideo NOTIFY subVideoChanged)
    Q_PROPERTY(QString uuid READ uuid)

public:
    explicit VideoRender(QQuickItem* parent = nullptr);
    ~VideoRender();
    Renderer* createRenderer() const override;
    QVideoFrame& getFrame();  // 用于在创建的Renderer中访问当前帧的图像数据

    QString accountId() const;
    void setAccountId(const QString& accountId);

    bool subVideo() const;
    void setSubVideo(bool subVideo);

    QString uuid() const { return m_uuid; }

public slots:
    void deliverFrame(const QString& accountId, const QVideoFrame& frame, const QSize& videoSize, bool sub);

signals:
    void receivedVideoFrame(const QVideoFrame& frame, const QSize& videoSize);
    void accountIdChanged();
    void subVideoChanged();

private:
    QString m_accountId;
    bool m_subVideo = false;
    QString m_uuid;
    QVideoFrame m_videoFrame;
};

////////////////////////////////////////////////////////////////////////////////////////////////////
class VideoFboRender : public QQuickFramebufferObject::Renderer {
public:
    VideoFboRender();
    ~VideoFboRender();

    // 该函数主要从VideoRender中获取数据，用于在render()函数中的渲染;会先调用此函数再调用render
    void synchronize(QQuickFramebufferObject* item) override;
    void render() override;
    QOpenGLFramebufferObject* createFramebufferObject(const QSize& size) override;

private:
    VideoRender* m_pVideoRender = nullptr;
    I420Render* m_pRender = nullptr;
    QQuickWindow* m_window = nullptr;
    int m_itemWidth = 0;
    int m_itemHeight = 0;
};

////////////////////////////////////////////////////////////////////////////////////////////////////
class I420Render : public QObject, public QOpenGLFunctions {
    Q_OBJECT
public:
    I420Render(QObject* pParent = nullptr);
    ~I420Render();
    void render(uchar* nv12Ptr, int w, int h, int itemWidth, int itemHeight, int windowWidth, int windowHeight);  // 渲染当前帧
    void resize(int width, int height);

private:
    QOpenGLShaderProgram* m_pShaderProgram = nullptr;
    QOpenGLBuffer* m_pVBO = nullptr;
    GLuint m_idY = 0;
    GLuint m_idU = 0;
    GLuint m_idV = 0;
    GLuint m_textureUniformY = 0;
    GLuint m_textureUniformU = 0;
    GLuint m_textureUniformV = 0;
    QOpenGLTexture* m_pTextureY = nullptr;
    QOpenGLTexture* m_pTextureU = nullptr;
    QOpenGLTexture* m_pTextureV = nullptr;
};

#endif  // VIDEO_RENDER_H
