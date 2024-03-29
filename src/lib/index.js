export function isMobile() {
  // 获取视口宽度
  const screenWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;

  // 定义移动设备的屏幕宽度上限
  const mobileWidthThreshold = 768; // 可以根据需要调整这个值

  // 判断是否为移动设备
  return screenWidth <= mobileWidthThreshold;
}
