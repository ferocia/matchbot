import { Select } from "@chakra-ui/react";
import { useGameDispatch, useGameState } from "../GameContext";

const PlayerSelector = ({ teamKey, playerKey, players }) => {
  const dispatch = useGameDispatch();
  const state = useGameState();

  const handleSelect = (event) => {
    dispatch({
      type: "player_selected",
      teamKey: teamKey,
      playerKey: playerKey,
      playerId: event.target.value,
    });
  };

  const selectedPlayerIds = [
    state.team1.player1,
    state.isDouble && state.team1.player2,
    state.team2.player1,
    state.isDouble && state.team2.player2,
  ].filter(Boolean);

  return (
    <Select
      placeholder="Select player"
      maxWidth="md"
      onChange={handleSelect}
      value={state[teamKey][playerKey] || ""}
    >
      {[...players]
        .sort(({ name: first }, { name: second }) =>
          first.localeCompare(second)
        )
        .map(({ name, id }) => (
          <option key={id} value={id} disabled={selectedPlayerIds.includes(id)}>
            {name}
          </option>
        ))}
    </Select>
  );
};

export default PlayerSelector;
