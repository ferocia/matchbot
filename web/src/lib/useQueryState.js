import { useState } from "react";
import qs from "query-string";

export default function useQueryState(key, defaultValue) {
  const initialValue = qs.parse(window.location.search)[key] || defaultValue;
  const [v, set] = useState(initialValue);

  const setter = (value) => {
    if (value === v) {
      return;
    }

    const parsed = qs.parse(window.location.search);
    parsed[key] = value;
    window.history.pushState(
      {},
      "MatchBot",
      `?${qs.stringify(parsed)}${window.location.hash}`
    );

    set(value);
  };

  return [v, setter];
}
