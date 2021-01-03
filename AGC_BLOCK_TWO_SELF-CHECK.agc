### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AGC_BLOCK_TWO_SELF-CHECK.agc
## Purpose:     A section of Luminary revision 163.
##              It is part of the reconstructed source code for the first
##              (unflown) release of the flight software for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 14.
##              The code has been recreated from a reconstructed copy of
##              Luminary 173, as well as Luminary memos 157 amd 158.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 163 in NASA
##              drawing 2021152N, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   pp. 1273-1282
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-08-21 MAS  Created from Luminary 173.

## Page 1273
# PROGRAM DESCRIPTION                                                         DATE  20 DECEMBER 1967
# PROGRAM NAME -  SELF-CHECK                                                  LOG SECTION AGC BLOCK TWO SELF-CHECK
# MOD NO -  1                                                                 ASSEMBLY SUBROUTINE UTILITYM REV 25
# MOD BY - GAUNTT


# FUNCTIONAL DESCRIPTION

#      PROGRAM HAS TWO MAIN PARTS. THE FIRST IS SELF-CHECK WHICH RUNS AS A ZERO PRIORITY JOB WITH NO CORE SET, AS
# PART OF THE BACK-UP IDLE LOOP. THE SECOND IS SHOW-BANKSUM WHICH RUNS AS A REGULAR EXECUTIVE JOB WITH ITS OWN
# STARTING VERB.
#      THE PURPOSE OF SELF-CHECK IS TO CHECK OUT VARIOUS PARTS OF THE COMPUTER AS OUTLINED BELOW IN THE OPTIONS.
#      THE PURPOSE OF SHOW-BANKSUM IS TO DISPLAY THE SUM OF EACH BANK , ONE AT A TIME.
#      IN ALL THERE ARE  7 POSSIBLE OPTIONS IN THIS BLOCK II VERSION OF SELF-CHECK. MORE DETAIL DESCRIPTION MAY BE
# FOUND IN E-2065 BLOCK II AGC SELF-CHECK AND SHOW BANKSUM BY EDWIN D. SMALLY DECEMBER 1966, AND ADDENDA 2 AND 3.
#      THE DIFFERENT OPTIONS ARE CONTROLLED BY PUTTING DIFFERENT NUMBERS IN THE SMODE REGISTER (NOUN 27). BELOW IS
# A DESCRIPTION OF WHAT PARTS OF THE COMPUTER THAT ARE CHECKED BY THE OPTIONS, AND THE CORRESPONDING NUMBER, IN
# OCTAL, TO LOAD INTO SMODE.
# +-4   ERASABLE MEMORY
# +-5   FIXED MEMORY
# +-1,2,3,6,7,10   EVERYTHING IN OPTIONS 4 AND 5.
# -0    SAME AS +-10 UNTIL AN ERROR IS DETECTED.
# +0    NO CHECK, PUTS COMPUTER INTO THE BACKUP IDLE LOOP.


# WARNINGS

#      USE OF E MEMORY RESERVED FOR SELF-CHECK (EVEN IN IDLE LOOP) AS TEMP STORAGE BY OTHER PROGRAMS IS DANGEROUS.
#      SMODE SET GREATER THAN OCT 10 PUTS COMPUTER INTO BACKUP IDLE LOOP.


# CALLING SEQUENCE

#      TO CALL SELF-CHECK KEY IN
#           V 21 N 27 E  OPTION NUMBER E
#      TO CALL SHOW-BANKSUM KEY IN
#           V 91 E         DISPLAYS FIRST BANK
#           V 33 E         PROCEED, DISPLAYS NEXT BANK


# EXIT MODES, NORMAL AND ALARM

#      SELF-CHECK NORMALLY CONTINUES INDEFINITELY UNLESS THERE IS AN ERROR DETECTED. IF SO + OPTION NUMBERS PUT
# COMPUTER INTO BACKUP IDLE LOOP, - OPTION NUMBERS RESTART THE OPTION.
#      THE -0 OPTION PROCEEDS FROM THE LINE FOLLOWING THE LINE WHERE THE ERROR WAS DETECTED.
#      SHOW-BANKSUM PROCEEDS UNTIL A TERMINATE IS KEYED IN (V 34 E). THE COMPUTER IS PUT INTO THE BACKUP IDLE LOOP
#


# OUTPUT
## Page 1274
#      SELF-CHECK UPON DETECTING AN ERROR LOADS THE SELF-CHECK ALARM CONSTANT (01102) INTO THE FAILREG SET AND
# TURNS ON THE ALARM LIGHT. THE OPERATOR MAY THEN DISPLAY THE THREE FAILREGS BY KEYING IN V 05 N 09 E. FOR FURTHER
# INFORMATION HE MAY KEY IN V 05 N 08 E, THE DSKY DISPLAY IN R1 WILL BE ADDRESS+1 OF WHERE THE ERROR WAS DETECTED,
# IN R2 THE BBCON OF SELF-CHECK, AND IN R3 THE TOTAL NUMBER OF ERRORS DETECTED BY SELF-CHECK SINCE THE LAST MAN
# INITIATED FRESH START (SLAP1).
#      SHOW-BANKSUM STARTING WITH BANK 0 DISPLAYS IN R1 THE BANK SUM (A +-NUMBER EQUAL TO THE BANK NUMBER), IN R2
# THE BANK NUMBER, AND IN R3 THE BUGGER WORD.


# ERASABLE INITIALIZATION REQUIRED

#      ACCOMPLISHED BY FRESH START
#           SMODE SET TO +0


# DEBRIS

#      ALL EXITS FROM THE CHECK OF ERASABLE (ERASCHK) RESTORE ORIGINAL CONTENTS TO REGISTERS UNDER CHECK.
# EXCEPTION IS A RESTART. RESTART THAT OCCURS DURING ERASCHK RESTORES ERASABLE, UNLESS THERE IS EVIDENCE TO DOUBT
# E MEMORY, IN WHICH CASE PROGRAM THEN DOES A FRESH START (DOFSTART).

                BANK            25
                SETLOC          SELFCHEC
                BANK

                COUNT*          $$/SELF
SBIT1           EQUALS          BIT1
SBIT2           EQUALS          BIT2
SBIT3           EQUALS          BIT3
SBIT4           EQUALS          BIT4
SBIT5           EQUALS          BIT5
SBIT6           EQUALS          BIT6
SBIT7           EQUALS          BIT7
SBIT8           EQUALS          BIT8
SBIT9           EQUALS          BIT9
SBIT10          EQUALS          BIT10
SBIT11          EQUALS          BIT11
SBIT12          EQUALS          BIT12
SBIT13          EQUALS          BIT13
SBIT14          EQUALS          BIT14
SBIT15          EQUALS          BIT15

S+ZERO          EQUALS          ZERO
S+1             EQUALS          BIT1
S+2             EQUALS          BIT2
S+3             EQUALS          THREE
S+4             EQUALS          FOUR
S+5             EQUALS          FIVE
S+6             EQUALS          SIX
## Page 1275
S+7             EQUALS          SEVEN
S8BITS          EQUALS          LOW8                            # 00377
CNTRCON         =               OCT50                           # USED IN CNTRCHK
ERASCON1        OCTAL           00061                           # USED IN ERASCHK
ERASCON2        OCTAL           01373                           # USED IN ERASCHK
ERASCON6        =               OCT1400                         # USED IN ERASCHK
ERASCON3        OCTAL           01461                           # USED IN ERASCHK
ERASCON4        OCTAL           01773                           # USED IN ERASCHK
S10BITS         EQUALS          LOW10                           # 01777, USED IN ERASCHK
SBNK03          EQUALS          PRIO6                           # 06000, USED IN ROPECHK
-MAXADRS        =               HI5                             # FOR ROPECHK
SIXTY           OCTAL           00060
SUPRCON         OCTAL           60017                           # USED IN ROPECHK
S13BITS         OCTAL           17777
CONC+S1         OCTAL           25252                           # USED IN CYCLSHFT
CONC+S2         OCTAL           52400                           # USED IN CYCLSHFT
ERASCON5        OCTAL           76777
S-7             =               OCT77770
S-4             EQUALS          NEG4
S-3             EQUALS          NEG3
S-2             EQUALS          NEG2
S-1             EQUALS          NEGONE
S-ZERO          EQUALS          NEG0

                EBANK=          LST1
ADRS1           ADRES           SKEEP1
SELFADRS        ADRES           SELFCHK                         # SELFCHK RETURN ADDRESS. SHOULD BE PUT
                                                                # IN SELFRET WHEN GOING FROM SELFCHK TO
                                                                # SHOWSUM AND PUT IN SKEEP1 WHEN GOING
                                                                # FROM SHOWSUM TO SELF-CHECK.

PRERRORS        CA              ERESTORE                        # IS IT NECESSARY TO RESTORE ERASABLE
                EXTEND
                BZF             ERRORS                          # NO
                EXTEND
                DCA             SKEEP5
                INDEX           SKEEP7
                DXCH            0000                            # RESTORE THE TWO ERASABLE REGISTERS
                CA              S+ZERO
                TS              ERESTORE
ERRORS          INHINT
                CA              Q
                TS              SFAIL                           # SAVE Q FOR FAILURE LOCATION
                TS              ALMCADR                         # FOR DISPLAY WITH BBANK AND ERCOUNT
                INCR            ERCOUNT                         # KEEP TRACK OF NUMBER OF MALFUNCTIONS.
TCALARM2        TC              ALARM2
                OCT             01102                           # SELF-CHECK MALFUNCTION INDICATOR
                CCS             SMODE
SIDLOOP         CA              S+ZERO
                TS              SMODE
## Page 1276
                TC              SELFCHK                         # GO TO IDLE LOOP
                TC              SFAIL                           # CONTINUE WITH SELF-CHECK

-1CHK           CCS             A
                TCF             PRERRORS
                TCF             PRERRORS
                CCS             A
                TCF             PRERRORS
                TC              Q

SMODECHK        EXTEND
                QXCH            SKEEP1
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CCS             SMODE
                TC              SOPTIONS
                TC              SMODECHK        +2              # TO BACKUP IDLE LOOP
                TC              SOPTIONS
                INCR            SCOUNT
                TC              SKEEP1                          # CONTINUE WITH SELF-CHECK

SOPTIONS        AD              S-7
                EXTEND
                BZMF            +2                              # FOR OPTIONS BELOW NINE.
BNKOPTN         TC              SIDLOOP                         # ILLEGAL OPTION.  GO TO IDLE LOOP.
                INCR            SCOUNT                          # FOR OPTIONS BELOW NINE.
                AD              S+7

                INDEX           A
                TC              SOPTION1
SOPTION1        TC              SKEEP1                          # WAS TC+TCF
SOPTION2        TC              SKEEP1                          # WAS IN:OUT1
SOPTION3        TC              SKEEP1                          # WAS COUNTCHK
SOPTION4        TC              ERASCHK
SOPTION5        TC              ROPECHK
SOPTION6        TC              SKEEP1
SOPTION7        TC              SKEEP1
SOPTON10        TC              SKEEP1                          # CONTINUE WITH SELF-CHECK

CHECKNJ         EXTEND
                QXCH            SELFRET                         # SAVE RETURN ADDRESS WHILE TESTING NEWJOB
                TC              POSTJUMP                        # TO SEE IF ANY JOBS HAVE BECOME ACTIVE.
                CADR            ADVAN

SELFCHK         TC              SMODECHK                        # ** CHARLEY, COME IN HERE

# SKEEP7 HOLDS LOWEST OF TWO ADDRESSES BEING CHECKED.
# SKEEP6 HOLDS B(X+1).
# SKEEP5 HOLDS B(X).
# SKEEP4 HOLDS C(EBANK) DURING ERASLOOP AND CHECKNJ.
# SKEEP3 HOLDS LAST ADDRESS BEING CHECKED (HIGHEST ADDRESS).
## Page 1277
# SKEEP2 CONTROLS CHECKING OF NON-SWITCHABLE ERASABLE MEMORY WITH BANK NUMBERS IN EB.
# ERASCHK TAKES APPROXMATELY 7 SECONDS
ERASCHK         CA              S+1
                TS              SKEEP2
0EBANK          CA              S+ZERO
                TS              EBANK
                CA              ERASCON3                        # 01461
                TS              SKEEP7                          # STARTING ADDRESS
                CA              S10BITS                         # 01777
                TS              SKEEP3                          # LAST ADDRESS CHECKED
                TC              ERASLOOP

E134567B        CA              ERASCON6                        # 01400
                TS              SKEEP7                          # STARTING ADDRESS
                CA              S10BITS                         # 01777
                TS              SKEEP3                          # LAST ADDRESS CHECKED
                TC              ERASLOOP

2EBANK          CA              ERASCON6                        # 01400
                TS              SKEEP7                          # STARTING ADDRESS
                CA              ERASCON4                        # 01773
                TS              SKEEP3                          # LAST ADDRESS CHECKED
                TC              ERASLOOP

NOEBANK         TS              SKEEP2                          # +0
                CA              ERASCON1                        # 00061
                TS              SKEEP7                          # STARTING ADDRESS
                CA              ERASCON2                        # 01373
                TS              SKEEP3                          # LAST ADDRESS CHECKED

ERASLOOP        INHINT
                CA              EBANK                           # STORES C(EBANK)
                TS              SKEEP4
                EXTEND
                NDX             SKEEP7
                DCA             0000
                DXCH            SKEEP5                          # STORES C(X) AND C(X+1) IN SKEEP6 AND 5.
                CA              SKEEP7
                TS              ERESTORE                        # IF RESTART, RESTORE C(X) AND C(X+1)
                TS              L
                INCR            L
                NDX             A
                DXCH            0000                            # PUTS OWN ADDRESS IN X AND X +1
                NDX             SKEEP7
                CS              0001                            # CS  X+1
                NDX             SKEEP7
                AD              0000                            # AD X
                TC              -1CHK
                CA              ERESTORE                        # HAS ERASABLE BEEN RESTORED
                EXTEND
## Page 1278
                BZF             ELOOPFIN                        # YES, EXIT ERASLOOP.
                EXTEND
                NDX             SKEEP7
                DCS             0000                            # COMPLEMENT OF ADDRESS OF X AND X+1
                NDX             SKEEP7
                DXCH            0000                            # PUT COMPLEMENT OF ADDRESS OF X AND X+1
                NDX             SKEEP7
                CS              0000                            # CS X
                NDX             SKEEP7
                AD              0001                            # AD X+1
                TC              -1CHK
                CA              ERESTORE                        # HAS ERASABLE BEEN RESTORED
                EXTEND
                BZF             ELOOPFIN                        # YES, EXIT ERASLOOP.
                EXTEND
                DCA             SKEEP5
                NDX             SKEEP7
                DXCH            0000                            # PUT B(X) AND B(X+1) BACK INTO X AND X+1
                CA              S+ZERO
                TS              ERESTORE                        # IF RESTART, DO NOT RESTORE C(X), C(X+1)
ELOOPFIN        RELINT
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CA              SKEEP4                          # REPLACES B(EBANK)
                TS              EBANK
                INCR            SKEEP7
                CS              SKEEP7
                AD              SKEEP3
                EXTEND
                BZF             +2
                TC              ERASLOOP                        # GO TO NEXT ADDRESS IN SAME BANK
                CCS             SKEEP2
                TC              NOEBANK
                INCR            SKEEP2                          # PUT +1 IN SKEEP2.
                CA              EBANK
                AD              SBIT9
                TS              EBANK
                AD              ERASCON5                        # 76777, CHECK FOR BANK E2
                EXTEND
                BZF             2EBANK
                CCS             EBANK
                TC              E134567B                        # GO TO EBANKS 1,3,4,5,6, AND 7
                CA              ERASCON6                        # END OF ERASCHK
                TS              EBANK
# CNTRCHK PERFORMS A CS OF ALL REGISTERS FROM OCT. 60 THROUGH OCT. 10.
# INCLUDED ARE ALL COUNTERS, T6-1, CYCLE AND SHIFT, AND ALL RUPT REGISTERS
CNTRCHK         CA              CNTRCON                         # 00050
CNTRLOOP        TS              SKEEP2
                AD              SBIT4                           # +10 OCTAL
                INDEX           A
                CS              0000
## Page 1279
                CCS             SKEEP2
                TC              CNTRLOOP

# CYCLSHFT CHECKS THE CYCLE AND SHIFT REGISTERS
CYCLSHFT        CA              CONC+S1                         # 25252
                TS              CYR                             # C(CYR) = 12525
                TS              CYL                             # C(CYL) = 52524
                TS              SR                              # C(SR) = 12525
                TS              EDOP                            # C(EDOP) = 00125
                AD              CYR                             # 37777         C(CYR) = 45252
                AD              CYL                             # 00-12524      C(CYL) = 25251
                AD              SR                              # 00-25251      C(SR) = 05252
                AD              EDOP                            # 00-25376      C(EDOP) = +0
                AD              CONC+S2                         # C(CONC+S2) = 52400
                TC              -1CHK
                AD              CYR                             # 45252
                AD              CYL                             # 72523
                AD              SR                              # 77775
                AD              EDOP                            # 77775
                AD              S+1                             # 77776
                TC              -1CHK

                INCR            SCOUNT          +1
                TC              SMODECHK
# SKEEP1 HOLDS SUM
# SKEEP2 HOLDS PRESENT CONTENTS OF ADDRESS IN ROPECHK AND SHOWSUM ROUTINES
# SKEEP2 HOLDS BANK NUMBER IN LOW ORDER BITS DURING SHOWSUM DISPLAY
# SKEEP3 HOLDS PRESENT ADDRESS (00000 TO 01777 IN COMMON FIXED BANKS)
#                              (04000 TO 07777 IN FXFX BANKS)
# SKEEP3 HOLDS BUGGER WORD DURING SHOWSUM DISPLAY
# SKEEP4 HOLDS BANK NUMBER AND SUPER BANK NUMBER
# SKEEP5 COUNTS 2 SUCCESSIVE TC SELF WORDS
# SKEEP6 CONTROLS ROPECHK OR SHOWSUM OPTION
# SKEEP7 CONTROLS WHEN ROUNTINE IS IN COMMON FIXED OR FIXED FIXED BANKS

ROPECHK         CA              S-ZERO                          # *
                TS              SKEEP6                          # * -0 FOR ROPECHK.
STSHOSUM        CA              S+ZERO                          # * SHOULD BE ROPECHK

                TS              SKEEP4                          # BANK NUMBER
                CA              S+1
COMMFX          TS              SKEEP7
                CA              S+ZERO
                TS              SKEEP1
                TS              SKEEP3
                CA              S+1
                TS              SKEEP5                          # COUNTS DOWN 2 TC SELF WORDS
COMADRS         CA              SKEEP4
                TS              L                               # TO SET SUPER BANK
                MASK            HI5
## Page 1280
                AD              SKEEP3
                TC              SUPDACAL                        # SUPER DATA CALL
                TC              ADSUM
                AD              SBIT11                          # 02000
                TC              ADRSCHK

FXFX            CS              A
                TS              SKEEP7
                EXTEND
                BZF             +3
                CA              SBIT12                          # 04000, STARTING ADDRESS OF BANK 02
                TC              +2
                CA              SBNK03                          # 06000, STARTING ADDRESS OF BANK 03
                TS              SKEEP3
                CA              S+ZERO
                TS              SKEEP1
                CA              S+1
                TS              SKEEP5                          # COUNTS DOWN 2 TC SELF WORDS
FXADRS          INDEX           SKEEP3
                CA              0000
                TC              ADSUM
                TC              ADRSCHK

ADSUM           TS              SKEEP2
                AD              SKEEP1
                TS              SKEEP1
                CAF             S+ZERO
                AD              SKEEP1
                TS              SKEEP1
                CS              SKEEP2
                AD              SKEEP3
                TC              Q

ADRSCHK         LXCH            A
                CA              SKEEP3
                MASK            LOW10                           # RELATIVE ADDRESS
                AD              -MAXADRS                        # SUBTRACT MAX RELATIVE ADDRESS = 1777.
                EXTEND
                BZF             SOPTION                         # CHECKSUM FINISHED IF LAST ADDRESS.
                CCS             SKEEP5                          # IS CHECKSUM FINISHED
                TC              +3                              # NO
                TC              +2                              # NO
                TC              SOPTION                         # GO TO ROPECHK SHOWSUM OPTION
                CCS             L                               # -0 MEANS A TC SELF WORD.
                TC              CONTINU
                TC              CONTINU
                TC              CONTINU
                CCS             SKEEP5
                TC              CONTINU         +1
                CA              S-1
## Page 1281
                TC              CONTINU         +1              # AD IN THE BUGGER WORD
CONTINU         CA              S+1                             # MAKE SURE TWO CONSECUTIVE TC SELF WORDS
                TS              SKEEP5
                CCS             SKEEP6                          # *
                CCS             NEWJOB                          # * +1, SHOWSUM
                TC              CHANG1                          # *
                TC              +2                              # *
                TC              CHECKNJ                         # -0 IN SKEEP6 FOR ROPECHK

ADRS+1          INCR            SKEEP3
                CCS             SKEEP7
                TC              COMADRS
                TC              COMADRS
                TC              FXADRS
                TC              FXADRS

NXTBNK          CS              SKEEP4
                AD              LSTBNKCH                        # LAST BANK TO BE CHECKED
                EXTEND
                BZF             ENDSUMS                         # END OF SUMMING OF BANKS.
                CA              SKEEP4
                AD              SBIT11
                TS              SKEEP4                          # 37 TO 40 INCRMTS SKEEP4 BY END RND CARRY
                TC              CHKSUPR
17TO20          CA              SBIT15
                ADS             SKEEP4                          # SET FOR BANK 20
                TC              GONXTBNK
CHKSUPR         MASK            HI5
                EXTEND
                BZF             NXTSUPR                         # INCREMENT SUPER BANK
27TO30          AD              S13BITS
                EXTEND
                BZF             +2                              # BANK SET FOR 30
                TC              GONXTBNK
                CA              SIXTY                           # FIRST SUPER BANK
                ADS             SKEEP4
                TC              GONXTBNK
NXTSUPR         AD              SUPRCON                         # SET BNK 30 + INCR SUPR BNK AND CANCEL
                ADS             SKEEP4                          # ERC BIT OF THE 37 TO 40 ADVANCE.
GONXTBNK        CCS             SKEEP7
                TC              COMMFX
                CA              S+1
                TC              FXFX
                CA              SBIT7                           # HAS TO BE LARGER THAN NO OF FXSW BANKS.
                TC              COMMFX

SOPTION         CA              SKEEP4
                MASK            HI5                             # = BANK BITS
                TC              LEFT5
                TS              L                               # BANK NUMBER BEFORE SUPER BANK
## Page 1282
                CA              SKEEP4
                MASK            S8BITS                          # = SUPER BANK BITS
                EXTEND
                BZF             SOPT                            # BEFORE SUPER BANK
                TS              SR                              # SUPER BANK NECESSARY
                CA              L
                MASK            SEVEN
                AD              SR
                TS              L                               # BANK NUMBER WITH SUPER BANK
SOPT            CA              SKEEP6                          # *
                EXTEND                                          # *
                BZF             +2                              # * ON -0 CONTINUE WITH ROPE CHECK.
                TC              SDISPLAY                        # * ON +1 GO TO DISPLAY OF SUM.
                CCS             SKEEP1                          # FORCE SUM TO ABSOLUTE VALUE.
                TC              +2
                TC              +2
                AD              S+1
                TS              SKEEP1
BNKCHK          CS              L                               # = - BANK NUMBER
                AD              SKEEP1
                AD              S-1
                TC              -1CHK                           # CHECK SUM
                TC              NXTBNK

                EBANK=          NEWJOB
LSTBNKCH        BBCON*                                          # * CONSTANT, LAST BANK.
