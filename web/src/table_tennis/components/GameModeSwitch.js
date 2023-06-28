import { Box, Switch } from "@chakra-ui/react";
import { useGameDispatch, useGameState } from "../GameContext";

const GameModeSwitch = () => {
  const dispatch = useGameDispatch();
  const state = useGameState();

  const handleToggle = (event) => {
    dispatch({
      type: "game_mode_toggled",
      isDouble: event.target.checked,
    });
  };

  return (
    <Box py="4">
      Single&nbsp;
      <Switch
        isChecked={state.isDouble}
        onChange={handleToggle}
        size="lg"
        id="game-mode"
      />
      &nbsp;Double
    </Box>
  );
};

export default GameModeSwitch;
