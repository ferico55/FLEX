module.exports = (robot) ->
 robot.respond /deploy (.*)$/i, (msg) ->
    hostname = msg.match[1]
    @exec = require('child_process').exec
    command = "cd .. && fastlane #{hostname}"

    msg.send "Deploying to #{hostname}..."
    msg.send "This is the command #{command}."

    @exec command, (error, stdout, stderr) ->
      msg.send error
      msg.send stderr
