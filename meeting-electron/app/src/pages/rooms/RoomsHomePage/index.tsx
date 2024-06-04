import Styles from './index.less';
import { useEffect, useState } from 'react';
import { RoomsInfo } from '../request';

import RoomsIcon from '../../../assets/rooms-icon.png';

import dayjs from 'dayjs';

dayjs.locale('zh-cn');

interface RoomPageProps {
  roomsInfo?: RoomsInfo;
  screenSharingVisible?: boolean;
}

const RoomsPage: React.FC<RoomPageProps> = ({
  roomsInfo,
  screenSharingVisible,
}) => {
  const [time, setTime] = useState(dayjs().format('HH:mm'));
  const [date, setDate] = useState(dayjs().format('MM-DD'));
  const [week, setWeek] = useState(dayjs().format('dddd'));

  useEffect(() => {
    const now = dayjs(); // 获取当前时间的dayjs对象
    const currentSecond = now.second(); // 获取当前秒数

    setTimeout(() => {
      setTime(dayjs().format('HH:mm'));
      setInterval(() => {
        setTime(dayjs().format('HH:mm'));
      }, 1000 * 60);
    }, 1000 * (60 - currentSecond));

    setInterval(() => {
      setDate(dayjs().format('MM-DD'));
    }, 1000 * 60 * 60 * 24);
    setInterval(() => {
      setWeek(dayjs().format('dddd'));
    }, 1000 * 60 * 60 * 24);
  }, []);

  return (
    <div className={Styles.roomsInfoWrapper}>
      {roomsInfo && (
        <>
          <div className={Styles.roomsLogo}>
            <img
              className={Styles.roomsIcon}
              src={roomsInfo.brandInfo?.brandLogoUrl || RoomsIcon}
            />
            <div className={Styles.roomsTitle}>
              {roomsInfo.brandInfo?.brandName || '网易会议 Rooms'}
            </div>
          </div>
          {!screenSharingVisible && (
            <div className={Styles.roomsInfo}>
              <div className={Styles.roomsPosition}>{roomsInfo?.nickname}</div>
              <div className={Styles.timeWrapper}>
                <div className={Styles.time}>{time}</div>
                <div className={Styles.date}>
                  <span className={Styles.certainDate}>{date}</span>
                  <span>{week}</span>
                </div>
              </div>
              <div className={Styles.deviceId}>{roomsInfo?.pairingCode}</div>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default RoomsPage;
