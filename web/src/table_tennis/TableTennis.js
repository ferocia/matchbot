import React, { useState, useRef } from "react";
import { gql, useQuery, useMutation } from "@apollo/client";
import {
  Box,
  Button,
  Container,
  Switch,
  Select,
  Heading,
  Stack,
  Flex,
  Skeleton,
  Spacer,
  HStack,
} from "@chakra-ui/react";
import GamePicker from "../GamePicker";
import ScrollButton from "./components/ScrollButton";

const QUERY = gql`
  query MatchEntry {
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
      }
    }
  }
`;

export default function TableTennis() {
  const gameState = {
    team1: {
      isDouble: false,
      players: [],
      score: null,
    },
    team2: {
      isDouble: false,
      players: [],
      score: null,
    },
    maxScore: 11,
  };

  const { loading, error, data } = useQuery(QUERY);
  const team1ScoreRef = useRef();
  const team2ScoreRef = useRef();
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
  const [results, setResults] = useState([]);
  const [submitting, setSubmitting] = useState(false);

  if (loading) {
    return (
      <Stack
        style={{
          padding: 5,
          display: "flex",
          flexDirection: "column",
        }}
      >
        <Skeleton height="20px" />
        <Skeleton height="20px" />
        <Skeleton height="20px" />
        <Skeleton height="20px" />
        <Skeleton height="20px" />
      </Stack>
    );
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
    const toSubmit = results.map((playerId, i) => ({
      players: [playerId],
      place: i + 1,
    }));

    submitResult({ variables: { gameId: game.id, results: toSubmit } })
      .then(() => {
        setSubmitting(false);
        setResults([]);
      })
      .catch((e) => {
        setSubmitting(false);
        alert(e.message);
      });
  };

  const handleScroll = (scroll, containerRef) => {
    const { current: container } = containerRef;
    const newScrollLeft = container.scrollLeft + scroll;

    container.scrollTo({ left: newScrollLeft });
  };

  return (
    <Container maxWidth="container.md">
      <Heading pt="15">Table Tennis</Heading>

      <Flex>
        <Box py="4">
          Single&nbsp;
          <Switch size="lg" id="game-mode" />
          &nbsp;Double
        </Box>
        <Spacer />
        <Box py="4">
          <Button colorScheme="blue" variant="outline" mt="-2">
            Double down
          </Button>
        </Box>
      </Flex>

      <Heading as="h2" size="lg">
        Team 1
      </Heading>
      <HStack spacing="24px" justify="center">
        <Select placeholder="Select player" maxWidth="md">
          {[...data.players]
            .sort(({ name: first }, { name: second }) =>
              first.localeCompare(second)
            )
            .map(({ name, id }) => (
              <option key={id} value={id}>
                {name}
              </option>
            ))}
        </Select>

        <Select placeholder="Select player" maxWidth="md">
          {[...data.players]
            .sort(({ name: first }, { name: second }) =>
              first.localeCompare(second)
            )
            .map(({ name, id }) => (
              <option key={id} value={id}>
                {name}
              </option>
            ))}
        </Select>
      </HStack>

      <HStack py="5" minW="100%" position="relative">
        <Stack
          position="absolute"
          top={0}
          bottom={0}
          left={0}
          justifyContent="center"
        >
          <ScrollButton
            buttonLocation="left"
            scroll={handleScroll}
            containerRef={team1ScoreRef}
          />
        </Stack>

        <HStack
          ref={team1ScoreRef}
          scrollBehavior="smooth"
          overflowX="hidden"
          spacing={4}
          minW="100%"
        >
          <Button variant="outline">0</Button>
          <Button variant="outline">1</Button>
          <Button variant="outline">2</Button>
          <Button variant="outline">3</Button>
          <Button variant="outline">4</Button>
          <Button variant="outline">5</Button>
          <Button variant="outline">6</Button>
          <Button variant="outline">7</Button>
          <Button variant="outline">8</Button>
          <Button variant="outline">9</Button>
          <Button variant="outline">10</Button>
          <Button variant="outline">11</Button>
          <Button variant="outline">12</Button>
          <Button variant="outline">13</Button>
          <Button variant="outline">14</Button>
          <Button variant="outline">15</Button>
          <Button variant="outline">16</Button>
          <Button variant="outline">17</Button>
          <Button variant="outline">18</Button>
          <Button variant="outline">19</Button>
          <Button variant="outline">20</Button>
          <Button variant="outline">21</Button>
          <Button variant="outline">22</Button>
          <Button variant="outline">23</Button>
          <Button variant="outline">24</Button>
          <Button variant="outline">25</Button>
          <Button variant="outline">26</Button>
          <Button variant="outline">27</Button>
          <Button variant="outline">28</Button>
          <Button variant="outline">29</Button>
          <Button variant="outline">30</Button>
          <Button variant="outline">31</Button>
        </HStack>

        <Stack
          position="absolute"
          top={0}
          bottom={0}
          right={0}
          justifyContent="center"
        >
          <ScrollButton
            buttonLocation="right"
            scroll={handleScroll}
            containerRef={team1ScoreRef}
          />
        </Stack>
      </HStack>

      <Heading as="h2" size="lg">
        Team 2
      </Heading>
      <HStack spacing="24px" justify="center">
        <Select placeholder="Select player" maxWidth="md">
          {[...data.players]
            .sort(({ name: first }, { name: second }) =>
              first.localeCompare(second)
            )
            .map(({ name, id }) => (
              <option key={id} value={id}>
                {name}
              </option>
            ))}
        </Select>

        {/* <Select placeholder="Select player" maxWidth="md">
          {[...data.players]
            .sort(({ name: first }, { name: second }) =>
              first.localeCompare(second)
            )
            .map(({ name, id }) => (
              <option key={id} value={id}>
                {name}
              </option>
            ))}
        </Select> */}
      </HStack>

      <HStack py="5" minW="100%" position="relative">
        <Stack
          position="absolute"
          top={0}
          bottom={0}
          left={0}
          justifyContent="center"
        >
          <ScrollButton
            buttonLocation="left"
            scroll={handleScroll}
            containerRef={team2ScoreRef}
          />
        </Stack>

        <HStack
          ref={team2ScoreRef}
          scrollBehavior="smooth"
          overflowX="hidden"
          spacing={4}
          minW="100%"
        >
          <Button variant="outline">0</Button>
          <Button variant="outline">1</Button>
          <Button variant="outline">2</Button>
          <Button variant="outline">3</Button>
          <Button variant="outline">4</Button>
          <Button variant="outline">5</Button>
          <Button variant="outline">6</Button>
          <Button variant="outline">7</Button>
          <Button variant="outline">8</Button>
          <Button variant="outline">9</Button>
          <Button variant="outline">10</Button>
          <Button variant="outline">11</Button>
          <Button variant="outline">12</Button>
          <Button variant="outline">13</Button>
          <Button variant="outline">14</Button>
          <Button variant="outline">15</Button>
          <Button variant="outline">16</Button>
          <Button variant="outline">17</Button>
          <Button variant="outline">18</Button>
          <Button variant="outline">19</Button>
          <Button variant="outline">20</Button>
          <Button variant="outline">21</Button>
          <Button variant="outline">22</Button>
          <Button variant="outline">23</Button>
          <Button variant="outline">24</Button>
          <Button variant="outline">25</Button>
          <Button variant="outline">26</Button>
          <Button variant="outline">27</Button>
          <Button variant="outline">28</Button>
          <Button variant="outline">29</Button>
          <Button variant="outline">30</Button>
          <Button variant="outline">31</Button>
        </HStack>

        <Stack
          position="absolute"
          top={0}
          bottom={0}
          right={0}
          justifyContent="center"
        >
          <ScrollButton
            buttonLocation="right"
            scroll={handleScroll}
            containerRef={team2ScoreRef}
          />
        </Stack>
      </HStack>

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
        <Button onClick={handleResultSubmission} colorScheme="green" mt="15">
          Submit
        </Button>
      </Flex>
    </Container>
  );
}
