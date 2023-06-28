export function getOpponentScore(score) {
  if (score === null || score > 10) {
    return null;
  } else if (score < 10) {
    return 11;
  } else {
    return 12;
  }
}

export function isValidState(state) {
  // Validate players
  if (state.team1.player1 === null || state.team2.player1 === null) {
    return false;
  }
  if (
    state.isDouble &&
    (state.team1.player2 === null || state.team2.player2 === null)
  ) {
    return false;
  }

  // Validate scores
  if (state.team1.score === null || state.team2.score === null) {
    return false;
  }

  const maxScore = Math.max(state.team1.score, state.team2.score);
  const minScore = Math.min(state.team1.score, state.team2.score);
  if (minScore < 10 && maxScore !== 11) {
    return false;
  } else if (minScore === 10 && maxScore !== 12) {
    return false;
  } else if (minScore > 10 && maxScore - minScore !== 2) {
    return false;
  }

  return true;
}
