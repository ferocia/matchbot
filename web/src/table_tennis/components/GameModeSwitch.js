import { Box, Switch } from "@chakra-ui/react";

const GameModeSwitch = ({ isDouble, dispatch }) => {
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
        isChecked={isDouble}
        onChange={handleToggle}
        size="lg"
        id="game-mode"
      />
      &nbsp;Double
    </Box>
  );
};

export default GameModeSwitch;
