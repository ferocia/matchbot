import React from "react";
import { Dropdown } from "semantic-ui-react";
import { gql } from "@apollo/client";

export default function GamePicker({ loading, data, value, onChange }) {
  const { games } = data;
  return (
    <Dropdown
      loading={loading}
      onChange={(e, { value }) => onChange(value)}
      placeholder="Choose Game"
      selection
      value={value}
      options={games.map((g) => ({
        key: g.id,
        text: (
          <span style={{ display: "flex" }}>
            {g.emoji.raw || (
              <img
                alt={g.emoji.name}
                style={{ width: "1rem", marginRight: "6px" }}
                src={g.emoji.url}
              />
            )}
            {g.name}
          </span>
        ),
        value: g.id,
      }))}
    />
  );
}

GamePicker.fragments = {
  query: gql`
    fragment GamePickerQuery on Query {
      games {
        id
        name
        emoji {
          name
          raw
          url
        }
      }
    }
  `,
};
