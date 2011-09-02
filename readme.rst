**Nethack Demigod IRC Bot**

FEATURES

- Deaths mentioned in channel as they happen
- Ability to search item database
- Random fortunes
- Top ten scoreboard

RUNNING

::

    ln -s /var/games/nethack/record record
    ln -s /var/games/nethack/logfile logfile
    perl nhbot.pl


COMMANDS

- @help - displays this menu
- @search <string> - searches database for given 
- @fortune - gets random fortune
- @topten - displays top ten nethack scores
