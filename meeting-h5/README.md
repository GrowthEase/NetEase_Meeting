# NEMeetingKit

NEMeetingKit

## 下载依赖

```bash
$ npm install nemeeting-web-sdk --save
```

## 使用

```html
<!-- 预留一个dom用于挂载会议组件 -->
<div id="ne-web-meeting"></div>
```

```js
import NEMeetingKit from 'nemeeting-web-sdk'

/* 初始化
 * 需要一个id为ne-web-meeting的元素容器用于挂载会议组件
 * @param width：宽度(px)，为0则表示100%
 * @param height：高度(px)，为0则表示100%
 * @param config：入会配置
 * @param callback： 回调
*/
const config = {
    appKey: '', //云信服务appkey
}
NEMeetingKit.actions.init(0, 0, config, () => {
    console.log('init回调', e)

    // 检测浏览器兼容性
    NEMeetingKit.actions.checkSystemRequirements(
        function (err, result) {
            let str = ''
            if (err) {
                str = err
            } else {
                str = result ? "支持" : "不支持"
            }
            console.log('浏览器兼容性检测结果：', str)
        }
    )

    // 事件监听
    NEMeetingKit.actions.on("peerJoin", (members) => {
        console.log("成员加入回调", members);
    });
    NEMeetingKit.actions.on("peerLeave", (uuids) => {
        console.log("成员离开回调", uuids);
    });
    NEMeetingKit.actions.on("roomEnded", (reason) => {
        console.log("房间被关闭", reason);
    });

    // 获取会议相关信息
    const NEMeetingInfo = NEMeetingKit.actions.NEMeetingInfo // 会议基本信息
    const memberInfo = NEMeetingKit.actions.memberInfo // 当前成员信息
    const joinMemberInfo = NEMeetingKit.actions.joinMemberInfo // 入会成员信息

})

// token登录
NEMeetingKit.actions.login({
        accountId: accountId, // 账号
        accountToken: accountToken, // token
    },
    function (e) {
        console.log('login回调', e)
    }
);

// 登出
NEMeetingKit.actions.logout(
    function (e) {
        console.log('logout回调', e)
    }
)

// 加入会议，需要先进行token登录
NEMeetingKit.actions.join({
        meetingId: meetingId, // 会议号
        nickName: nickName, // 会中昵称
        video: 1, // 视频开关，1为打开2为关闭
        audio: 1, // 音频开关，1为打开2为关闭
    },
    function (e) {
        console.log('加入会议回调', e);
    }
);

// 取消监听
NEMeetingKit.actions.off("peerJoin")
NEMeetingKit.actions.off("peerLeave"）
NEMeetingKit.actions.off("roomEnded"）

// 销毁sdk
NEMeetingKit.actions.destroy(); // 销毁
```
