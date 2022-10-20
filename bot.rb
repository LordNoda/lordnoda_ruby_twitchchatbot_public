require 'socket'
require 'logger'
require 'figaro'

# Load Figaro variables
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

class Twitch_Bot

  attr_reader :running, :socket, :twitch_bot_auth, :twitch_bot_user, :twitch_channel, :logger, :commands

  def initialize(logger = nil)
    @logger = logger || Logger.new(STDOUT)
    # BOT RUN VARIABLES
    @running = false
    @socket = nil
    # SET UP CLIENT VARIABLES (ENVIRONMENT VARIABLES)
    @twitch_bot_auth = "#{ENV['AUTH_KEY']}".strip.downcase #oauth:XXXXXXXXXXXXXXXXXXXXXXXX
    @twitch_bot_user = "#{ENV['BOT_USER']}".strip.downcase #TwitchBotUser
    @twitch_channel = "#{ENV['TWITCH_CHANNEL']}".strip.downcase #TwitchChannel
    # SET UP ALL COMMANDS (FROM COMMANDS.TXT LIST OF CommandName | Response)
    @commands = Hash.new
  end

  # JOIN CHANNEL
  def JoinChannel()
    logger.info("<JOINED> JOIN ##{twitch_channel}")
    socket.puts("JOIN ##{twitch_channel}");
  end

  # MESSAGE CHANNEL
  def Send(message)
    logger.info("<SENT> PRIVMSG ##{twitch_channel} :#{message}")
    socket.puts("PRIVMSG ##{twitch_channel} :#{message}");
  end

  # COMPILE COMMANDS LIST (IGNORE LINES BEGINNING WITH #)
  def CompileCommands()
    open("./commands.txt").each_line do |line|
      if (line[0].strip != '#' && line.strip.empty? != true)
        command = line.split('|')
        commands.store(command[0].strip.downcase, command[1].strip) # strip trailing/leading spaces and downcase key to avoid case sensitivity
      end
    end
  end

  # RUN COMMAND FROM MESSAGE
  def RunCommand(user, message)
    if (message[0] != '!')
      return # Dont do anything if not starting with !
    else
      logger.info("> #{user} | #{message}")
      command = message.downcase; # downcase to avoid case sensitivity
      exists = commands.key?(command)
      if (exists)
        response = commands.fetch(command);
        # Replace {user} value in response
        if (response.include? "{user}")
          response["{user}"] = user
        end
        # Send Response
        Send(response)
      end
    end
  end

  # STOP BOT
  def Stop
    @running = false;
  end

  def run
    logger.info('Initializing Bot...')

    # CONNECT TO SOCKET
    @socket = TCPSocket.new('irc.chat.twitch.tv', 6667)
    @running = true;

    # PASS AUTH
    socket.puts("PASS #{twitch_bot_auth}")
    socket.puts("NICK #{twitch_bot_user}")

    # JOIN CHANNEL]
    CompileCommands()
    JoinChannel()

    logger.info('Bot Connected...')

    # SOCKET PRINTS
    # MESSAGE FORMAT :<user>!<user>@<user>.tmi.twitch.tv PRIVMSG #<channel> :This is a sample message
    Thread.start do
      while (running) do
        ready = IO.select([socket])
        ready[0].each do |s|
          line = s.gets()
          # IF LINE IS EMPTY WE SKIP
          if line.nil? || line.empty?
            next
          end
          # PARSE THE LINE USING REGEX
          match = line.match(/:(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
          # Tip use https://rubular.com/
          user = match && match[1]
          message = match && match[4]

          if message
            RunCommand(user.strip, message.strip) #Always remove the trail and leading spaces
          end
        end
      end
    end
  end
end

def StartBot
  bot = Twitch_Bot.new
  bot.run

  # READ CONSOLE INPUT AND SEND THEM TO TWITCH CHANNEL
  while (bot.running) do
    if (!gets.nil?)
      command = gets.chomp
      if (command == "quit")
        bot.Stop()
      else
        # WRITE MESSAGE TO TWITCH CHANNEL
        bot.Send(command)
      end
    end
  end

  puts('Exit.')
end

StartBot()
