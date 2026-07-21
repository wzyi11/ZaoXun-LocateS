export function centerImageOffset(viewportSize: number, imageSize: number): number {
  if (viewportSize <= 0 || imageSize <= 0) {
    return 0;
  }
  return (viewportSize - imageSize) / 2;
}

export function clampImageOffset(value: number, viewportSize: number, imageSize: number): number {
  if (viewportSize <= 0 || imageSize <= 0) {
    return 0;
  }
  if (imageSize <= viewportSize) {
    return centerImageOffset(viewportSize, imageSize);
  }
  const minOffset: number = viewportSize - imageSize;
  return Math.max(minOffset, Math.min(0, value));
}

export function normalizeImagePoint(
  rawPoint: number,
  imageOffset: number,
  imageSize: number,
  minRatio: number,
  maxRatio: number
): number {
  if (imageSize <= 0) {
    return minRatio;
  }
  const ratio: number = (rawPoint - imageOffset) / imageSize;
  return Math.max(minRatio, Math.min(maxRatio, ratio));
}
