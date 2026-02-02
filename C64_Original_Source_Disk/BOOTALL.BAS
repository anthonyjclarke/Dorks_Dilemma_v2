10 REM boot editor/loader/dos
15 POKE53280,11:POKE53281,11
20 IFa=0THENa=1:LOAD"dos5.2",8,1
40 IFa=1THENa=2:LOAD"editor",8,1
50 IFa=2THENSYS52224:SYS49152
64000 REM Hex dump of binary trailer ...
64000 REM 0000 :  FF FF
64000 REM 2 byte(s) of trailer
