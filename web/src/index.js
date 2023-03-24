import React from 'react';
import {createRoot} from 'react-dom/client';
import { ApolloProvider } from '@apollo/client';
import apollo from './apollo';
import MatchEntry from './MatchEntry';
import Leaderboard from './Leaderboard';
import PlayerStats from './PlayerStats';
import NewPlayerStats from './NewPlayerStats';

import './styles.css';
import { Tab } from 'semantic-ui-react';

const slugify = (text) =>
  text
    .replace(/[^A-Za-z ]/g, '')
    .toLowerCase()
    .split(' ')
    .join('-');

const tabs = [
  { menuItem: 'Match Entry', render: () => <MatchEntry /> },
  { menuItem: 'Leaderboard', render: () => <Leaderboard /> },
  { menuItem: 'Player Stats', render: () => <PlayerStats /> },
  { menuItem: 'Player Stats (Experimental)', render: () => <NewPlayerStats /> },
];

const tabSlugs = tabs.map((t) => slugify(t.menuItem));

function App() {
  let hash = window.location.hash.replace(/^#/, '');
  let defaultActiveIndex =
    hash !== '' && tabSlugs.includes(hash) ? tabSlugs.indexOf(hash) : 0;

  return (
    <ApolloProvider client={apollo}>
      <div className="App">
        <Tab
          panes={tabs}
          defaultActiveIndex={defaultActiveIndex}
          onTabChange={(_e, data) =>
            (window.location.hash = tabSlugs[data.activeIndex])
          }
        />
      </div>
    </ApolloProvider>
  );
}

const root = createRoot(document.getElementById('root'));
root.render(<App />);
