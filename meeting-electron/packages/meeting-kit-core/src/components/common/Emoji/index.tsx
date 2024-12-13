import React, { CSSProperties, useEffect, useState } from 'react'
import { Tooltip } from 'antd'
import classNames from 'classnames'
import './index.less'

import a1 from './assets/a-1.png'
import a2 from './assets/a-2.png'
import a3 from './assets/a-3.png'
import a4 from './assets/a-4.png'
import a5 from './assets/a-5.png'
import a6 from './assets/a-6.png'
import a7 from './assets/a-7.png'
import a8 from './assets/a-8.png'
import a9 from './assets/a-9.png'
import a10 from './assets/a-10.png'
import a11 from './assets/a-11.png'
import a12 from './assets/a-12.png'
import a13 from './assets/a-13.png'
import a14 from './assets/a-14.png'
import a15 from './assets/a-15.png'
import a16 from './assets/a-16.png'
import a17 from './assets/a-17.png'
import a18 from './assets/a-18.png'
import a19 from './assets/a-19.png'
import a20 from './assets/a-20.png'
import a21 from './assets/a-21.png'
import a22 from './assets/a-22.png'
import a23 from './assets/a-23.png'
import a24 from './assets/a-24.png'
import a25 from './assets/a-25.png'
import a26 from './assets/a-26.png'
import a27 from './assets/a-27.png'
import a28 from './assets/a-28.png'
import a29 from './assets/a-29.png'
import a30 from './assets/a-30.png'
import a31 from './assets/a-31.png'
import a32 from './assets/a-32.png'
import a33 from './assets/a-33.png'
import a34 from './assets/a-34.png'
import a35 from './assets/a-35.png'
import a36 from './assets/a-36.png'
import a37 from './assets/a-37.png'
import a38 from './assets/a-38.png'
import a39 from './assets/a-39.png'
import a40 from './assets/a-40.png'
import a41 from './assets/a-41.png'
import a42 from './assets/a-42.png'
import a43 from './assets/a-43.png'
import a44 from './assets/a-44.png'
import a45 from './assets/a-45.png'
import a46 from './assets/a-46.png'
import a47 from './assets/a-47.png'
import a48 from './assets/a-48.png'
import a49 from './assets/a-49.png'
import a50 from './assets/a-50.png'
import a51 from './assets/a-51.png'
import a52 from './assets/a-52.png'
import a53 from './assets/a-53.png'
import a54 from './assets/a-54.png'
import a55 from './assets/a-55.png'
import a56 from './assets/a-56.png'
import a57 from './assets/a-57.png'
import a58 from './assets/a-58.png'
import a59 from './assets/a-59.png'
import a60 from './assets/a-60.png'
import a61 from './assets/a-61.png'
import a62 from './assets/a-62.png'
import a63 from './assets/a-63.png'
import a64 from './assets/a-64.png'
import a65 from './assets/a-65.png'
import a66 from './assets/a-66.png'
import a67 from './assets/a-67.png'
import a68 from './assets/a-68.png'
import a1000 from './assets/a-1000.png'
import a1001 from './assets/a-1001.png'
import a1002 from './assets/a-1002.png'
import a1003 from './assets/a-1003.png'
import a1004 from './assets/a-1004.png'
import a1005 from './assets/a-1005.png'
import a1006 from './assets/a-1006.png'
import a2000 from './assets/a-2000.png'
import a2001 from './assets/a-2001.png'
import a2002 from './assets/a-2002.png'
import a2003 from './assets/a-2003.png'
import a2004 from './assets/a-2004.png'
import a2005 from './assets/a-2005.png'

const tipsText = {
  '[大笑]': { zh: '大笑', en: 'Laugh', ja: '大笑いする' },
  '[开心]': { zh: '开心', en: 'Happy', ja: 'うれしい' },
  '[色]': { zh: '色', en: 'Drool', ja: '好色' },
  '[酷]': { zh: '酷', en: 'CoolGuy', ja: 'クール' },
  '[奸笑]': { zh: '奸笑', en: 'Smirk', ja: 'くすくす笑う' },
  '[亲]': { zh: '亲', en: 'Kiss', ja: 'キスします' },
  '[伸舌头]': { zh: '伸舌头', en: 'Tongue', ja: '舌を出す' },
  '[眯眼]': { zh: '眯眼', en: 'Wink', ja: '目を細める' },
  '[可爱]': { zh: '可爱', en: 'Cute', ja: 'かわいい' },
  '[鬼脸]': { zh: '鬼脸', en: 'Grimace', ja: 'に面' },
  '[偷笑]': { zh: '偷笑', en: 'Chuckle', ja: 'くすくす笑う' },
  '[喜悦]': { zh: '喜悦', en: 'Grin', ja: '喜び' },
  '[狂喜]': { zh: '狂喜', en: 'Yeah!', ja: '狂喜' },
  '[惊讶]': { zh: '惊讶', en: 'Surprise', ja: 'びっくりさせる' },
  '[流泪]': { zh: '流泪', en: 'Weep', ja: '涙を流す' },
  '[流汗]': { zh: '流汗', en: 'Sweats', ja: '汗をかく' },
  '[天使]': { zh: '天使', en: 'Angel', ja: '天使' },
  '[笑哭]': { zh: '笑哭', en: 'Lol', ja: '笑って泣く' },
  '[尴尬]': { zh: '尴尬', en: 'Awkward', ja: '気まずい' },
  '[惊恐]': { zh: '惊恐', en: 'Panic', ja: 'びっくり仰天' },
  '[大哭]': { zh: '大哭', en: 'Sob', ja: '泣き叫ぶ' },
  '[烦躁]': { zh: '烦躁', en: 'Scream', ja: 'いらいらさせる' },
  '[恐怖]': { zh: '恐怖', en: 'Terror', ja: '怖い' },
  '[两眼冒星]': { zh: '两眼冒星', en: 'Dizzy', ja: '目から星が出る' },
  '[害羞]': { zh: '害羞', en: 'Shy', ja: 'はずかしい' },
  '[睡着]': { zh: '睡着', en: 'Sleep', ja: '眠りにつく' },
  '[冒星]': { zh: '冒星', en: 'Faint', ja: '星が出る' },
  '[口罩]': { zh: '口罩', en: 'Sick', ja: 'マスク枚' },
  '[OK]': { zh: 'OK', en: 'Emm', ja: 'OK' },
  '[好吧]': { zh: '好吧', en: 'Fine', ja: 'わかった' },
  '[鄙视]': { zh: '鄙视', en: 'Duh', ja: '軽蔑する' },
  '[难受]': { zh: '难受', en: 'Let Down', ja: 'つらい' },
  '[不屑]': { zh: '不屑', en: 'Disdain', ja: '潔しとしない' },
  '[不舒服]': { zh: '不舒服', en: 'Unwell', ja: '気分が悪い' },
  '[愤怒]': { zh: '愤怒', en: 'Anger', ja: '怒り' },
  '[鬼怪]': { zh: '鬼怪', en: 'Ghost', ja: 'お化け人' },
  '[发怒]': { zh: '发怒', en: 'Angry', ja: '怒りを発する' },
  '[生气]': { zh: '生气', en: 'Arrogant', ja: '腹が立つ' },
  '[不高兴]': { zh: '不高兴', en: 'Unhappy', ja: 'うれしくない' },
  '[皱眉]': { zh: '皱眉', en: 'Frown', ja: '眉をしかめる' },
  '[心碎]': { zh: '心碎', en: 'BrokenHeart', ja: '心が砕ける' },
  '[心动]': { zh: '心动', en: 'Heart', ja: '心が動く' },
  '[好的]': { zh: '好的', en: 'OK', ja: 'はい' },
  '[低级]': { zh: '低级', en: 'ThumbsDown', ja: '下位レベル' },
  '[赞]': { zh: '赞', en: 'ThumbsUp', ja: 'いいね' },
  '[鼓掌]': { zh: '鼓掌', en: 'Clap', ja: '拍手する' },
  '[给力]': { zh: '给力', en: 'Awesome', ja: 'すげぇ' },
  '[打你]': { zh: '打你', en: 'HitYou', ja: '殴ってやる' },
  '[阿弥陀佛]': { zh: '阿弥陀佛', en: 'Worship', ja: '阿弥陀仏' },
  '[拜拜]': { zh: '拜拜', en: 'Bye', ja: 'バイバイ' },
  '[第一]': { zh: '第一', en: 'First', ja: '第1' },
  '[拳头]': { zh: '拳头', en: 'Fist', ja: 'こぶし' },
  '[手掌]': { zh: '手掌', en: 'Palm', ja: '手のひら' },
  '[剪刀]': { zh: '剪刀', en: 'Scissors', ja: 'はさみ' },
  '[招手]': { zh: '招手', en: 'Wave', ja: '手を振る' },
  '[不要]': { zh: '不要', en: "Don't", ja: 'いや' },
  '[举着]': { zh: '举着', en: 'Holding', ja: '持ち上げる' },
  '[思考]': { zh: '思考', en: 'Thinking', ja: '考える' },
  '[猪头]': { zh: '猪头', en: 'Pig', ja: '豚の頭' },
  '[不听]': { zh: '不听', en: "Don't listen", ja: '聞かない' },
  '[不看]': { zh: '不看', en: "Don't look", ja: '見ない' },
  '[不说]': { zh: '不说', en: "Don't say it", ja: '言わない' },
  '[猴子]': { zh: '猴子', en: 'Monkey', ja: '猿' },
  '[炸弹]': { zh: '炸弹', en: 'Bomb', ja: 'ばくだん' },
  '[睡觉]': { zh: '睡觉', en: 'Sleep', ja: '寝る' },
  '[筋斗云]': { zh: '筋斗云', en: 'Cloud', ja: '筋斗雲' },
  '[火箭]': { zh: '火箭', en: 'Rocket', ja: 'ロヶット' },
  '[救护车]': { zh: '救护车', en: 'Ambulance', ja: '救急車' },
  '[点赞]': { zh: '点赞', en: 'Thumbs Up', ja: 'いいね' },
  '[爱心]': { zh: '爱心', en: 'Heart', ja: '心' },
  '[惊叹]': { zh: '惊叹', en: 'Open Mouth', ja: '驚嘆する' },
  '[撒花]': { zh: '撒花', en: 'Tada', ja: '花をまく' },
}

export const emojiMap = {
  '[大笑]': a1,
  '[开心]': a2,
  '[色]': a3,
  '[酷]': a4,
  '[奸笑]': a5,
  '[亲]': a6,
  '[伸舌头]': a7,
  '[眯眼]': a8,
  '[可爱]': a9,
  '[鬼脸]': a10,
  '[偷笑]': a11,
  '[喜悦]': a12,
  '[狂喜]': a13,
  '[惊讶]': a14,
  '[流泪]': a15,
  '[流汗]': a16,
  '[天使]': a17,
  '[笑哭]': a18,
  '[尴尬]': a19,
  '[惊恐]': a20,
  '[大哭]': a21,
  '[烦躁]': a22,
  '[恐怖]': a23,
  '[两眼冒星]': a24,
  '[害羞]': a25,
  '[睡着]': a26,
  '[冒星]': a27,
  '[口罩]': a28,
  '[OK]': a29,
  '[好吧]': a30,
  '[鄙视]': a31,
  '[难受]': a32,
  '[不屑]': a33,
  '[不舒服]': a34,
  '[愤怒]': a35,
  '[鬼怪]': a36,
  '[发怒]': a37,
  '[生气]': a38,
  '[不高兴]': a39,
  '[皱眉]': a40,
  '[心碎]': a41,
  '[心动]': a42,
  '[好的]': a43,
  '[低级]': a44,
  '[赞]': a45,
  '[鼓掌]': a46,
  '[给力]': a47,
  '[打你]': a48,
  '[阿弥陀佛]': a49,
  '[拜拜]': a50,
  '[第一]': a51,
  '[拳头]': a52,
  '[手掌]': a53,
  '[剪刀]': a54,
  '[招手]': a55,
  '[不要]': a56,
  '[举着]': a57,
  '[思考]': a58,
  '[猪头]': a59,
  '[不听]': a60,
  '[不看]': a61,
  '[不说]': a62,
  '[猴子]': a63,
  '[炸弹]': a64,
  '[睡觉]': a65,
  '[筋斗云]': a66,
  '[火箭]': a67,
  '[救护车]': a68,
}

export const emoji2Map = {
  '[鼓掌]': [a1000, a2000],
  '[点赞]': [a1001, a2001],
  '[爱心]': [a1002, a2002],
  '[笑哭]': [a1003, a2003],
  '[惊叹]': [a1004, a2004],
  '[撒花]': [a1005, a2005],
  '[举手]': [a1006, a1006],
}

export function getEmojiPath(
  emojiKey: string,
  type?: number,
  animate?: boolean
): string | undefined {
  if (type === 2) {
    const index = animate ? 1 : 0

    return emoji2Map[emojiKey][index] || undefined
  } else {
    return emojiMap[emojiKey] || undefined
  }
}

interface EmojiItemProps {
  emojiKey: string
  type?: number // 1 聊天室； 2 表情回应
  animate?: boolean
  disabled?: boolean
  language?: string
  size?: number
  style?: CSSProperties | undefined
  onClick?: (emojiKey: string) => void
}

const EmojiItem: React.FC<EmojiItemProps> = ({
  language,
  type = 1,
  animate = false,
  disabled = false,
  size = 30,
  emojiKey,
  onClick,
}) => {
  const style = {
    width: size,
    height: size,
    fontSize: size,
    lineHeight: `${size}px`,
  }

  const [path, setPath] = useState(getEmojiPath(emojiKey, type, animate))

  const tip = language ? tipsText[emojiKey][language] : ''

  const onMouseEnter = () => {
    type === 2 && setPath(getEmojiPath(emojiKey, type, true) ?? '')
  }

  const onMouseLeave = () => {
    type === 2 && setPath(getEmojiPath(emojiKey, type, animate) ?? '')
  }

  useEffect(() => {
    setPath(getEmojiPath(emojiKey, type, animate) ?? '')
  }, [emojiKey, type, animate])

  return path ? (
    <Tooltip
      placement="top"
      trigger={tip && !disabled ? ['hover'] : []}
      title={tip}
    >
      <img
        onMouseEnter={onMouseEnter}
        onMouseLeave={onMouseLeave}
        className={classNames('nemeeting-emoji-item', {
          ['nemeeting-emoji-item-disabled']: disabled,
        })}
        style={style}
        src={path}
        onClick={() => onClick?.(emojiKey)}
      />
    </Tooltip>
  ) : (
    emojiKey
  )
}

export default React.memo(EmojiItem)
