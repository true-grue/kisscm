set DICPATH=%~dp0/hunspell
%~dp0/hunspell/hunspell.exe -d en_US,ru_RU -l -i utf8 %*
