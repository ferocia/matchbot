import { ContextProvider } from "./GameContext";
import Screen from "./Screen";

const TableTennis = () => (
  <ContextProvider>
    <Screen />
  </ContextProvider>
);

export default TableTennis;
