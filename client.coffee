players = []

ractive = new Ractive {
  el: 'container',
  template: '#template',
  data: {
    myId: null,
    myName: null,
    state: 'waiting',
    role: null,
    myTurn: false,
    dice: [{n: 6, s: false},{n: 6, s: false},{n: 6, s: false},{n: 6, s: false},{n: 6, s: false},{n: 6, s: false}]
    diceValue: 0,
    oldValue: 0,
    turnValue: 0,
    players: players,
    info: '',
  }
}

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

updateDice = () ->
  d = ractive.get('dice').filter (el) ->
    return el.s
  d.sort (a, b) ->
    return a.n - b.n
  d2 = getDiceScore d.map((el) -> return el.n).join ''
  ractive.set 'diceValue', d2
  ractive.set 'turnValue', d2 + ractive.get 'oldValue'

socket = io.connect()
socket.on 'connect', () ->
  ractive.set 'state', 'entry'

socket.on 'unavailable', (data) ->
  ractive.set 'myId', data.id.slice 0, 6
  ractive.set 'myName', data.name
  for p in data.players
    players.push {id: p.id, name: p.name, score: p.score}
  ractive.set 'role', 'spectator'
  ractive.set 'state', 'game'

socket.on 'joined', (data) ->
  console.log 'joined!'
  ractive.set 'myId', data.id.slice 0, 6
  ractive.set 'myName', data.name
  for p in data.players
    players.push {id: p.id, name: p.name, score: p.score}
  ractive.set 'role', 'player'
  ractive.set 'state', 'foyer'

socket.on 'newplayer', (data) ->
  players.push (id: data.id, name: data.name, score: 0)

socket.on 'started', (data) ->
  ractive.set 'state', 'game'

socket.on 'yourturn', (data) ->
  console.log data.dice
  ractive.set 'dice', data.dice.map (el) ->
    return {n: el, s: false}
  ractive.set 'myTurn', true

socket.on 'continue', (data) ->
  console.log data.dice
  ractive.set 'dice', data.dice.map (el) ->
    return {n: el, s: false}
  ractive.set 'oldValue', data.risk
  ractive.set 'info', "Your score is #{data.score}, of which you are risking #{data.risk}"

socket.on 'farkle', () ->
  ractive.set 'info', "You farkled!"
  ractive.set 'myTurn', false

socket.on 'turnover', (data) ->
  ractive.set 'oldValue', 0
  ractive.set 'turnValue', 0
  ractive.set 'diceValue', 0
  ractive.set 'info', "Your turn ended successfully."
  ractive.set 'myTurn', false

socket.on 'cheat', (data) ->
  ractive.set 'info', "#{data.name}&nbsp;<code class='id'>#{data.id.slice(0,6)}</code> cheated?"

socket.on 'update', (data) ->
  for p in players
    players.pop()
  for p in data.players
    players.push {id: p.id, name: p.name, score: p.score}
  ractive.set 'dice', data.dice.map (el) ->
    return {n: el, s: false}
  ractive.set 'info', data.info

socket.on 'gameover', (data) ->
  for p in players
    players.pop()
  for p in data.leaders
    players.push {id: p.id, name: p.name, score: p.score}
  ractive.set 'state', 'afterparty'

ractive.on
  setname: (e) ->
    socket.emit 'setname', e.node.value
    ractive.set 'state', 'waiting'
  startgame: (e) ->
    console.log 'starting'
    socket.emit 'startgame'
  selectdie: (e) ->
    if ractive.get 'myTurn'
      ractive.set "dice[#{e.node.getAttribute('data-i')}].s", !ractive.get "dice[#{e.node.getAttribute('data-i')}].s"
      updateDice()
  submitdice: (e) ->
    socket.emit 'submitdice', {dice: ractive.get 'dice'}
  endturn: (e) ->
    socket.emit 'endturn', {dice: ractive.get 'dice'}