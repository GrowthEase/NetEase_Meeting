// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "video_render.h"

#include <QOpenGLBuffer>
#include <QOpenGLFramebufferObject>
#include <QOpenGLShaderProgram>
#include <QOpenGLTexture>
#include <QTimer>

#define VERTEXIN 0
#define TEXTUREIN 1

VideoRender::VideoRender(QQuickItem* parent)
    : QQuickFramebufferObject(parent) {
    m_uuid = QUuid::createUuid().toString();
}

VideoRender::~VideoRender() {
    disconnect(this, &VideoRender::receivedVideoFrame, 0, 0);
}

void VideoRender::deliverFrame(const QString& accountId, const QVideoFrame& frame, const QSize& videoSize, bool sub) {
    if ((accountId != m_accountId && !accountId.isEmpty()) || (sub != m_subVideo)) {
        return;
    }

    if (!m_videoFrame.isMapped()) {
        m_videoFrame = frame;
        update();
    }
}

QQuickFramebufferObject::Renderer* VideoRender::createRenderer() const {
    return new VideoFboRender();
}

QVideoFrame& VideoRender::getFrame() {
    return m_videoFrame;
}

QString VideoRender::accountId() const {
    return m_accountId;
}

void VideoRender::setAccountId(const QString& accountId) {
    if (accountId != m_accountId) {
        m_accountId = accountId;
        emit accountIdChanged();
    }
}

bool VideoRender::subVideo() const {
    return m_subVideo;
}

void VideoRender::setSubVideo(bool subVideo) {
    if (subVideo != m_subVideo) {
        m_subVideo = subVideo;
        emit subVideoChanged();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
VideoFboRender::VideoFboRender() {
    m_pRender = new I420Render();
}

VideoFboRender::~VideoFboRender() {
    if (m_pRender) {
        delete m_pRender;
        m_pRender = nullptr;
    }
}

void VideoFboRender::synchronize(QQuickFramebufferObject* item) {
    m_pVideoRender = qobject_cast<VideoRender*>(item);
    if (m_pVideoRender) {
        if (!m_window) {
            m_window = m_pVideoRender->window();
        }
    }
}

void VideoFboRender::render() {
    if (!m_pVideoRender) {
        return;
    }
    if (m_window) {
        if (m_itemWidth != m_pVideoRender->width() || m_itemHeight != m_pVideoRender->height()) {
            m_itemWidth = m_pVideoRender->width();
            m_itemHeight = m_pVideoRender->height();
            m_pRender->resize(m_itemWidth, m_itemHeight);
        }
    }
    auto frame = m_pVideoRender->getFrame();
    // if (frame.map(QAbstractVideoBuffer::ReadOnly)) {
    //     auto pData = frame.bits();
    //     auto videoW = frame.width();
    //     auto videoH = frame.height();
    //     if (m_pRender && !(nullptr == pData || 0 >= videoW || 0 >= videoH)) {
    //         // 渲染当前帧
    //         m_pRender->render(pData, videoW, videoH, m_itemWidth, m_itemHeight, m_window->width(), m_window->height());
    //         if (m_window) {
    //             m_window->resetOpenGLState();
    //         }
    //     }
    //     frame.unmap();
    // }
}

QOpenGLFramebufferObject* VideoFboRender::createFramebufferObject(const QSize& size) {
    QOpenGLFramebufferObjectFormat format;  // 当大小发生变化时，会调用此函数生成对应大小的FBO
    format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
    format.setSamples(4);
    return new QOpenGLFramebufferObject(size, format);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void safeDeleteTexture(QOpenGLTexture* texture) {
    if (texture) {
        if (texture->isBound()) {
            texture->release();
        }
        if (texture->isCreated()) {
            texture->destroy();
        }
        delete texture;
        texture = nullptr;
    }
}

I420Render::~I420Render() {
    if (m_pVBO) {
        m_pVBO->release();
        if (m_pVBO->isCreated()) {
            m_pVBO->destroy();
        }
        delete m_pVBO;
        m_pVBO = nullptr;
    }
    safeDeleteTexture(m_pTextureY);
    safeDeleteTexture(m_pTextureU);
    safeDeleteTexture(m_pTextureV);
}

I420Render::I420Render(QObject* pParent)
    : QObject(pParent) {
    initializeOpenGLFunctions();
    glEnable(GL_DEPTH_TEST);
    static const GLfloat vertices[]{// 顶点坐标
                                    -1.0f, -1.0f, -1.0f, +1.0f, +1.0f, +1.0f, +1.0f, -1.0f,
                                    // 纹理坐标
                                    0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.0f};

    if (!m_pVBO) {
        m_pVBO = new QOpenGLBuffer();
    }
    m_pVBO->create();
    m_pVBO->bind();
    m_pVBO->allocate(vertices, sizeof(vertices));

    // 顶点着色器源码
    const char* vsrc =
        "attribute vec4 vertexIn; \
        attribute vec2 textureIn; \
        varying vec2 textureOut;  \
        uniform mediump mat4 matrix;\
        void main(void)           \
        {                         \
            gl_Position = vertexIn * matrix; \
            textureOut = textureIn; \
        }";

    // 片段着色器源码
    std::string fsrc;
#if defined(WIN32)  // windows下opengl es 需要加上float这句话
    fsrc.append("#ifdef GL_ES\n").append("precision mediump float;\n").append("#endif\n");
#endif

#if defined(Q_OS_WIN)
    QString fragmentFile = qApp->applicationDirPath() + "/config/fragment.txt";
#elif defined(Q_OS_MACX)
    QString fragmentFile = qApp->applicationDirPath() + "/../Resources/config/fragment_mac.txt";
#endif

    if (!QFile::exists(fragmentFile)) {
        YXLOG(Error) << "fragmentFile not exists: " << fragmentFile.toStdString() << YXLOGEnd;
    } else {
        QFile file(fragmentFile);
        if (file.open(QIODevice::ReadOnly)) {
            fsrc.append(file.readAll());
        }
    }

    if (!m_pShaderProgram) {
        m_pShaderProgram = new QOpenGLShaderProgram(this);
    }
    m_pShaderProgram->addCacheableShaderFromSourceCode(QOpenGLShader::Vertex, vsrc);
    m_pShaderProgram->addCacheableShaderFromSourceCode(QOpenGLShader::Fragment, fsrc.c_str());

    // m_pShaderProgram->addShader(vshader);  // 将顶点着色器添加到程序容器
    // m_pShaderProgram->addShader(fshader);  // 将片段着色器添加到程序容器
    // 绑定属性vertexIn到指定位置ATTRIB_VERTEX,该属性在顶点着色源码其中有声明
    m_pShaderProgram->bindAttributeLocation("vertexIn", VERTEXIN);
    // 绑定属性textureIn到指定位置ATTRIB_TEXTURE,该属性在顶点着色源码其中有声明
    m_pShaderProgram->bindAttributeLocation("textureIn", TEXTUREIN);
    m_pShaderProgram->link();  // 链接所有所有添入到的着色器程序

    // 读取着色器中的数据变量tex_y, tex_u, tex_v的位置,这些变量的声明可以在片段着色器源码中可以看到
    m_textureUniformY = m_pShaderProgram->uniformLocation("tex_y");
    m_textureUniformU = m_pShaderProgram->uniformLocation("tex_u");
    m_textureUniformV = m_pShaderProgram->uniformLocation("tex_v");

    // 分别创建y,u,v纹理对象
    if (!m_pTextureY) {
        m_pTextureY = new QOpenGLTexture(QOpenGLTexture::Target2D);
    }
    m_pTextureY->create();
    if (!m_pTextureU) {
        m_pTextureU = new QOpenGLTexture(QOpenGLTexture::Target2D);
    }
    m_pTextureU->create();
    if (!m_pTextureV) {
        m_pTextureV = new QOpenGLTexture(QOpenGLTexture::Target2D);
    }
    m_pTextureV->create();

    m_idY = m_pTextureY->textureId();  // 获取返回y分量的纹理索引值
    m_idU = m_pTextureU->textureId();  // 获取返回u分量的纹理索引值
    m_idV = m_pTextureV->textureId();  // 获取返回v分量的纹理索引值

    glClearColor(0.16f, 0.16f, 0.2f, 1.0f);  // 设置背景色
    glDisable(GL_DEPTH_TEST);
}

void I420Render::resize(int width, int height) {
    glViewport(0, 0, width, height);
}

void I420Render::render(uchar* yuvPtr, int videoW, int videoH, int itemWidth, int itemHeight, int windowWidth, int windowHeight) {
    if (nullptr == m_pVBO || nullptr == m_pShaderProgram || nullptr == yuvPtr || 0 >= videoW || 0 >= videoH) {
        return;
    }

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // 激活所有链接
    m_pShaderProgram->bind();
    QMatrix4x4 modelview;
    modelview.setToIdentity();
    float ft1 = (float)videoW / (float)videoH;
    float ft2 = (float)itemHeight / (float)itemWidth;
    modelview.scale(ft1 * ft2, 1.0);
    m_pShaderProgram->setUniformValue("matrix", modelview);
    m_pVBO->bind();
    m_pShaderProgram->enableAttributeArray(VERTEXIN);
    m_pShaderProgram->enableAttributeArray(TEXTUREIN);
    m_pShaderProgram->setAttributeBuffer(VERTEXIN, GL_FLOAT, 0, 2, 2 * sizeof(GLfloat));
    m_pShaderProgram->setAttributeBuffer(TEXTUREIN, GL_FLOAT, 8 * sizeof(GLfloat), 2, 2 * sizeof(GLfloat));

    //------- 加载y数据纹理 -------
    glActiveTexture(GL_TEXTURE0);         // 激活纹理单元GL_TEXTURE0,系统里面的
    glBindTexture(GL_TEXTURE_2D, m_idY);  // 绑定y分量纹理对象id到激活的纹理单元
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    // 使用内存中的数据创建真正的y分量纹理数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, videoW, videoH, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, yuvPtr);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    //------- 加载u数据纹理 -------
    glActiveTexture(GL_TEXTURE1);  // 激活纹理单元GL_TEXTURE1
    glBindTexture(GL_TEXTURE_2D, m_idU);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    // 使用内存中的数据创建真正的u分量纹理数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, videoW >> 1, videoH >> 1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, yuvPtr + videoW * videoH);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    //------- 加载v数据纹理 -------
    glActiveTexture(GL_TEXTURE2);  // 激活纹理单元GL_TEXTURE2
    glBindTexture(GL_TEXTURE_2D, m_idV);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    // 使用内存中的数据创建真正的v分量纹理数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, videoW >> 1, videoH >> 1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, yuvPtr + videoW * videoH * 5 / 4);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    // 指定y纹理要使用新值,只能用0,1,2等表示纹理单元的索引，这是opengl不人性化的地方
    glUniform1i(m_textureUniformY, 0);  // 0对应纹理单元GL_TEXTURE0,//指定y纹理要使用新值
    glUniform1i(m_textureUniformU, 1);  // 1对应纹理单元GL_TEXTURE1,//指定u纹理要使用新值
    glUniform1i(m_textureUniformV, 2);  // 2对应纹理的单元GL_TEXTURE2,//指定v纹理要使用新值

    // 使用顶点数组方式绘制图形
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

    m_pShaderProgram->disableAttributeArray(VERTEXIN);
    m_pShaderProgram->disableAttributeArray(TEXTUREIN);
    m_pVBO->release();
    m_pShaderProgram->release();
}
