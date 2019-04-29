import React from 'react';
import Row from 'react';
import TeamCard from './TeamCard';
import './App.css';


function App() {
    return (
        <div>
          <div class="title">
            <h1> College Football Gambling </h1>
          </div>
          <Row>
              <TeamCard>

              </TeamCard>

          </Row>
        </div>
    );
}

export default App;
