/*
 * @Description: 配置文件
 */

import { getQueryVariable } from './utils'

const isDev = process.env.NODE_ENV === 'development'
const isWebSite = process.env.VUE_APP_VERSION === 'website'
const isWebSiteDEV = process.env.VUE_APP_USE_DOMAIN === 'dev'
const mockOnline =
  getQueryVariable('mockOnline') && getQueryVariable('mockOnline') === '1'

const appkeyOnline = process.env.VUE_APP_KEY_ONLINE,
  appkeyTest = process.env.VUE_APP_KEY_TEST,
  domainOnline = process.env.VUE_APP_DOMAIN_ONLINE,
  domainTest = process.env.VUE_APP_DOMAIN_TEST

export const appkey = isWebSite
  ? isWebSiteDEV
    ? appkeyTest
    : appkeyOnline /* 此处分割区分站点调试与sdk调试 */
  : isDev
  ? mockOnline
    ? appkeyOnline
    : appkeyTest
  : appkeyOnline

export const meetingServerDomain = isWebSite
  ? isWebSiteDEV
    ? domainTest
    : domainOnline /* 此处分割区分站点调试与sdk调试 */
  : isDev
  ? mockOnline
    ? domainOnline
    : domainTest
  : domainOnline

export default {
  appkey,
  meetingServerDomain,
}
