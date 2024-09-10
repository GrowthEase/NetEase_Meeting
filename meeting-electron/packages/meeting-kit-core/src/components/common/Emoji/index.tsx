import React, { CSSProperties } from 'react'
import './index.less'
import { Tooltip } from 'antd'

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
}

export const emojiMap = {
  '[大笑]': 'a-1',
  '[开心]': 'a-2',
  '[色]': 'a-3',
  '[酷]': 'a-4',
  '[奸笑]': 'a-5',
  '[亲]': 'a-6',
  '[伸舌头]': 'a-7',
  '[眯眼]': 'a-8',
  '[可爱]': 'a-9',
  '[鬼脸]': 'a-10',
  '[偷笑]': 'a-11',
  '[喜悦]': 'a-12',
  '[狂喜]': 'a-13',
  '[惊讶]': 'a-14',
  '[流泪]': 'a-15',
  '[流汗]': 'a-16',
  '[天使]': 'a-17',
  '[笑哭]': 'a-18',
  '[尴尬]': 'a-19',
  '[惊恐]': 'a-20',
  '[大哭]': 'a-21',
  '[烦躁]': 'a-22',
  '[恐怖]': 'a-23',
  '[两眼冒星]': 'a-24',
  '[害羞]': 'a-25',
  '[睡着]': 'a-26',
  '[冒星]': 'a-27',
  '[口罩]': 'a-28',
  '[OK]': 'a-29',
  '[好吧]': 'a-30',
  '[鄙视]': 'a-31',
  '[难受]': 'a-32',
  '[不屑]': 'a-33',
  '[不舒服]': 'a-34',
  '[愤怒]': 'a-35',
  '[鬼怪]': 'a-36',
  '[发怒]': 'a-37',
  '[生气]': 'a-38',
  '[不高兴]': 'a-39',
  '[皱眉]': 'a-40',
  '[心碎]': 'a-41',
  '[心动]': 'a-42',
  '[好的]': 'a-43',
  '[低级]': 'a-44',
  '[赞]': 'a-45',
  '[鼓掌]': 'a-46',
  '[给力]': 'a-47',
  '[打你]': 'a-48',
  '[阿弥陀佛]': 'a-49',
  '[拜拜]': 'a-50',
  '[第一]': 'a-51',
  '[拳头]': 'a-52',
  '[手掌]': 'a-53',
  '[剪刀]': 'a-54',
  '[招手]': 'a-55',
  '[不要]': 'a-56',
  '[举着]': 'a-57',
  '[思考]': 'a-58',
  '[猪头]': 'a-59',
  '[不听]': 'a-60',
  '[不看]': 'a-61',
  '[不说]': 'a-62',
  '[猴子]': 'a-63',
  '[炸弹]': 'a-64',
  '[睡觉]': 'a-65',
  '[筋斗云]': 'a-66',
  '[火箭]': 'a-67',
  '[救护车]': 'a-68',
}

export function getEmojiPath(emojiKey: string): string | undefined {
  const emoji = emojiMap[emojiKey]

  if (emoji) {
    return require('./assets/' + emoji + '.png')
  }

  return
}

interface EmojiItemProps {
  emojiKey: string
  language?: string
  size?: number
  style?: CSSProperties | undefined
  onClick?: (emojiKey: string) => void
}

const EmojiItem: React.FC<EmojiItemProps> = ({
  language,
  size = 30,
  emojiKey,
  onClick,
}) => {
  const style = {
    width: size,
    height: size,
    fontSize: size,
    lineHeight: `${size}px`,
    display: 'inline-block',
  }

  const path = getEmojiPath(emojiKey)

  const tip = language ? tipsText[emojiKey][language] : ''

  return path ? (
    <Tooltip placement="top" trigger={tip ? ['hover'] : []} title={tip}>
      <img
        className="nemeeting-emoji-item"
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
