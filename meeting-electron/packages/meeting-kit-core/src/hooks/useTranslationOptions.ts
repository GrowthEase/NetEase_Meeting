import { NERoomCaptionTranslationLanguage } from 'neroom-types'
import { useMemo } from 'react'
import { useTranslation } from 'react-i18next'

export default function useTranslationOptions() {
  const { t } = useTranslation()
  const translationOptions = useMemo(() => {
    return [
      {
        value: NERoomCaptionTranslationLanguage.NONE,
        label: t('transcriptionNotTranslated'),
      },
      {
        value: NERoomCaptionTranslationLanguage.CHINESE,
        label: t('langChinese'),
      },
      {
        value: NERoomCaptionTranslationLanguage.ENGLISH,
        label: t('langEnglish'),
      },
      {
        value: NERoomCaptionTranslationLanguage.JAPANESE,
        label: t('langJapanese'),
      },
    ]
  }, [t])

  const translationMap = useMemo(() => {
    return {
      [NERoomCaptionTranslationLanguage.CHINESE]: t('langChinese'),
      [NERoomCaptionTranslationLanguage.ENGLISH]: t('langEnglish'),
      [NERoomCaptionTranslationLanguage.JAPANESE]: t('langJapanese'),
    }
  }, [t])

  return {
    translationMap,
    translationOptions,
  }
}
