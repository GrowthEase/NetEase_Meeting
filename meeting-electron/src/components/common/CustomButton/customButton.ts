/* 自定义按钮 */

import { NEMenuIDs, SingleMeunIds } from '../../../types'
import { checkType, deepClone, hasOwnType, isLegalParam } from '../../../utils'

class BaseCustomBtnConfig {
  public barList: Array<any>
  private menuIds: Array<number | string>
  private forMain: boolean
  private checkPresetKeys: Array<string> = [
    'id',
    'btnConfig',
    'injectItemClick',
  ]
  private checkKeys: Array<string> = [
    'id',
    'type',
    'btnConfig',
    'injectItemClick',
    'btnStatus',
  ]
  private barTypes: Array<string> = ['single', 'multiple']
  private btnConfigBasic: Array<string> = ['icon', 'text', 'status']
  constructor(list: Array<any>, forMain: boolean) {
    this.barList = list
    this.forMain = forMain
    this.menuIds = Object.values(NEMenuIDs)
  }
  /**
   * @description: 获取设置的列表
   * @param {*}
   * @return {*}
   */
  public getList() {
    return deepClone(this.barList)
  }

  /**
   * @description: 增加配置项 前或者后（未暴露，未测试）
   * @param {string|number} id 菜单ID
   * @param {object} btnItem 替换的菜单项
   * @return {*}
   */
  public addItem(location, btnItem, afterItemId) {
    if (this.barList.length >= (this.forMain ? 7 : 10)) {
      throw new Error('已超出自定义最大限制')
    }
    if (!afterItemId) {
      this.barList.push(btnItem)
    }
    this.barList.splice(location, 0, btnItem)
  }
  /**
   * @description: 删除按钮（未暴露，未测试）
   * @param {string|number} id 菜单ID
   * @return {*}
   */
  public delItem(location) {
    this.barList.splice(location, 1)
  }
  /**
   * @description: 替换菜单项（未暴露，未测试）
   * @param {string|number} id 菜单ID
   * @param {object} btnItem 替换的菜单项
   * @return {*}
   */
  public replaceItem(location, btnItem) {
    this.barList.splice(location, 1, btnItem)
  }
  /**
   * @description: 检测列表合理性
   * @param {array} list 其他列表
   * @return {*}
   */
  public async checkList(list?) {
    if (list) {
      await this.compareList(deepClone(list))
    }
    await this.checkListSameid()
    for (const item of this.barList) {
      switch (true) {
        case this.menuIds.includes(item.id):
          await this.checkItem(item)
          break
        default:
          await this.checkItem(item, true)
          break
      }
    }
    return true
  }

  /**
   * @description: 节点判断是否缺失字段
   * @param {object} btnItem
   * @param {boolean} isCustom
   * @return {*}
   */
  private async checkItem(btnItem, isCustom?) {
    if (!hasOwnType(btnItem, 'id')) {
      throw new Error(`this menuitem missing id: ${JSON.stringify(btnItem)}`)
    }
    if (!checkType(btnItem.id, 'number')) {
      throw new Error(
        `this menuitem's id isn't number: ${JSON.stringify(btnItem)}`
      )
    }
    if (isCustom) {
      if (!this.menuIds.includes(btnItem.id) && Number(btnItem.id) <= 100) {
        throw new Error(
          `this menuitem's id isn't valid, please use id more than 100: ${JSON.stringify(
            btnItem
          )}`
        )
      }
      if (!btnItem.type) {
        throw new Error(
          `this menuitem missing type : ${JSON.stringify(btnItem)}`
        )
      }
      if (!this.barTypes.includes(btnItem.type)) {
        throw new Error(
          `this menuitem's type is illegal: ${JSON.stringify(btnItem)}`
        )
      }
      const checkArr =
        btnItem.type === 'single'
          ? [...this.checkPresetKeys]
          : [...this.checkKeys]
      for (const item of checkArr) {
        if (!hasOwnType(btnItem, item)) {
          throw new Error(
            `this menuitem missing ${item} : ${JSON.stringify(btnItem)}`
          )
        }
        // 校验对象还是数组
        const checkBtnConfigArr =
            btnItem.type === 'single'
              ? [...this.btnConfigBasic.slice(0, -1)]
              : [...this.btnConfigBasic],
          isSingle = btnItem.type === 'single'
        if (isSingle) {
          for (const btnConfigItem of checkBtnConfigArr) {
            if (!hasOwnType(btnItem.btnConfig, btnConfigItem)) {
              throw new Error(
                `this menuitem's btnConfig missing ${btnConfigItem} : ${JSON.stringify(
                  btnItem
                )}`
              )
            }
            if (!isLegalParam(btnItem.btnConfig[btnConfigItem])) {
              throw new Error(
                `this menuitem's btnConfig ${btnConfigItem} is empty : ${JSON.stringify(
                  btnItem
                )}`
              )
            }
          }
        } else {
          for (const btnConfigItem of checkBtnConfigArr) {
            for (const confKey in btnItem.btnConfig) {
              if (!hasOwnType(btnItem.btnConfig[confKey], btnConfigItem)) {
                throw new Error(
                  `this menuitem's btnConfig missing ${btnConfigItem} : ${JSON.stringify(
                    btnItem
                  )}`
                )
              }
              if (!isLegalParam(btnItem.btnConfig[confKey][btnConfigItem])) {
                throw new Error(
                  `this menuitem's btnConfig ${btnConfigItem} is empty : ${JSON.stringify(
                    btnItem
                  )}`
                )
              }
            }
          }
        }
      }
    } else {
      const checkArr = ['id']
      for (const item of checkArr) {
        if (!hasOwnType(btnItem, item)) {
          throw new Error(
            `this menuitem missing ${item} : ${JSON.stringify(btnItem)}`
          )
        }
        // if (hasOwnType(btnItem, 'btnConfig') && (checkType(btnItem.btnConfig, 'object') || checkType(btnItem.btnConfig, 'array'))) {
        //   const checkBtnConfigArr =  [...this.btnConfigBasic.slice(0, -1)],
        //   isSingle = Object.values(SingleMeunIds).includes(btnItem.id);
        //   if (isSingle) {
        //     if (!checkType(btnItem.btnConfig, 'object')) {
        //       throw new Error(`this menuitem's btnConfig isn't object , id ${btnItem.id} : ${JSON.stringify(btnItem)}`)
        //     }
        //     for (const btnConfigItem of checkBtnConfigArr) {
        //       if (!hasOwnType(btnItem.btnConfig, btnConfigItem)) {
        //         throw new Error(`this menuitem's btnConfig missing ${btnConfigItem} : ${JSON.stringify(btnItem)}`)
        //       }
        //     }
        //   } else {
        //     if (!checkType(btnItem.btnConfig, 'array')) {
        //       throw new Error(`this menuitem's btnConfig isn't array , id ${btnItem.id} : ${JSON.stringify(btnItem)}`)
        //     }
        //     for (const btnConfigItem of checkBtnConfigArr) {
        //       for (const confKey in btnItem.btnConfig) {
        //         if (!hasOwnType(btnItem.btnConfig[confKey], btnConfigItem)) {
        //           throw new Error(`this menuitem's btnConfig missing ${btnConfigItem} : ${JSON.stringify(btnItem)}`)
        //         }
        //       }
        //     }
        //   }
        // } else if (hasOwnType(btnItem, 'btnConfig') && !(checkType(btnItem.btnConfig, 'object') || checkType(btnItem.btnConfig, 'array'))) {
        //   throw new Error(`this menuitem's btnConfig isn't ${Object.values(SingleMeunIds).includes(btnItem.id) ? 'object' : 'array'} , id ${btnItem.id} : ${JSON.stringify(btnItem)}`)
        // }
        if (
          hasOwnType(btnItem, 'btnConfig') &&
          !(
            checkType(btnItem.btnConfig, 'object') ||
            checkType(btnItem.btnConfig, 'array')
          )
        ) {
          throw new Error(
            `this menuitem's btnConfig isn't ${
              Object.values(SingleMeunIds).includes(btnItem.id)
                ? 'object'
                : 'array'
            } , id ${btnItem.id} : ${JSON.stringify(btnItem)}`
          )
        }
      }
    }
  }
  /**
   * @description: 对比其他列表是否有重复ID-取交集 有异常直接抛异常
   * @param {array} list
   * @return {boolean}
   */
  private async compareList(list) {
    const arr = [...this.barList].filter((a) =>
      [...list].some((b) => a.id === b.id)
    )
    if (arr.length > 0) {
      throw new Error(
        `there are some same id in main list and more list: ${JSON.stringify(
          arr
        )}`
      )
    }
    return true
  }

  private async checkListSameid() {
    const arr = []
    for (const item of this.barList) {
      if (arr.includes[item.id]) {
        throw new Error(
          `there are some same id in ${
            this.forMain ? 'main' : 'more'
          } list ${JSON.stringify(item)}`
        )
      }
    }
    return true
  }
}

export default BaseCustomBtnConfig
