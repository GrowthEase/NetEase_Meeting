import axios from 'axios';
import { DOMAIN_SERVER } from '../config';
import pkg from '../../package.json';
import i18n from '../../../src/locales/i18n';

const axiosInstance = axios.create({
  baseURL: DOMAIN_SERVER,
});

axiosInstance.interceptors.request.use(
  function (config) {
    config.headers = {
      ...config.headers,
      clientType: 'Web',
      versionCode: pkg.version,
      'Accept-Language': i18n.language,
    };
    return config;
  },
  function (error) {
    return Promise.reject(error);
  },
);

axiosInstance.interceptors.response.use(
  (response) => {
    const code = response.data.code;
    if (code === 0) {
      return response.data.data;
    } else {
      return Promise.reject(response.data);
    }
  },
  function (error) {
    return Promise.reject(error);
  },
);

export default axiosInstance;
