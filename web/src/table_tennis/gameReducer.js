export const initialState = {
  isDouble: false,
  team1: {
    player1: null,
    player2: null,
    score: null,
  },
  team2: {
    player1: null,
    player2: null,
    score: null,
  },
  previousGame: {
    isDouble: false,
    team1: {
      player1: null,
      player2: null,
    },
    team2: {
      player1: null,
      player2: null,
    },
  },
};

function getOpponentScores(score) {
  if (score < 10) {
    return [11];
  } else if (score === 10) {
    return [12];
  } else {
    return [score - 2, score + 2];
  }
}

export function gameReducer(state, action) {
  switch (action.type) {
    case "game_submitted": {
      return {
        ...initialState,
        previousGame: {
          isDouble: state.isDouble,
          team1: {
            player1: state.team1.player1,
            player2: state.team1.player2,
          },
          team2: {
            player1: state.team2.player1,
            player2: state.team2.player2,
          },
        },
      };
    }
    case "double_down": {
      const previous = state.previousGame;
      return {
        ...state,
        isDouble: previous.isDouble,
        team1: {
          player1: previous.team1.player1,
          player2: previous.team1.player2,
        },
        team2: {
          player1: previous.team2.player1,
          player2: previous.team2.player2,
        },
        previousGame: { ...initialState.previousGame },
      };
    }
    case "game_mode_toggled": {
      return {
        ...state,
        isDouble: action.isDouble,
        team1: {
          ...state.team1,
          player2: null,
        },
        team2: {
          ...state.team2,
          player2: null,
        },
      };
    }
    case "score_selected": {
      let team1 = state.team1;
      let team2 = state.team2;
      const opponentScores = getOpponentScores(action.score);
      if (action.teamKey == "team1") {
        team1 = {
          ...state.team1,
          score: action.score,
        };
        team2 = {
          ...state.team2,
          score: opponentScores.length == 1 ? opponentScores[0] : team2.score,
        };
      } else if (action.teamKey == "team2") {
        team2 = {
          ...state.team2,
          score: action.score,
        };
        team1 = {
          ...state.team1,
          score: opponentScores.length == 1 ? opponentScores[0] : team1.score,
        };
      }
      return {
        ...state,
        team1,
        team2,
      };
    }
    case "player_selected": {
      return {
        ...state,
        [action.teamKey]: {
          ...state[action.teamKey],
          [action.playerKey]: action.playerId,
        },
      };
    }
    default: {
      throw Error("Unknown action: " + action.type);
    }
  }
}
