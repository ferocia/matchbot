import React, { useState, useReducer } from "react";
import { gql, useQuery, useMutation } from "@apollo/client";
import {
  Button,
  Container,
  Heading,
  Flex,
  Spacer,
  HStack,
  useToast,
} from "@chakra-ui/react";
import GamePicker from "../GamePicker";
import { initialState, gameReducer } from "./gameReducer";
import {
  DoubleDownButton,
  GameModeSwitch,
  ScoreSelector,
  PlayerSelector,
  LoadingPlaceholder,
} from "./components";

const QUERY = gql`
  query Players {
    players {
      id
      name
    }
    ...GamePickerQuery
  }
  ${GamePicker.fragments.query}
`;

const ADD_PLAYER = gql`
  mutation AddPlayer($name: String!) {
    createPlayer(name: $name) {
      player {
        id
        name
      }
    }
  }
`;

const SUBMIT_RESULT = gql`
  mutation SubmitResult($gameId: ID!, $results: [MatchResult!]!) {
    createMatch(gameId: $gameId, results: $results, postResultToSlack: true) {
      match {
        id
        text
      }
    }
  }
`;

export default function TableTennis() {
  const toast = useToast();
  const { loading, error, data } = useQuery(QUERY);
  const [state, dispatch] = useReducer(gameReducer, initialState);
  const [addPlayer] = useMutation(ADD_PLAYER, {
    update: (
      cache,
      {
        data: {
          createPlayer: { player },
        },
      }
    ) => {
      cache.writeQuery({
        query: QUERY,
        data: {
          ...data,
          players: [...data.players, player],
        },
      });
    },
  });

  const [submitResult] = useMutation(SUBMIT_RESULT);
  const [submitting, setSubmitting] = useState(false);
  console.log(state);
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

  const handlePlayerAdd = () => {
    const name = prompt("Enter the new player's name");

    if (name !== null && name !== "") {
      addPlayer({ variables: { name } });
    }
  };

  const handleResultSubmission = () => {
    setSubmitting(true);
    const toSubmit = [
      {
        players: [state.team1.player1, state.team1.player2].filter(Boolean),
        score: state.team1.score,
        place: state.team1.score > state.team2.score ? 1 : 2,
      },
      {
        players: [state.team2.player1, state.team2.player2].filter(Boolean),
        score: state.team2.score,
        place: state.team2.score > state.team1.score ? 1 : 2,
      },
    ];

    submitResult({ variables: { gameId: game.id, results: toSubmit } })
      .then((response) => {
        setSubmitting(false);
        dispatch({ type: "game_submitted" });
        toast({
          title: "Result submitted.",
          description: response.data.createMatch.match.text,
          status: "success",
          duration: 10000,
          isClosable: true,
          position: "top",
        });
      })
      .catch((e) => {
        setSubmitting(false);
        toast({
          title: "Submit failed.",
          description: e.message,
          status: "error",
          duration: 10000,
          isClosable: true,
          position: "top",
        });
      });
  };

  return (
    <Container maxWidth="container.md">
      <Heading pt="15">Table Tennis</Heading>

      <Flex>
        <GameModeSwitch isDouble={state.isDouble} dispatch={dispatch} />
        <Spacer />
        {state.previousGame.team1.player1 && (
          <DoubleDownButton dispatch={dispatch} />
        )}
      </Flex>

      <Heading as="h2" size="lg">
        Team 1
      </Heading>
      <HStack spacing="24px" justify="center">
        <PlayerSelector
          teamKey="team1"
          playerKey="player1"
          state={state}
          dispatch={dispatch}
          players={data.players}
        />
        {state.isDouble && (
          <PlayerSelector
            teamKey="team1"
            playerKey="player2"
            state={state}
            dispatch={dispatch}
            players={data.players}
          />
        )}
      </HStack>

      <ScoreSelector
        score={state.team1.score}
        teamKey="team1"
        dispatch={dispatch}
      />

      <Heading as="h2" size="lg">
        Team 2
      </Heading>
      <HStack spacing="24px" justify="center">
        <PlayerSelector
          teamKey="team2"
          playerKey="player1"
          state={state}
          dispatch={dispatch}
          players={data.players}
        />
        {state.isDouble && (
          <PlayerSelector
            teamKey="team2"
            playerKey="player2"
            state={state}
            dispatch={dispatch}
            players={data.players}
          />
        )}
      </HStack>

      <ScoreSelector
        score={state.team2.score}
        teamKey="team2"
        dispatch={dispatch}
      />

      <Flex>
        <Button
          onClick={() => handlePlayerAdd()}
          colorScheme="teal"
          variant="outline"
          mt="15"
        >
          Add player
        </Button>
        <Spacer />
        <Button
          onClick={handleResultSubmission}
          colorScheme="green"
          mt="15"
          isDisabled={submitting}
        >
          Submit
        </Button>
      </Flex>
    </Container>
  );
}
