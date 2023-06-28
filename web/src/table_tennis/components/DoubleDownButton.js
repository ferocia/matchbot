import { Box, Button } from "@chakra-ui/react";
import { useGameDispatch } from "../GameContext";

const DoubleDownButton = () => {
  const dispatch = useGameDispatch();

  const handleDoubleDown = () => {
    dispatch({ type: "double_down" });
  };

  return (
    <Box py="4">
      <Button
        colorScheme="blue"
        variant="outline"
        mt="-2"
        onClick={handleDoubleDown}
      >
        Double down
      </Button>
    </Box>
  );
};

export default DoubleDownButton;
