import React, { useState, useEffect } from 'react';
import { HashRouter as Router, Switch, Route } from 'react-router-dom';
import { Input, Button, Select, Checkbox, Divider, message } from 'antd';
import Login from './pages/login';
import Meeting from './pages/meeting';

import './App.global.css';

const NEMeetingKit = require('nemeeting-sdk').default;

const nemeeting = new NEMeetingKit();

export default function App() {
  useEffect(() => {
    const handleRelease = () => {
      nemeeting.unInitialize((errorObject: any) => {
        if (errorObject.code !== 0) {
          message.error(
            `反初始化失败：${errorObject.code}(${errorObject.msg})`
          );
        } else {
          // message.success('反初始化成功');
        }
      });
    };
    return () => {
      handleRelease();
    };
  }, []);

  return (
    <Router>
      <Switch>
        <Route
          exact
          path="/"
          render={(props) => <Login {...props} nemeeting={nemeeting} />}
        />
        <Route
          path="/meeting"
          render={(props) => <Meeting {...props} nemeeting={nemeeting} />}
        />
      </Switch>
    </Router>
  );
}
