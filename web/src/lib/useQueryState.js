import { useState } from 'react';
import { parse, stringify } from 'query-string';

export default function useQueryState(key, defaultValue) {
  const initialValue = parse(window.location.search)[key] || defaultValue;
  const [v, set] = useState(initialValue);

  const setter = (value) => {
    if (value === v) {
      return;
    }

    const parsed = parse(window.location.search);
    parsed[key] = value;
    window.history.pushState(
      {},
      'MatchBot',
      `?${stringify(parsed)}${window.location.hash}`,
    );

    set(value);
  };

  return [v, setter];
}
