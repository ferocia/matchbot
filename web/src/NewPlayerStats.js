import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { gql } from 'apollo-boost';
import { useQuery, useLazyQuery } from '@apollo/react-hooks';
import { Header, Dropdown } from 'semantic-ui-react';
import { Chart } from 'react-charts';
import useQueryState from './lib/useQueryState';
import GamePicker from './GamePicker';

const ALL_PLAYER_DATA = gql`
  query GameRatingsData($gameId: ID!) {
    game(id: $gameId) {
      leaderboard {
        player {
          id
          name
        }
        ratingEvents {
          mean
          match {
            id
          }
        }
      }
    }
  }
`;

const PICKER_QUERY = gql`
  query LeaderboardPicker {
    ...GamePickerQuery
    players {
      id
      name
    }
  }
  ${GamePicker.fragments.query}
`;

const formatData = (data) => {
  if (data == null) {
    return null;
  }

  const allTimes = [
    ...new Set(
      data.game.leaderboard
        .map(({ ratingEvents }) => ratingEvents.map((r) => r.match.id))
        .reduce((a, c) => [...a, ...c], []),
    ),
  ].sort((a, b) => a - b);

  return data.game.leaderboard.map(
    ({ player: { name, id }, ratingEvents }) => ({
      playerId: id,
      label: name,
      data: ratingEvents.map(({ mean, match: { id } }, i) => [
        allTimes.indexOf(id),
        Math.floor(mean * 100),
      ]),
    }),
  );
};

export default function PlayerStats() {
  const [gameId, setGameId] = useQueryState('gameId', null);
  const [playerId, setPlayerId] = useState(null);
  const picker = useQuery(PICKER_QUERY);
  const [getGameData, gameData] = useLazyQuery(ALL_PLAYER_DATA);
  const chartData = useMemo(() => formatData(gameData.data), [gameData.data]);
  const axes = useMemo(
    () => [
      { primary: true, type: 'linear', position: 'bottom' },
      { type: 'linear', position: 'left' },
    ],
    [],
  );
  const getSeriesStyle = useCallback(
    (series) => ({
      strokeWidth:
        playerId && series.originalSeries.playerId === playerId ? 6 : 2,
    }),
    [playerId],
  );

  useEffect(() => {
    if (gameId != null) {
      getGameData({ variables: { gameId } });
    }
  }, [gameId, getGameData]);

  if (picker.error) {
    return <p>There was an error: {picker.error.message}</p>;
  }

  const player = playerId
    ? picker.data.players.find(({ id }) => id === playerId)
    : null;
  const name = player ? player.name : null;

  const playerNotAvailable =
    gameData.data != null &&
    gameData.data.game.leaderboard.find((l) => l.player.id === playerId) ==
      null;

  return (
    <div
      style={{
        padding: 5,
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      <Header as="h1">
        Overall Player Stats {name ? `for ${name}` : null}
      </Header>
      <p>This is experimental. It doesn't work quite right yet.</p>
      <GamePicker
        data={picker.data}
        loading={picker.loading}
        value={gameId}
        onChange={setGameId}
      />
      <Dropdown
        loading={picker.loading}
        onChange={(e, { value }) => setPlayerId(value)}
        placeholder="Choose Player"
        selection
        value={playerId}
        options={(picker.data || { players: [] }).players
          .sort((a, b) => a.name.localeCompare(b.name))
          .map((p) => ({
            key: p.id,
            text: p.name,
            value: p.id,
          }))}
      />
      {playerId != null && playerNotAvailable ? (
        <p>Player data not available for {name}</p>
      ) : null}
      {chartData != null ? (
        <div style={{ width: '100%', height: 600 }}>
          <Chart
            getSeriesStyle={getSeriesStyle}
            data={chartData}
            axes={axes}
            tooltip
          />
        </div>
      ) : null}
    </div>
  );
}
