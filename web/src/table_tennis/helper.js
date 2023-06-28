export function getOpponentScore(score) {
  if (score === null || score > 10) {
    return null;
  } else if (score < 10) {
    return 11;
  } else {
    return 12;
  }
}
