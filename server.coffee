port = process.env.PORT || 5000

connect = require('connect')
server = connect.createServer(connect.static(__dirname)).listen(port)
io = require('socket.io').listen(server)

io.configure 'production', () ->
  io.set 'transports', ['xhr-polling']

getDiceScore = (str) ->
  switch str
    when '5' then return 50
    when '1', '55' then return 100
    when '15' then return 150
    when '222', '11', '155' then return 200
    when '115', '2225' then return 250
    when '333', '1155', '1222', '22255' then return 300
    when '3335', '12225' then return 350
    when '444', '11222', '122255', '1333', '33355' then return 400
    when '112225', '13335', '4445' then return 450
    when '111', '555', '11333', '133355', '1444', '44455' then return 500
    when '1133355', '14445', '1115' then return 550
    when '666', '11444', '144455', '1555', '11155' then return 600
    when '114445', '5666' then return 650
    when '1666', '55666' then return 700
    when '15666' then return 750
    when '11666' then return 800
    when '115666' then return 850
    when '1111', '2222', '3333', '4444', '5555', '6666' then return 1000
    when '11115', '22225', '33335', '44445', '56666' then return 1050
    when '12222', '13333', '14444', '15555', '16666' then return 1100
    when '122225', '133335', '144445', '156666' then 1150
    when '123456', '111222', '111333', '111444', '111555', '111666', '222333', '222444', '222555', '222666', '333444', '333555', '333666', '444555', '444666', '555666', '111122', '111133', '111144', '111155', '111166', '112222', '112233', '112244', '112255', '112266', '113333', '113344', '113355', '113366', '114444', '114455', '114466', '115566', '116666', '222233', '222244', '222255', '222266', '222233', '223344', '223355', '223366', '224444', '224455', '224466', '225555', '225566', '226666', '333344', '333355', '333366', '334444', '334455', '334466', '335555', '335566', '336666', '444455', '444466', '445555', '445566', '446666' then return 1500
    when '11111', '22222', '33333', '44444', '55555', '66666' then return 2000
    when '111115', '222225', '333335', '444445', '555556' then return 2050
    when '122222', '133333', '144444', '155555', '166666' then return 2100
    when '111111', '222222', '333333', '444444', '555555', '666666' then return 3000
    else return 0

getFarkle = (str) ->
  return (str.indexOf('1') is -1 and str.indexOf('5') is -1 and str.indexOf('222') is -1 and str.indexOf('333') is -1 and str.indexOf('444') is -1 and str.indexOf('666') is -1 and str isnt '223344' and str isnt '223366' and str isnt '224466' and str isnt '334466')

gameActive = false
players = []
current = 0

io.sockets.on 'connection', (socket) ->
  socket.on 'setname', (name) ->
    socket.set 'name', name
    if not gameActive
      players.push {id: socket.id, name: name, score: 0, risk: 0, dice: [Math.floor(Math.random() * 5.99) + 1,Math.floor(Math.random() * 5.99) + 1,Math.floor(Math.random() * 5.99) + 1,Math.floor(Math.random() * 5.99) + 1,Math.floor(Math.random() * 5.99) + 1,Math.floor(Math.random() * 5.99) + 1]}
      socket.emit 'joined', {id: socket.id, name: name, players: players}
      socket.broadcast.emit 'newplayer', {id: socket.id, name: name}
    else
      socket.emit 'unavailable', {id: socket.id, name: name, players: players}

  socket.on 'startgame', () ->
    gameActive = true
    io.sockets.emit 'started'

    current = 0
    io.sockets.socket(players[current].id).emit 'yourturn', {dice: players[current].dice}
    io.sockets.emit 'update', 
      info: "It's #{players[current].name}&nbsp;<code class='id'>#{players[current].id.slice(0,6)}</code>'s turn."
      dice: players[current].dice
      players: players
      playing: {id: players[current].id, name: players[current].name}

  socket.on 'disconnect', () ->
    for i in [0...players.length]
      if players[i].id is socket.id
        players.splice i, 1
        if players.length is 0
          gameActive = false
          io.sockets.emit 'update', 
            info: "All players have left the game. Refresh to rejoin."
            dice: []
            players: []
            playing: {id: null, name: null}
        else
          socket.get 'name', (err, name) ->
            io.sockets.emit 'update', 
              info: "#{name}&nbsp;<code class='id'>#{socket.id.slice(0,6)}</code> disconnected. #{players.length} players remain."
              dice: players[current].dice
              players: players
              playing: {id: players[current].id, name: players[current].name}
          if current > players.length - 2
            current = 0
            io.sockets.socket(players[current].id).emit 'yourturn', {dice: players[current].dice}
        break

  socket.on 'submitdice', (data) ->
    d = data.dice.filter (el) ->
      return el.s
    d.sort (a, b) ->
      return a.n - b.n
    ds = d.map((el) -> return el.n).join ''
    d2 = getDiceScore ds

    if d2 is 0
      cheater = current
      current = (current + 1) % players.length
      socket.emit 'turnover'
      io.sockets.emit 'update', 
        info: "It's #{players[current].name}&nbsp;<code class='id'>#{players[current].id.slice(0,6)}</code>'s turn."
        dice: players[current].dice
        players: players
        playing: {id: players[current].id, name: players[current].name}
      io.sockets.emit 'cheat', {id: socket.id, name: players[cheater].name}
      io.sockets.socket(players[current].id).emit 'yourturn', {dice: players[current].dice}
    else
      for [0...ds.length]
        players[current].dice.pop()
      if players[current].dice.length is 0
        for [0...6]
          players[current].dice.push 6
      for i in [0...players[current].dice.length]
        players[current].dice[i] = Math.floor(Math.random() * 5.99) + 1

      if getFarkle(players[current].dice.join '')
        players[current].score -= players[current].risk
        players[current].risk = 0
        for [0...(6 - players[current].dice.length)]
          players[current].dice.push 6
        for i in [0...players[current].dice.length]
          players[current].dice[i] = Math.floor(Math.random() * 5.99) + 1

        while getFarkle(players[current].dice.join '')
          for i in [0...players[current].dice.length]
            players[current].dice[i] = Math.floor(Math.random() * 5.99) + 1

        io.sockets.emit 'update', 
          info: "#{players[current].name}&nbsp;<code class='id'>#{players[current].id.slice(0,6)}</code> farkled!"
          dice: players[current].dice
          players: players
          playing: {id: players[(current + 1) % players.length].id, name: players[(current + 1) % players.length].name}
        current = (current + 1) % players.length
        socket.emit 'farkle'
        io.sockets.socket(players[current].id).emit 'yourturn', {dice: players[current].dice}
      else
        players[current].risk += d2
        players[current].score += d2
        socket.emit 'continue', {dice: players[current].dice, score: players[current].score, risk: players[current].risk}
        io.sockets.emit 'update', 
          info: "#{players[current].name}&nbsp;<code class='id'>#{players[current].id.slice(0,6)}</code> is risking #{players[current].risk}!"
          dice: players[current].dice
          players: players
          playing: {id: players[current].id, name: players[current].name}

  socket.on 'endturn', (data) ->
    d = data.dice.filter (el) ->
      return el.s
    d.sort (a, b) ->
      return a.n - b.n
    ds = d.map((el) -> return el.n).join ''
    d2 = getDiceScore ds

    if d2 is 0
      io.sockets.emit 'cheat', {id: socket.id, name: players[current].name}
    else
      for [0...ds.length]
        players[current].dice.pop()
      for [0...(6 - players[current].dice.length)]
        players[current].dice.push 6

      for i in [0...players[current].dice.length]
        players[current].dice[i] = Math.floor(Math.random() * 5.99) + 1

      while getFarkle(players[current].dice.join '')
        for i in [0...players[current].dice.length]
          players[current].dice[i] = Math.floor(Math.random() * 5.99) + 1

      players[current].score += d2
      players[current].risk = 0

      io.sockets.emit 'update', 
        info: "#{players[current].name}&nbsp;<code class='id'>#{players[current].id.slice(0,6)}</code> banked for #{players[current].score} points!"
        dice: players[(current + 1) % players.length].dice
        players: players
        playing: {id: players[(current + 1) % players.length].id, name: players[(current + 1) % players.length].name}

    current = (current + 1) % players.length
    socket.emit 'turnover', {score: players[current].score}

    if current is 0
      leaders = players.slice 0
      leaders.sort((a, b) -> return b.score - a.score)
      if leaders[0].score >= 10000
        io.sockets.emit 'gameover', {leaders: leaders}
        return

    io.sockets.socket(players[current].id).emit 'yourturn', {dice: players[current].dice}