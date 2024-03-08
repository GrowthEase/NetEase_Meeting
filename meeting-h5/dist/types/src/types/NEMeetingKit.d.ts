import { EventName, JoinOptions, LoginOptions, MoreBarList, NEMeetingInitConfig, NEMember, ToolBarList } from './type';
import NEMeetingService from '../services/NEMeeting';
/**
 * 会议组件
 */
export default interface NEMeetingKit {
    /**
     * NEMeetingInfo 当前会议信息
     */
    /**
     *@ignore
     */
    view: HTMLElement | null;
    /**
     *@ignore
     */
    isInitialized: boolean;
    /**
     *@ignore
     */
    neMeeting: NEMeetingService | null;
    /**
     *@ignore
     */
    NEMeetingInfo: any;
    /**
     *@ignore
     */
    /**
     * 控制栏按钮配置（h5暂不支持）
     */
    toolBarList: ToolBarList;
    /**
     * 更多按钮配置（h5暂不支持）
     */
    moreBarList: MoreBarList;
    /**
     * 当前成员信息
     */
    memberInfo: NEMember;
    /**
     * 入会成员信息
     */
    joinMemberInfo: {
        [key: string]: NEMember;
    };
    /**
     * 初始化接口
     * @param width 画布宽度
     * @param height 画布高度
     * @param config 配置项
     */
    init: (width: number, height: number, config: NEMeetingInitConfig, callback: () => void) => void;
    /**
     * 销毁房间方法
     */
    destroy: () => void;
    /**
     * 离开房间回调方法
     * @param callback
     */
    /**
     * 登录接口
     * @param options 相应配置项
     * @param callback 接口回调
     */
    login: (options: LoginOptions, callback: () => void) => void;
    /**
     * 登出接口
     * @param callback 接口回调
     */
    logout: (callback: () => void) => void;
    /**
     * 创建会议接口
     * @param options 相应配置参数
     * @param callback 接口回调
     */
    /**
     * 加入会议接口
     * @param options 相应配置参数
     * @param callback 接口回调
     */
    join: (options: JoinOptions, callback: () => void) => void;
    /**
     * 动态更新自定义按钮
     * @param options
     */
    /**
     * 事件监听接口
     * @param actionName 事件名
     * @param callback 事件回调
     */
    on: (actionName: EventName, callback: (data: any) => void) => void;
    /**
     * 移除事件监听接口
     * @param actionName 事件名
     * @param callback 事件回调
     */
    off: (actionName: EventName, callback?: (data: any) => void) => void;
    /**
     * 设置默认画面展示模式
     * @param mode big | small
     */
    /**
     * 上传日志接口
     * @param logNames 日志类型名称
     * @param start 日志开始时间
     * @param end 日志结束时间
     */
    /**
     * 下载日志接口
     * @param logNames 日志类型类型
     * @param start 日志开始时间
     * @param end 日志结束时间
     */
    /**
     * 检测浏览器是否兼容
     * 返回true表示支持当前环境，否则为不支持
     */
    checkSystemRequirements: () => boolean;
}
export declare type IM = any;
