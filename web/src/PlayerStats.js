import React, { useState, useEffect } from "react";
import { gql, useQuery, useLazyQuery } from "@apollo/client";
import { Header, Dropdown } from "semantic-ui-react";
import {
  LineChart,
  Line,
  Tooltip,
  XAxis,
  YAxis,
  ResponsiveContainer,
} from "recharts";
import useQueryState from "./lib/useQueryState";
import GamePicker from "./GamePicker";

const PLAYER_DATA_QUERY = gql`
  query PlayerData($id: ID!, $gameId: ID!) {
    player(id: $id) {
      rating(gameId: $gameId) {
        mean
        ratingEvents {
          mean
          createdAt
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

export default function PlayerStats() {
  const [gameId, setGameId] = useQueryState("gameId", null);
  const [playerId, setPlayerId] = useState(null);
  const picker = useQuery(PICKER_QUERY);
  const [getPlayerData, playerData] = useLazyQuery(PLAYER_DATA_QUERY);

  useEffect(() => {
    if (gameId != null && playerId != null) {
      getPlayerData({ variables: { gameId, id: playerId } });
    }
  }, [gameId, playerId, getPlayerData]);

  if (picker.error) {
    return <p>There was an error: {picker.error.message}</p>;
  }

  const player = playerId
    ? picker.data.players.find(({ id }) => id === playerId)
    : null;
  const name = player ? player.name : null;

  const chartData =
    playerData.data != null && playerData.data.player.rating != null
      ? playerData.data.player.rating.ratingEvents.map(
          ({ mean, createdAt }) => ({
            name: new Date(createdAt * 1000).toLocaleString(),
            value: mean,
          })
        )
      : null;

  console.log(window.innerWidth);

  return (
    <div
      style={{
        padding: 5,
        display: "flex",
        flexDirection: "column",
      }}
    >
      <Header as="h1">Player Stats {name ? `for ${name}` : null}</Header>
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
        options={(picker.data || { players: [] }).players.map((p) => ({
          key: p.id,
          text: p.name,
          value: p.id,
        }))}
      />
      {playerData.data != null && playerData.data.player.rating == null ? (
        <p>No play history available for that player</p>
      ) : null}
      {chartData != null ? (
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={chartData} margin={{ top: 40 }}>
            <Tooltip />
            <YAxis />
            <XAxis dataKey="name" />
            <Line type="monotone" dataKey="value" stroke="#8884d8" />
          </LineChart>
        </ResponsiveContainer>
      ) : null}
    </div>
  );
}
