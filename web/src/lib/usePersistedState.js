import { useState } from "react";

export default function usePersistedState(key, initialValue, reset = false) {
  const storedValue = window.localStorage.getItem(key) || initialValue;
  const value = reset ? initialValue : storedValue;

  const [v, set] = useState(value);

  const setter = (value) => {
    window.localStorage.setItem(key, value);
    set(value);
  };

  return [v, setter];
}
