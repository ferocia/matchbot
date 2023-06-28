import { Heading, Text, VStack } from "@chakra-ui/react";
import { useGameState } from "../GameContext";

const TeamHeader = ({ teamKey }) => {
  const state = useGameState();

  return (
    <VStack mb={15}>
      <Heading as="h2" size="lg" mb={0}>
        Team {teamKey == "team1" ? 1 : 2}
      </Heading>
      <Text fontSize="lg">
        Score:{" "}
        {state[teamKey].score !== null ? state[teamKey].score : "not set"}
      </Text>
    </VStack>
  );
};

export default TeamHeader;
