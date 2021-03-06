// Generated by CoffeeScript 1.6.3
(function() {
  var connect, current, gameActive, getDiceScore, getFarkle, io, players, port, server;

  port = process.env.PORT || 5000;

  connect = require('connect');

  server = connect.createServer(connect["static"](__dirname)).listen(port);

  io = require('socket.io').listen(server);

  io.configure('production', function() {
    return io.set('transports', ['xhr-polling']);
  });

  getDiceScore = function(str) {
    switch (str) {
      case '5':
        return 50;
      case '1':
      case '55':
        return 100;
      case '15':
        return 150;
      case '222':
      case '11':
      case '155':
        return 200;
      case '115':
      case '2225':
        return 250;
      case '333':
      case '1155':
      case '1222':
      case '22255':
        return 300;
      case '3335':
      case '12225':
        return 350;
      case '444':
      case '11222':
      case '122255':
      case '1333':
      case '33355':
        return 400;
      case '112225':
      case '13335':
      case '4445':
        return 450;
      case '111':
      case '555':
      case '11333':
      case '133355':
      case '1444':
      case '44455':
        return 500;
      case '1133355':
      case '14445':
      case '1115':
        return 550;
      case '666':
      case '11444':
      case '144455':
      case '1555':
      case '11155':
        return 600;
      case '114445':
      case '5666':
        return 650;
      case '1666':
      case '55666':
        return 700;
      case '15666':
        return 750;
      case '11666':
        return 800;
      case '115666':
        return 850;
      case '1111':
      case '2222':
      case '3333':
      case '4444':
      case '5555':
      case '6666':
        return 1000;
      case '11115':
      case '22225':
      case '33335':
      case '44445':
      case '56666':
        return 1050;
      case '12222':
      case '13333':
      case '14444':
      case '15555':
      case '16666':
        return 1100;
      case '122225':
      case '133335':
      case '144445':
      case '156666':
        return 1150;
      case '123456':
      case '111222':
      case '111333':
      case '111444':
      case '111555':
      case '111666':
      case '222333':
      case '222444':
      case '222555':
      case '222666':
      case '333444':
      case '333555':
      case '333666':
      case '444555':
      case '444666':
      case '555666':
      case '111122':
      case '111133':
      case '111144':
      case '111155':
      case '111166':
      case '112222':
      case '112233':
      case '112244':
      case '112255':
      case '112266':
      case '113333':
      case '113344':
      case '113355':
      case '113366':
      case '114444':
      case '114455':
      case '114466':
      case '115566':
      case '116666':
      case '222233':
      case '222244':
      case '222255':
      case '222266':
      case '222233':
      case '223344':
      case '223355':
      case '223366':
      case '224444':
      case '224455':
      case '224466':
      case '225555':
      case '225566':
      case '226666':
      case '333344':
      case '333355':
      case '333366':
      case '334444':
      case '334455':
      case '334466':
      case '335555':
      case '335566':
      case '336666':
      case '444455':
      case '444466':
      case '445555':
      case '445566':
      case '446666':
        return 1500;
      case '11111':
      case '22222':
      case '33333':
      case '44444':
      case '55555':
      case '66666':
        return 2000;
      case '111115':
      case '222225':
      case '333335':
      case '444445':
      case '555556':
        return 2050;
      case '122222':
      case '133333':
      case '144444':
      case '155555':
      case '166666':
        return 2100;
      case '111111':
      case '222222':
      case '333333':
      case '444444':
      case '555555':
      case '666666':
        return 3000;
      default:
        return 0;
    }
  };

  getFarkle = function(str) {
    return str.indexOf('1') === -1 && str.indexOf('5') === -1 && str.indexOf('222') === -1 && str.indexOf('333') === -1 && str.indexOf('444') === -1 && str.indexOf('666') === -1 && str !== '223344' && str !== '223366' && str !== '224466' && str !== '334466';
  };

  gameActive = false;

  players = [];

  current = 0;

  io.sockets.on('connection', function(socket) {
    socket.on('setname', function(name) {
      socket.set('name', name);
      if (!gameActive) {
        players.push({
          id: socket.id,
          name: name,
          score: 0,
          risk: 0,
          dice: [Math.floor(Math.random() * 5.99) + 1, Math.floor(Math.random() * 5.99) + 1, Math.floor(Math.random() * 5.99) + 1, Math.floor(Math.random() * 5.99) + 1, Math.floor(Math.random() * 5.99) + 1, Math.floor(Math.random() * 5.99) + 1]
        });
        socket.emit('joined', {
          id: socket.id,
          name: name,
          players: players
        });
        return socket.broadcast.emit('newplayer', {
          id: socket.id,
          name: name
        });
      } else {
        return socket.emit('unavailable', {
          id: socket.id,
          name: name,
          players: players
        });
      }
    });
    socket.on('startgame', function() {
      gameActive = true;
      io.sockets.emit('started');
      current = 0;
      io.sockets.socket(players[current].id).emit('yourturn', {
        dice: players[current].dice
      });
      return io.sockets.emit('update', {
        info: "It's " + players[current].name + "&nbsp;<code class='id'>" + (players[current].id.slice(0, 6)) + "</code>'s turn.",
        dice: players[current].dice,
        players: players,
        playing: {
          id: players[current].id,
          name: players[current].name
        }
      });
    });
    socket.on('disconnect', function() {
      var i, _i, _ref, _results;
      _results = [];
      for (i = _i = 0, _ref = players.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (players[i].id === socket.id) {
          players.splice(i, 1);
          if (players.length === 0) {
            gameActive = false;
            io.sockets.emit('update', {
              info: "All players have left the game. Refresh to rejoin.",
              dice: [],
              players: [],
              playing: {
                id: null,
                name: null
              }
            });
          } else {
            socket.get('name', function(err, name) {
              return io.sockets.emit('update', {
                info: "" + name + "&nbsp;<code class='id'>" + (socket.id.slice(0, 6)) + "</code> disconnected. " + players.length + " players remain.",
                dice: players[current].dice,
                players: players,
                playing: {
                  id: players[current].id,
                  name: players[current].name
                }
              });
            });
            if (current > players.length - 2) {
              current = 0;
              io.sockets.socket(players[current].id).emit('yourturn', {
                dice: players[current].dice
              });
            }
          }
          break;
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
    socket.on('submitdice', function(data) {
      var cheater, d, d2, ds, i, _i, _j, _k, _l, _m, _n, _ref, _ref1, _ref2, _ref3, _ref4;
      d = data.dice.filter(function(el) {
        return el.s;
      });
      d.sort(function(a, b) {
        return a.n - b.n;
      });
      ds = d.map(function(el) {
        return el.n;
      }).join('');
      d2 = getDiceScore(ds);
      if (d2 === 0) {
        cheater = current;
        current = (current + 1) % players.length;
        socket.emit('turnover');
        io.sockets.emit('update', {
          info: "It's " + players[current].name + "&nbsp;<code class='id'>" + (players[current].id.slice(0, 6)) + "</code>'s turn.",
          dice: players[current].dice,
          players: players,
          playing: {
            id: players[current].id,
            name: players[current].name
          }
        });
        io.sockets.emit('cheat', {
          id: socket.id,
          name: players[cheater].name
        });
        return io.sockets.socket(players[current].id).emit('yourturn', {
          dice: players[current].dice
        });
      } else {
        for (_i = 0, _ref = ds.length; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--) {
          players[current].dice.pop();
        }
        if (players[current].dice.length === 0) {
          for (_j = 0; _j < 6; _j++) {
            players[current].dice.push(6);
          }
        }
        for (i = _k = 0, _ref1 = players[current].dice.length; 0 <= _ref1 ? _k < _ref1 : _k > _ref1; i = 0 <= _ref1 ? ++_k : --_k) {
          players[current].dice[i] = Math.floor(Math.random() * 5.99) + 1;
        }
        if (getFarkle(players[current].dice.join(''))) {
          players[current].score -= players[current].risk;
          players[current].risk = 0;
          for (_l = 0, _ref2 = 6 - players[current].dice.length; 0 <= _ref2 ? _l < _ref2 : _l > _ref2; 0 <= _ref2 ? _l++ : _l--) {
            players[current].dice.push(6);
          }
          for (i = _m = 0, _ref3 = players[current].dice.length; 0 <= _ref3 ? _m < _ref3 : _m > _ref3; i = 0 <= _ref3 ? ++_m : --_m) {
            players[current].dice[i] = Math.floor(Math.random() * 5.99) + 1;
          }
          while (getFarkle(players[current].dice.join(''))) {
            for (i = _n = 0, _ref4 = players[current].dice.length; 0 <= _ref4 ? _n < _ref4 : _n > _ref4; i = 0 <= _ref4 ? ++_n : --_n) {
              players[current].dice[i] = Math.floor(Math.random() * 5.99) + 1;
            }
          }
          io.sockets.emit('update', {
            info: "" + players[current].name + "&nbsp;<code class='id'>" + (players[current].id.slice(0, 6)) + "</code> farkled!",
            dice: players[current].dice,
            players: players,
            playing: {
              id: players[(current + 1) % players.length].id,
              name: players[(current + 1) % players.length].name
            }
          });
          current = (current + 1) % players.length;
          socket.emit('farkle');
          return io.sockets.socket(players[current].id).emit('yourturn', {
            dice: players[current].dice
          });
        } else {
          players[current].risk += d2;
          players[current].score += d2;
          socket.emit('continue', {
            dice: players[current].dice,
            score: players[current].score,
            risk: players[current].risk
          });
          return io.sockets.emit('update', {
            info: "" + players[current].name + "&nbsp;<code class='id'>" + (players[current].id.slice(0, 6)) + "</code> is risking " + players[current].risk + "!",
            dice: players[current].dice,
            players: players,
            playing: {
              id: players[current].id,
              name: players[current].name
            }
          });
        }
      }
    });
    return socket.on('endturn', function(data) {
      var d, d2, ds, i, leaders, _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3;
      d = data.dice.filter(function(el) {
        return el.s;
      });
      d.sort(function(a, b) {
        return a.n - b.n;
      });
      ds = d.map(function(el) {
        return el.n;
      }).join('');
      d2 = getDiceScore(ds);
      if (d2 === 0) {
        io.sockets.emit('cheat', {
          id: socket.id,
          name: players[current].name
        });
      } else {
        for (_i = 0, _ref = ds.length; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--) {
          players[current].dice.pop();
        }
        for (_j = 0, _ref1 = 6 - players[current].dice.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; 0 <= _ref1 ? _j++ : _j--) {
          players[current].dice.push(6);
        }
        for (i = _k = 0, _ref2 = players[current].dice.length; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; i = 0 <= _ref2 ? ++_k : --_k) {
          players[current].dice[i] = Math.floor(Math.random() * 5.99) + 1;
        }
        while (getFarkle(players[current].dice.join(''))) {
          for (i = _l = 0, _ref3 = players[current].dice.length; 0 <= _ref3 ? _l < _ref3 : _l > _ref3; i = 0 <= _ref3 ? ++_l : --_l) {
            players[current].dice[i] = Math.floor(Math.random() * 5.99) + 1;
          }
        }
        players[current].score += d2;
        players[current].risk = 0;
        io.sockets.emit('update', {
          info: "" + players[current].name + "&nbsp;<code class='id'>" + (players[current].id.slice(0, 6)) + "</code> banked for " + players[current].score + " points!",
          dice: players[(current + 1) % players.length].dice,
          players: players,
          playing: {
            id: players[(current + 1) % players.length].id,
            name: players[(current + 1) % players.length].name
          }
        });
      }
      current = (current + 1) % players.length;
      socket.emit('turnover', {
        score: players[current].score
      });
      if (current === 0) {
        leaders = players.slice(0);
        leaders.sort(function(a, b) {
          return b.score - a.score;
        });
        if (leaders[0].score >= 10000) {
          io.sockets.emit('gameover', {
            leaders: leaders
          });
          return;
        }
      }
      return io.sockets.socket(players[current].id).emit('yourturn', {
        dice: players[current].dice
      });
    });
  });

}).call(this);
