export function getMeetingIdFromUrl(url) {
  const match = url.match(/meetingId=([^&]+)/);

  return match ? match[1] : null;
}
