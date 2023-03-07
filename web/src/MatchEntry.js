import React, { useState } from 'react';
import { gql } from 'apollo-boost';
import { useQuery, useMutation } from '@apollo/react-hooks';
import {
  Header,
  Button,
  Label,
  Dimmer,
  Loader,
  Checkbox,
} from 'semantic-ui-react';
import useQueryState from './lib/useQueryState';
import GamePicker from './GamePicker';

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

export default function MatchEntry() {
  const { loading, error, data } = useQuery(QUERY);
  const [addPlayer] = useMutation(ADD_PLAYER, {
    update: (
      cache,
      {
        data: {
          createPlayer: { player },
        },
      },
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
  const [gameId, setGameId] = useQueryState('gameId', null);
  const [results, setResults] = useState([]);
  const [invertResultEntry, setInvertResultEntry] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  if (loading) {
    return (
      <Dimmer active>
        <Loader />
      </Dimmer>
    );
  }

  if (error) {
    return <p>There was an error: {error.message}</p>;
  }

  if (!data) {
    return (
      <p>
        For some reason, there was no data returned{' '}
        <span role="img" aria-label="man shrugging">
          🤷‍♂️
        </span>
      </p>
    );
  }

  const handlePlayerPress = (id) => {
    setResults((res) => {
      const index = res.indexOf(id);
      if (index !== -1) {
        return res.filter((x) => x !== id);
      }
      if (invertResultEntry) {
        return [id, ...res];
      } else {
        return [...res, id];
      }
    });
  };

  const handlePlayerAdd = () => {
    const name = prompt("Enter the new player's name");

    if (name !== null && name !== '') {
      addPlayer({ variables: { name } });
    }
  };

  const handleResultSubmission = () => {
    setSubmitting(true);
    const toSubmit = results.map((playerId, i) => ({
      players: [playerId],
      place: i + 1,
    }));

    submitResult({ variables: { gameId, results: toSubmit } })
      .then(() => {
        setSubmitting(false);
        setResults([]);
      })
      .catch((e) => {
        setSubmitting(false);
        alert(e.message);
      });
  };

  return (
    <div
      style={{
        padding: 5,
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      <Header as="h1">Match Entry</Header>
      <GamePicker
        loading={loading}
        data={data}
        value={gameId}
        onChange={setGameId}
      />

      <div style={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap' }}>
        {data.players
          .sort(({ name: first }, { name: second }) =>
            first.localeCompare(second),
          )
          .map(({ name, id }) => (
            <Button
              style={{ margin: 4, padding: 24 }}
              active={results.includes(id)}
              key={id}
              onClick={() => handlePlayerPress(id)}
            >
              {name.toLowerCase()}
            </Button>
          ))}
        <Button
          color="green"
          basic
          style={{ margin: 4 }}
          onClick={() => handlePlayerAdd()}
        >
          +
        </Button>
      </div>

      <div
        style={{
          width: '100%',
          display: 'flex',
          flexDirection: 'column',
          position: 'absolute',
          bottom: 0,
        }}
      >
        {results.length > 0 && <Header as="h4">Results</Header>}
        <div style={{ marginBottom: 5 }}>
          {results.map((id, i) => {
            const position = i + 1;
            const player = data.players.find((p) => p.id === id);

            return (
              <Label key={id}>
                {position} {player.name}
              </Label>
            );
          })}
        </div>
        <div>
          <Checkbox
            label="Invert Result Entry (Last First)"
            checked={invertResultEntry}
            onChange={() => setInvertResultEntry((x) => !x)}
          />
        </div>
        <Button
          onClick={handleResultSubmission}
          positive
          disabled={results.length < 1 || submitting}
        >
          Submit
        </Button>
      </div>
    </div>
  );
}
