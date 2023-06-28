import { gql, useQuery } from "@apollo/client";
import { Container, Heading, Flex, Spacer, HStack } from "@chakra-ui/react";
import GamePicker from "../GamePicker";
import {
  DoubleDownButton,
  GameModeSwitch,
  ScoreSelector,
  PlayerSelector,
  LoadingPlaceholder,
  SubmitButton,
  AddPlayerButton,
  TeamHeader,
} from "./components";
import { useGameState } from "./GameContext";

export const QUERY = gql`
  query Players {
    players {
      id
      name
    }
    ...GamePickerQuery
  }
  ${GamePicker.fragments.query}
`;

const Screen = () => {
  const { loading, error, data } = useQuery(QUERY);
  const state = useGameState();

  if (loading) {
    return <LoadingPlaceholder />;
  }

  if (error) {
    return <p>There was an error: {error.message}</p>;
  }

  if (!data) {
    return (
      <p>
        For some reason, there was no data returned{" "}
        <span role="img" aria-label="man shrugging">
          🤷‍♂️
        </span>
      </p>
    );
  }

  const game = data.games.find((game) => game.emoji.name == "ping_pong");

  return (
    <Container maxWidth="container.md">
      <Heading pt="15">🏓 Table Tennis</Heading>

      <Flex>
        <GameModeSwitch />
        <Spacer />
        {state.previousGame.team1.player1 && <DoubleDownButton />}
      </Flex>
      <TeamHeader teamKey={"team1"} />
      <HStack spacing="24px" justify="center">
        <PlayerSelector
          teamKey="team1"
          playerKey="player1"
          players={data.players}
        />
        {state.isDouble && (
          <PlayerSelector
            teamKey="team1"
            playerKey="player2"
            players={data.players}
          />
        )}
      </HStack>
      <ScoreSelector teamKey="team1" />

      <TeamHeader teamKey={"team2"} />
      <HStack spacing="24px" justify="center">
        <PlayerSelector
          teamKey="team2"
          playerKey="player1"
          players={data.players}
        />
        {state.isDouble && (
          <PlayerSelector
            teamKey="team2"
            playerKey="player2"
            players={data.players}
          />
        )}
      </HStack>
      <ScoreSelector teamKey="team2" />

      <Flex pb={15}>
        <AddPlayerButton data={data} />
        <Spacer />
        <SubmitButton gameId={game.id} />
      </Flex>
    </Container>
  );
};

export default Screen;
