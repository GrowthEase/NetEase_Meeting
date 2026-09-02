import axios, { AxiosRequestConfig, AxiosResponse } from 'axios'
import { message } from 'antd'

interface NIMCommonError {
  code: number | string
  message: string
}

const instance = axios.create({
  baseURL: process.env.baseUrl,
})

instance.interceptors.request.use(
  (config) => {
    // @ts-expect-error 设置axios自定义头
    config.headers = {
      ...config.headers,
      clientType: 'web',
      versionCode: '3.1.0',
      deviceId: new Date().getTime() + '_invite',
    }
    return config
  },
  function (error) {
    return Promise.reject(error)
  }
)

instance.interceptors.response.use(
  function (response: AxiosResponse) {
    const { code, msg } = response.data

    if (code === 200 || code === 0) {
      return response.data
    } else {
      //Msg.error(msg);
      msg && message.error(msg)
      return Promise.reject(msg)
    }
  },
  function (error: NIMCommonError) {
    return Promise.reject(error)
  }
)

export const request = function (config: AxiosRequestConfig) {
  return instance(config)
    .then((res) => {
      return res.data
    })
    .catch((error: NIMCommonError) => {
      return Promise.reject(error)
    })
}
