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

export function gameReducer(state, action) {
  switch (action.type) {
    case "game_mode_toggled": {
      return {
        ...state,
        isDouble: action.isDouble,
      };
    }
    case "score_selected": {
      let team1 = state.team1;
      let team2 = state.team2;
      if (action.teamKey == "team1") {
        team1 = {
          ...state.team1,
          score: action.score,
        };
        team2 = { ...state.team2, score: action.score < 10 ? 11 : null };
      } else if (action.teamKey == "team2") {
        team2 = {
          ...state.team2,
          score: action.score,
        };
        team1 = { ...state.team1, score: action.score < 10 ? 11 : null };
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
