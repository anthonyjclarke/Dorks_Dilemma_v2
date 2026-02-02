1000 REM auto booter
1010 REM
1020 REM (c) micro projects 1985
1030 REM
1040 a$="l "+CHR$(34)+"mega*"+CHR$(34)+" 08"+CHR$(13)
1050 a$=a$+"g3c00"+CHR$(13)+CHR$(13)+"obj"+CHR$(13)
1060 a$=a$+"l "+CHR$(34)+"muff"+CHR$(34)+" 08"+CHR$(13)
1070 a$=a$+"l "+CHR$(34)+"chars"+CHR$(34)+" 08"+CHR$(13)
1080 a$=a$+"g 1960"
1090 KEY 1,a$
1100 MONITOR
