import React, {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import { useTranslation } from 'react-i18next';
import './index.less';
import NEPreMeetingService, {
  NEMeetingTranscriptionInfo,
  NEMeetingTranscriptionMessage,
} from '@meeting-module/kit/interface/service/pre_meeting_service';
import { debounce, formatDate } from '@meeting-module/utils';
import { NEResult } from 'neroom-types';
import { Button, Popover } from 'antd';
import {
  AutoSizer,
  CellMeasurer,
  CellMeasurerCache,
  List,
} from 'react-virtualized';
import { Toast } from '@meeting-module/kit';
import NEContactsService from '@meeting-module/kit/impl/service/meeting_contacts_service';
import { NEContact } from '@meeting-module/kit/interface/service/meeting_contacts_service';
import { TranscriptionItem } from '@meeting-module/components/web/Transcription';

const cache = new CellMeasurerCache({
  fixedWidth: true,
  minHeight: 40,
});

interface TranscriptionProps {
  className?: string;
  meetingId?: number;
  preMeetingService?: NEPreMeetingService;
  meetingContactsService?: NEContactsService;
  subject?: string;
}
interface TranscriptionListProps {
  transcriptionInfoList: NEMeetingTranscriptionInfo[];
  onClickDetail: (state: number, meetingId: number, startTime: string) => void;
}

interface TranscriptionDetailProps {
  messageList: NEMeetingTranscriptionMessage[];
  startTime: string;
  onClose?: () => void;
  className?: string;
  onDownload?: (type: 'pdf' | 'word' | 'txt') => void;
  meetingContactsService?: NEContactsService;
}

const TranscriptionList: React.FC<TranscriptionListProps> = ({
  transcriptionInfoList,
  onClickDetail,
}) => {
  const { t } = useTranslation();

  return (
    <div className="nemeeting-app-trans-list">
      <div className="nemeeting-app-trans-list-content">
        <div className="nemeeting-app-tran-title">
          {t('transcriptionTiming')}
        </div>
        <div className="nemeeting-app-tran-content">
          {transcriptionInfoList.map((item, index) => {
            const startTime = formatDate(
              item.timeRanges[0]?.start,
              'yyyy.MM.dd hh:mm:ss',
            );

            return (
              <div
                className="nemeeting-app-trans-list-item"
                key={index}
                onClick={() => onClickDetail(item.state, index, startTime)}
              >
                <div className="nemeeting-app-trans-list-item-date">
                  {startTime}
                </div>
                <svg
                  className="icon iconfont iconchat-history"
                  aria-hidden="true"
                >
                  <use xlinkHref="#iconyoujiantou-16px-2"></use>
                </svg>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export const TranscriptionDetail: React.FC<TranscriptionDetailProps> = ({
  onClose,
  messageList,
  className,
  onDownload,
  startTime,
  meetingContactsService,
}) => {
  const { t } = useTranslation();
  const [saveType, setType] = useState<'pdf' | 'word' | 'txt' | ''>('');
  const contentWrapperRef = useRef<HTMLDivElement | null>(null);
  const [userInfoMap, setUserInfoMap] = useState<Record<string, NEContact>>({});
  const userInfoMapRef = useRef<Record<string, NEContact>>(userInfoMap);

  userInfoMapRef.current = userInfoMap;

  const handleDownload = useCallback(
    (type: 'pdf' | 'word' | 'txt') => {
      setType(type);
      onDownload?.(type);
    },
    [onDownload],
  );

  const getUsersInfo = async (userIds: string[]) => {
    const userIdList = userIds.filter(
      (userId) => !userInfoMapRef.current[userId],
    );
    const tmpUserInfoMap = { ...userInfoMapRef.current };
    const res = await meetingContactsService?.getContactsInfo(userIdList);
    const meetingAccountListResp = res?.data.foundList;

    meetingAccountListResp?.forEach((item) => {
      tmpUserInfoMap[item.userUuid] = item;
    });
    setUserInfoMap(tmpUserInfoMap);
  };

  const onRowsRendered = debounce(
    (data: { startIndex: number; stopIndex: number }) => {
      const msgList = messageList.slice(data.startIndex, data.stopIndex + 1);

      getUsersInfo(msgList.map((item) => item.fromUserUuid));
    },
    800,
  );

  const popOverContent = useMemo(() => {
    return (
      <div className="nemeeting-app-trans-popover-content">
        <div className="nemeeting-app-trans-save-title">
          {t('globalFileSaveAs')}
        </div>
        <div
          className="nemeeting-app-trans-save-item"
          onClick={() => handleDownload('pdf')}
        >
          <div className="nemeeting-app-trans-save-item-label">
            <svg
              className="icon iconfont ne-trans-save-item-label-icon"
              aria-hidden="true"
            >
              <use xlinkHref="#iconPDF"></use>
            </svg>
            <span>{t('globalFileTypePDF')}</span>
          </div>
          {saveType === 'pdf' && (
            <svg
              className="icon iconfont ne-trans-save-item-icon"
              aria-hidden="true"
            >
              <use xlinkHref="#iconcheck-line-regular1x"></use>
            </svg>
          )}
        </div>
        <div
          className="nemeeting-app-trans-save-item"
          onClick={() => handleDownload('word')}
        >
          <div className="nemeeting-app-trans-save-item-label">
            <svg
              className="icon iconfont ne-trans-save-item-label-icon"
              aria-hidden="true"
            >
              <use xlinkHref="#iconWord"></use>
            </svg>
            <span>{t('globalFileTypeWord')}</span>
          </div>
          {saveType === 'word' && (
            <svg
              className="icon iconfont ne-trans-save-item-icon"
              aria-hidden="true"
            >
              <use xlinkHref="#iconcheck-line-regular1x"></use>
            </svg>
          )}
        </div>
        <div
          className="nemeeting-app-trans-save-item"
          onClick={() => handleDownload('txt')}
        >
          <div className="nemeeting-app-trans-save-item-label">
            <svg
              className="icon iconfont ne-trans-save-item-label-icon"
              aria-hidden="true"
            >
              <use xlinkHref="#iconwenben"></use>
            </svg>
            <span>{t('globalFileTypeTxt')}</span>
          </div>
          {saveType === 'txt' && (
            <svg
              className="icon iconfont ne-trans-save-item-icon"
              aria-hidden="true"
            >
              <use xlinkHref="#iconcheck-line-regular1x"></use>
            </svg>
          )}
        </div>
      </div>
    );
  }, [saveType, t, handleDownload]);

  const rowRenderer = ({ index, key, parent, style }) => {
    const item = messageList[index];

    return (
      <CellMeasurer
        cache={cache}
        columnIndex={0}
        key={key}
        rowIndex={index}
        parent={parent}
      >
        {({ registerChild }) => (
          <div ref={registerChild} style={style} className="virtual-item">
            <TranscriptionItem
              key={index}
              message={{
                ...item,
                isFinal: true,
                avatar: userInfoMap[item.fromUserUuid]?.avatar,
                nickname: item.fromNickname,
              }}
            />
          </div>
        )}
      </CellMeasurer>
    );
  };

  return (
    <div className={`nemeeting-app-trans-detail ${className || ''}`}>
      {startTime && (
        <div className="nemeeting-app-trans-detail-header">
          <svg
            className="icon iconfont nemeeting-app-trans-detail-header-back"
            aria-hidden="true"
            onClick={() => onClose?.()}
          >
            <use xlinkHref="#iconzuojiantou-16px"></use>
          </svg>
          <div className="nemeeting-app-trans-detail-header-title">
            {startTime}
          </div>
        </div>
      )}

      <div
        className="nemeeting-app-trans-detail-content"
        ref={contentWrapperRef}
      >
        <AutoSizer disableHeight>
          {({ width }) => (
            <List
              width={width}
              className="nemeeting-app-trans-detail-virtual-content"
              overscanRowCount={10}
              scrollToAlignment="end"
              height={startTime ? 512 : 552}
              rowCount={messageList.length}
              rowHeight={cache.rowHeight}
              rowRenderer={rowRenderer}
              onRowsRendered={onRowsRendered}
            />
          )}
        </AutoSizer>
      </div>
      <div className="nemeeting-app-trans-detail-footer">
        <Popover
          rootClassName="nemeeting-app-trans-detail-pop"
          arrow={false}
          trigger={'click'}
          content={popOverContent}
        >
          <Button
            type="primary"
            size="large"
            className="nemeeting-app-trans-detail-btn"
          >
            {t('transcriptionExportFile')}
            <svg className="icon iconfont iconchat-history" aria-hidden="true">
              <use xlinkHref="#iconxiajiantou-shixin"></use>
            </svg>
          </Button>
        </Popover>
      </div>
    </div>
  );
};

const Transcription: React.FC<TranscriptionProps> = ({
  meetingId,
  preMeetingService,
  subject,
  meetingContactsService,
}) => {
  const { t } = useTranslation();
  const [transcriptionInfoList, setTranscriptionInfoList] = useState<
    NEMeetingTranscriptionInfo[]
  >([]);

  const [transcriptionMessageList, setTranscriptionMessageList] = useState<
    NEMeetingTranscriptionMessage[]
  >([]);

  const transcriptionInfoListRef = useRef<NEMeetingTranscriptionInfo[]>([]);

  transcriptionInfoListRef.current = transcriptionInfoList;

  const [showDetail, setShowDetail] = useState<boolean>(false);
  const [startTime, setStartTime] = useState<string>('');
  const currentTranscriptionInfoRef = useRef<NEMeetingTranscriptionInfo>();

  useEffect(() => {
    if (meetingId) {
      preMeetingService
        ?.getHistoryMeetingTranscriptionInfo(meetingId)
        .then((res) => {
          const list = res.data;

          setTranscriptionInfoList(list);
          transcriptionInfoListRef.current = list;

          // 如果只有一项直接打开详情
          if (list.length === 1) {
            setShowDetail(true);
            handleClickDetail(list[0].state, 0, '');
          }
        });
    }
  }, [meetingId, preMeetingService]);

  function oncloseDetail() {
    setShowDetail(false);
    setTranscriptionMessageList([]);
    setStartTime('');
  }

  const downloadFile = useCallback((url, fileName) => {
    const link = document.createElement('a');

    link.href = url;
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }, []);

  function handleClickDetail(state: number, index: number, startTime: string) {
    // 转写中
    if (state !== 2) {
      Toast.info(t('transcriptionGenerating'));
      return;
    }

    console.log('handleClickDetail', index);
    const info = transcriptionInfoListRef.current[index];

    setStartTime(startTime);
    currentTranscriptionInfoRef.current = info;
    if (info && meetingId) {
      const requestList: Promise<NEResult<NEMeetingTranscriptionMessage[]>>[] =
        [];

      info.originalNosFileKeys.forEach((key) => {
        preMeetingService &&
          requestList.push(
            preMeetingService.getHistoryMeetingTranscriptionMessageList(
              meetingId,
              key,
            ),
          );
      });
      Promise.all(requestList).then((resList) => {
        const messageList = resList
          .map((res) => {
            return res.data;
          })
          .sort((firstList, nextList) => {
            return firstList[0]?.timestamp - nextList[0]?.timestamp;
          })
          .flat();

        setTranscriptionMessageList(messageList);
        console.log('getHistoryMeetingTranscriptionMessageList', resList);
      });

      setShowDetail(true);
    }
  }

  const handleDownload = useCallback(
    (type: 'pdf' | 'word' | 'txt') => {
      if (!meetingId) {
        return;
      }

      switch (type) {
        case 'pdf': {
          const pdfKeys = currentTranscriptionInfoRef.current?.pdfNosFileKeys;

          if (pdfKeys) {
            pdfKeys?.forEach(async (key, index) => {
              //【会议主题】_【转写记录编号】_【时间戳】202406122022；
              const res =
                await preMeetingService?.getHistoryMeetingTranscriptionFileUrl(
                  meetingId,
                  key,
                );

              res &&
                downloadFile(
                  res.data,
                  `${subject}_${index + 1}_${formatDate(
                    Date.now(),
                    'yyyyMMddhhmm',
                  )}.pdf`,
                );
            });
          }

          break;
        }

        case 'word': {
          const wordKeys = currentTranscriptionInfoRef.current?.wordNosFileKeys;

          if (wordKeys) {
            wordKeys?.forEach(async (key, index) => {
              const res =
                await preMeetingService?.getHistoryMeetingTranscriptionFileUrl(
                  meetingId,
                  key,
                );

              res &&
                downloadFile(
                  res.data,
                  `${subject}_${index + 1}_${formatDate(
                    Date.now(),
                    'yyyyMMddhhmm',
                  )}.docx`,
                );
            });
          }

          break;
        }

        case 'txt': {
          const txtKeys = currentTranscriptionInfoRef.current?.txtNosFileKeys;

          if (txtKeys) {
            txtKeys?.forEach(async (key, index) => {
              const res =
                await preMeetingService?.getHistoryMeetingTranscriptionFileUrl(
                  meetingId,
                  key,
                );

              res &&
                downloadFile(
                  res.data,
                  `${subject}_${index + 1}_${formatDate(
                    Date.now(),
                    'yyyyMMddhhmm',
                  )}.txt`,
                );
            });
          }

          break;
        }
      }
    },
    [downloadFile, meetingId, preMeetingService, subject],
  );

  return (
    <div className="nemeeting-app-transcription">
      <TranscriptionList
        transcriptionInfoList={transcriptionInfoList}
        onClickDetail={handleClickDetail}
      />
      {showDetail && (
        <TranscriptionDetail
          meetingContactsService={meetingContactsService}
          startTime={startTime}
          className="nemeeting-app-transcription-detail"
          messageList={transcriptionMessageList}
          onClose={() => oncloseDetail()}
          onDownload={(type) => handleDownload(type)}
        />
      )}
    </div>
  );
};

export default Transcription;
