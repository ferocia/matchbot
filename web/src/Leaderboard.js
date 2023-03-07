import React from 'react';
import { gql } from 'apollo-boost';
import { useQuery } from '@apollo/react-hooks';
import { Header, Table, Dimmer, Loader } from 'semantic-ui-react';
import useQueryState from './lib/useQueryState';
import GamePicker from './GamePicker';

const PICKER_QUERY = gql`
  query LeaderboardPicker {
    ...GamePickerQuery
  }
  ${GamePicker.fragments.query}
`;

const LEADERBOARD_QUERY = gql`
  query Leaderboard($gameId: ID!) {
    game(id: $gameId) {
      leaderboard {
        player {
          id
          name
        }
        mean
        playCount
      }
    }
  }
`;

const roundToFour = (num) => {
  num = num * 10000;
  num = Math.round(num);
  return num / 10000;
};

export default function Leaderboard() {
  const [gameId, setGameId] = useQueryState('gameId', null);
  const picker = useQuery(PICKER_QUERY);
  const leaderboard = useQuery(LEADERBOARD_QUERY, { variables: { gameId } });

  console.log(leaderboard);

  if (picker.error) {
    return <p>There was an error: {picker.error.message}</p>;
  }

  if (leaderboard.error) {
    return <p>There was an error: {leaderboard.error.message}</p>;
  }

  return (
    <div
      style={{
        padding: 5,
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      <Header as="h1">Leaderboard</Header>
      <GamePicker
        data={picker.data}
        loading={picker.loading}
        value={gameId}
        onChange={setGameId}
      />
      {leaderboard.loading ? (
        <Dimmer active>
          <Loader />
        </Dimmer>
      ) : null}
      {leaderboard.data != null ? (
        <Table celled>
          <Table.Header>
            <Table.Row>
              <Table.HeaderCell>Rank</Table.HeaderCell>
              <Table.HeaderCell>Name</Table.HeaderCell>
              <Table.HeaderCell>Mean Score</Table.HeaderCell>
              <Table.HeaderCell>Number Played</Table.HeaderCell>
            </Table.Row>
          </Table.Header>

          <Table.Body>
            {leaderboard.data.game.leaderboard
              .filter(({ playCount }) => playCount !== 0)
              .map(({ player: { name, id }, mean, playCount }, i) => (
                <Table.Row key={id}>
                  <Table.Cell collapsing>{i + 1}</Table.Cell>
                  <Table.Cell>{name}</Table.Cell>
                  <Table.Cell>{roundToFour(mean)}</Table.Cell>
                  <Table.Cell>{playCount}</Table.Cell>
                </Table.Row>
              ))}
          </Table.Body>
        </Table>
      ) : null}
    </div>
  );
}
