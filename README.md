_____________________________________________________________________________________________________

# Basic-Ruby-Twitch-Bot
This is a very basic framework for a twitch bot built in Ruby using twitch IRC connections
Feel free to download this and build upon / modify as per your requirements.

_____________________________________________________________________________________________________

Entry point (Rakefile) : 
    
The rakefile is set up to start the bot calling bot.rb when calling 'rake'

_____________________________________________________________________________________________________

Entry point (Procfile) :

The procfile is set up to start the bot calling bot.rb when being called by Heroku (To run it externally on a service)

_____________________________________________________________________________________________________

Usage : 
    
Typing in the console will send chat messages to the channel using the bot account.
    
Typing 'quit' in the console will stop the bot from running.

_____________________________________________________________________________________________________

# ENVIRONMENT VARIABLES 

Uses 'Figaro' gem to define local environment variables in config/application.yml ( If running locally via rakefile )

The entire config/* should be excluded from git commits via .gitignore (Set environment variables in you deployment process)

_____________________________________________________________________________________________________

AUTH_KEY : oauth:XXXXXXXXXXXXXXXXXXXXXXXX

BOT_USER : Requires the name of the bots twitch account

TWITCH_CHANNEL : Requires the name of the channel the bot will connect to
_____________________________________________________________________________________________________