### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    TRIM_GIMBAL_CONTROL_SYSTEM.agc
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
## Reference:   pp. 1460-1472
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-08-21 MAS  Created from Luminary 173.

## Page 1460
                BANK            21
                EBANK=          QDIFF
                SETLOC          DAPS4
                BANK

                COUNT*          $$/DAPGT

# CONTROL REACHES THIS POINT UNDER EITHER OF THE FOLLOWING TWO CONDITIONS ONCE THE DESCENT ENGINE AND THE DIGITAL
# AUTOPILOT ARE BOTH ON:
#          A) THE TRIM GIMBAL CONTROL LAW WAS ON DURING THE PREVIOUS Q,R-AXIS TIME5 INTERRUPT (OR THE DAPIDLER
#             INITIALIZATION WAS SET FOR TRIM GIMBAL CONTROL AND THIS IS THE FIRST PASS), OR
#          B) THE Q,R-AXES RCS AUTOPILOT DETERMINED THAT THE VEHICLE WAS ENTERING (OR HAD JUST ENTERED) A COAST
#             ZONE WITH A SMALL OFFSET ANGULAR ACCELERATION.

# GTS IS THE ENTRY TO THE GIMBAL TRIM SYSTEM FOR CONTROLLING ATTITUDE ERRORS AND RATES AS WELL AS ACCELERATIONS.

GTS             CAF             NEGONE                  # MAKE THE NEXT PASS THROUGH THE DAP BE
                TS              COTROLER                #   THROUGH RCS CONTROL,
                CAF             FOUR                    #   AND ENSURE THAT IT IS NOT A SKIP.
                TS              SKIPU
                TS              SKIPV

                CAF             TWO
                TS              INGTS                   # SET INDICATOR OF GTS CONTROL POSITIVE.
                TS              QGIMTIMR                # SET TIMERS TO 200 MSEC TO AVOID BOTH
                TS              RGIMTIMR                # RUNAWAY AND INTERFERENCE BY NULLING.

# THE DRIVE SETTING ALGORITHM

# DEL = SGN(OMEGA + ALPHA*ABS(ALPHA)/(2*K))

#                                             2               1/2                  2       3/2
# NEGUSUM = ERROR*K + ALPHA*(DEL*OMEGA + ALPHA /(3*K)) + DEL*K   (DEL*OMEGA + ALPHA /(2*K))

# DRIVE = -SGN(NEGUSUM)

                CA              SR                      # SAVE THE SR.  SHIFT IT LEFT TO CORRECT
                AD              A                       # FOR THE RIGHT SHIFT DUE TO EDITING.
                TS              SAVESR

GTSGO+DN        CAF             TWO                     # SET INDEXER FOR R-AXIS CALCULATIONS.
                TCF             GOQTRIMG        +1

GOQTRIMG        CAF             ZERO                    # SET INDEXER FOR Q-AXIS CALCULATIONS
                TS              QRCNTR

                INDEX           QRCNTR                  # AOS SCALED AT PI/2
                CA              AOSQ
                EXTEND
                MP              BIT2                    # RESCALE AOS TO PI/4

## Page 1461
                EXTEND
                BZF             GTSQAXIS        -3      # USE FULL SCALE FOR LARGER AOS ESTIMATES.

                INDEX           A
                CS              LIMITS                  # LIMITS +1 CONTAINS NEGMAX.
                XCH             L                       # LIMITS -1 CONTAINS POSMAX.

                CCS             QRCNTR                  # PICK UP RATE FOR THIS AXIS.  RATE CELLS
                INDEX           A                       # ARE ADJACENT, NOT SEPARATED.  AT PI/4
                CA              EDOTQ
GTSQAXIS        DXCH            WCENTRAL

                INDEX           QRCNTR                  # COLLECT K FOR THIS AXIS
                CA              KQ
                TS              KCENTRAL

                EXTEND                                  # CONTROL AUTHORITY  ZERO.  AVOID DRIVING
                BZF             POSDRIVE        +1      # ENGINE BELL TO THE STOPS.

                INDEX           QRCNTR                  # QDIFF, RDIFF ARE STORED IN D.P.
                CAE             QDIFF

ALGORTHM        EXTEND                                  # Q(R)DIFF IS THETA (ERROR) SCALED AT PI.
                MP              KCENTRAL                # FORM K*ERROR AT PI(2)/2(8), IN D.P.
                LXCH            K2THETA
                EXTEND
                MP              BIT5                    # RESCALE TO 4*PI(2)
                DXCH            K2THETA
                EXTEND
                MP              BIT5                    # FIRST TERM OF NEGUSUM IN K2THETA.
                ADS             K2THETA         +1      # NO CARRY NEEDED    D.P. AT 4*PI(2)

                CS              ACENTRAL                # FORM ALPHA(2)/(2*K) AT 16*PI, IN D.P.,
                EXTEND                                  # LIMITING QUOTIENT TO AVOID OVERFLOW.
                MP              BIT14                   # -ALPHA/2 IN A, SCALED AT PI/4
                EXTEND
                MP              ACENTRAL                # -ALPHA(2)/2 IN A,L, SCALED AT PI(2)/16
                AD              KCENTRAL
                EXTEND
                BZMF            HUGEQUOT                # K-ALPHA(2)/2 SHOULD BE PNZ FO DIVISION

                EXTEND
                DCS             A                       # ALPHA(2)/2 - K
                AD              KCENTRAL
                EXTEND
                DV              KCENTRAL                # HIGH ORDER OF QUOTIENT.
                XCH             A2CNTRAL
                CA              L                       # SHIFT UP THE REMAINDER.
                LXCH            7                       # ZERO LOW-ORDER DIVIDEND.
                EXTEND
## Page 1462
                DV              KCENTRAL
                XCH             A2CNTRAL        +1      # QUOTIENT STORED AT 16*PI, D.P.
                TCF             HAVEQUOT

HUGEQUOT        CA              POSMAX
                TS              L
                DXCH            A2CNTRAL                # LIMITED QUOTIENT STORED AT 16*PI, D.P.

HAVEQUOT        CA              WCENTRAL
                EXTEND
                MP              BIT9                    # RESCALE OMEGA AT 16*PI IN D.P.
                DXCH            K2CNTRAL                # LOWER WORD OVERLAYS OMEGA IN WCENTRAL

                EXTEND
                DCA             K2CNTRAL
                DXCH            FUNCTION

                CA              ACENTRAL                # GET ALPHA*ABS(ALPHA)/(2*K)
                EXTEND
                BZMF            +4

                EXTEND
                DCA             A2CNTRAL
                TCF             +3

                EXTEND
                DCS             A2CNTRAL

                DAS             FUNCTION                # OMEGA + ALPHA*ABS(ALPHA)/2*K) AT 16*PI

                CCS             FUNCTION                # DEL = +1 FOR FUNCT1 GREATER THAN ZERO.
                TCF             POSFNCT1                # OTHERWISE DEL = -1
                TCF             +2
                TCF             NEGFNCT1

                CCS             FUNCTION        +1      # USE LOW ORDER WORD SINCE HIGH IS ZERO
POSFNCT1        CAF             BIT1
                TCF             +2
NEGFNCT1        CS              BIT1
                TS              DEL

                CCS             DEL                     # REPLACE OMEGA BY DEL*OMEGA
                TCF             FUNCT2                  # POSITIVE DEL VALUE.  PROCEED.
                TCF             DEFUNCT
                TCF             NEGFNCT2

DEFUNCT         TS              K2CNTRAL
                TS              K2CNTRAL        +1
                TCF             FUNCT2

## Page 1463
NEG1/3          DEC             -.33333

NEGFNCT2        EXTEND
                DCS             K2CNTRAL
                DXCH            K2CNTRAL

FUNCT2          EXTEND
                DCA             A2CNTRAL
                DAS             K2CNTRAL                # DEL*OMEGA + ALPHA(2)/(2*K) AT 16*PI,D.P.

FUNCT3          CA              A2CNTRAL
                EXTEND
                MP              NEG1/3
                DXCH            A2CNTRAL
                CA              L
                EXTEND
                MP              NEG1/3
                ADS             A2CNTRAL        +1
                TS              L
                TCF             +2                      # A2CNTRAL NOW CONTAINS  -ALPHA(2)/(6*K),
                ADS             A2CNTRAL                # SCALED AT 16*PI, IN D.P.

                EXTEND
                DCA             K2CNTRAL                # DEL*OMEGA + ALPHA(2)/(3*K) IN A2CNTRAL,
                DAS             A2CNTRAL                # SCALED AT 16*PI, D.P.

                CA              A2CNTRAL
                EXTEND
                MP              ACENTRAL
                DAS             K2THETA
                CA              A2CNTRAL        +1
                EXTEND
                MP              ACENTRAL                # ACENTRAL MAY NOW BE OVERLAID.
                ADS             K2THETA         +1
                TS              L
                TCF             +2                      # TWO TERMS OF NEGUSUM ACCUMULATED, SO FAR
                ADS             K2THETA                 # SCALED AT 4*PI(2), IN D.P.

GETROOT         CA              K2CNTRAL                # K*(DEL*OMEGA + ALPHA(2)/(2*K)) IS THE
                EXTEND                                  # TERM FOR WHICH A SQUARE ROOT IS NEEDED.
                MP              KCENTRAL                # K AT PI/2(8)
                DXCH            FUNCTION
                CA              K2CNTRAL        +1
                EXTEND
                MP              KCENTRAL
                ADS             FUNCTION        +1
                TS              L
                TCF             +2
                ADS             FUNCTION                # DESIRED TERM IN FUNCTION, AT PI(2)/16
## Page 1464
                CCS             DEL
                TCF             RSTOFGTS
                TCF             NEGUSUM
                TCF             NEGATE
                TCF             NEGUSUM

NEGATE          EXTEND
                DCS             K2CNTRAL
                DXCH            K2CNTRAL
                TCF             RSTOFGTS

                BANK            16
                EBANK=          NEGUQ
                SETLOC          DAPS1
                BANK

# THE WRCHN12 SUBROUTINE SETS BITS 9,10,11,12 OF CHANNEL 12 ON THE BASIS OF THE CONTENTS OF NEGUQ,NEGUR WHICH ARE
# THE NEGATIVES OF THE DESIRED ACCELERATION CHANGES.  ACDT+C12 SETS Q(R)ACCDOT TO REFLECT THE NEW DRIVES.

# WARNING:  ACDT+C12 AND WRCHN12 MUST BE CALLED WITH INTERRUPT INHIBITED.

BGIM            OCTAL           07400
CHNL12          EQUALS          ITEMP6
ACDT+C12        CS              NEGUQ
                EXTEND                                  # GIMBAL DRIVE REQUESTS.
                MP              ACCDOTQ
                LXCH            QACCDOT
                CS              NEGUR
                EXTEND
                MP              ACCDOTR
                LXCH            RACCDOT

                CCS             NEGUQ
                CAF             BIT10
                TCF             +2
                CAF             BIT9
                TS              CHNL12

                CCS             NEGUR
                CAF             BIT12
                TCF             +2
                CAF             BIT11
                ADS             CHNL12                  # (STORED RESULT NOT USED AT PRESENT)

                CS              BGIM
                EXTEND
                RAND            CHAN12
                AD              CHNL12
                EXTEND
                WRITE           CHAN12

## Page 1465
                CS              CALLGMBL                # TURN OFF REQUEST FOR ACDT+C12 EXECUTION.
                MASK            RCSFLAGS
                TS              RCSFLAGS

                TC              Q                       # RETURN TO CALLER.

                BANK            21
                EBANK=          QDIFF
                SETLOC          DAPS4
                BANK

## Page 1466
# SUBROUTINE TIMEGMBL:  MOD 0,  OCTOBER 1967, CRAIG WORK

# TIMEGMBL COMPUTES THE DRIVE TIME NEEDED FOR THE TRIM GIMBAL TO POSITION THE DESCENT ENGINE NOZZLE SO AS TO NULL
# THE OFFSET ANGULAR ACCELERATION ABOUT THE Q (OR R) AXIS.  INSTEAD OF USING AOSQ(R), TIMEGMBL USES .4*AOSQ(R),
# SCALED AT PI/8.                         FOR EACH AXIS, THE DRIVE TIME IS COMPUTED AS ABS(ALPHA/ACCDOT).  A ZERO
# ALPHA OR ACCDOT OR A ZERO QUOTIENT TURNS OFF THE GIMBAL DRIVE IMMEDIATELY.  OTHERWISE, THE GIMBAL IS TURNED ON
# DRIVING IN THE CORRECT DIRECTION. THE Q(R)GIMTIMR IS SET TO TERMINATE THE DRIVE AND Q(R)ACCDOT
# IS STORED TO REFLECT THE NEW ACCELERATION DERIVATIVE.  NEGUQ(R) WILL CONTAIN +1,+0,-1 FOR A Q(R)ACCDOT VALUE
# WHICH IS NEGATIVE, ZERO, OR POSITIVE.

# INPUTS:  AOSQ,AOSR, SCALED AT P1/2, AND ACCDOTQ, ACCDOTR AT PI/2(7).    PI/2(7).

# OUTPUTS:   NEW GIMBAL DRIVE BITS IN CHANNEL 12,NEGUQ,NEGUR,QACCDOT AND RACCDOT, THE LAST SCALED AT PI/2(7).
#            Q(R)GIMTIMR WILL BE SET TO TIME AND TERMINATE GIMBAL DRIVE(S)

# DEBRIS:  A,L,Q, ITEMPS 2,3,6, RUPTREG2 AND ACDT+C12 DEBRIS.

# EXITS:  VIA TC Q.

# ALARMS, ABORTS, :  NONE

# SUBROUTINES:  ACDT+C12, IBNKCALL

# WARNING:  THIS SUBROUTINE WRITES INTO CHANNEL 12 AND USES THE ITEMPS.  THEREFORE IT MAY ONLY BE CALLED WITH
# INTERRUPT INHIBITED.

# ERASABLE STORAGE CONFIGURATION (NEEDED BY THE INDEXING METHODS):

#                                         NEGUQ    ERASE    +2            NEGATIVE OF Q-AXIS GIMBAL DRIVE
#                                         (SPWORD) EQUALS  NEGUQ +1       ANY S.P. ERASABLE NUMBER, NOW THRSTCMD
#                                         NEGUR    EQUALS  NEGUQ +2       NEGATIVE OF R-AXIS GIMBAL DRIVE

#                                         ACCDOTQ  ERASE    +2            Q-JERK TERM SCALED AT PI/2(7) RAD/SEC(3)
#                                         (SPWORD) EQUALS  ACCDOTQ +1     ANY S.P. ERASABLE NUMBER  NOW QACCDOT
#                                         ACCDOTR  EQUALS  ACCDOTQ +2     R-JERK TERM SCALED AT PI/2(7) RAD/SEC(3)
#                                                                         ACCDOTQ,ACCDOTR ARE MAGNITUDES.
#                                         AOSQ     ERASE   +4             Q-AXIS ACC.,D.P. AT PI/2 R/SEC(2)
#                                         AOSR     EQUALS  AOSQ +2        R-AXIS ACCELERATION SCALED AT PI/2 R/S2

QRNDXER         EQUALS          ITEMP6
OCT23146        OCTAL           23146                   # DECIMAL .6
NZACCDOT        EQUALS          ITEMP3

TIMEGMBL        CAF             ONE                     # INITIALIZE ALLOWGTS.
                TS              ALLOWGTS

                CAF             TWO                     # SET UP LOOP FOR R AXIS.
                LXCH            Q                       # SAVE RETURN ADDRESS.
                LXCH            RUPTREG2
## Page 1467
                TCF             +2
TIMQGMBL        CAF             ZERO                    # NOW DO THE Q-AXIS
                TS              QRNDXER
                INDEX           QRNDXER
                CA              ACCDOTQ                 # ACCDOT IS PRESUMED TO BE AT PI/2(7).
                EXTEND
                BZMF            TGOFFNOW                # IS ACCDOT LESS THAN OR EQUAL TO 0?
                TS              NZACCDOT                # NO.  STORE NON-ZERO, POSITIVE ACCDOT.

ALPHATRY        INDEX           QRNDXER
                CS              AOSQ
                EXTEND
                BZF             TGOFFNOW                # IS ALPHA ZERO?

                TS              Q                       # SAVE A COPY OF  -AOS.
                EXTEND                                  # NO.  RESCALE FOR TIMEGMBL USE.
                MP              OCT23146                # OCTAL 23146 IS DECIMAL .6
                AD              Q                       # -1.6*AOS AT PI/2 = -.4*AOS AT PI/8.
                TS              L                       # WAS THERE OVERFLOW?
                TCF             SETNEGU                 # NO.  COMPUTE DRIVE TIME.

                CS              A                       # RECOVER  -SGN(AOS) IN THE A REGISTER.
                INDEX           QRNDXER                 # YES.  START DRIVE WITHOUT WAITLIST.
                XCH             NEGUQ
                TCF             NOTALLOW                # KNOCK DOWN THE ALLOWGTS FLAG.

SETNEGU         EXTEND
                BZMF            POSALPH

                COM
                TS              ITEMP2                  # STORE  -ABS(.4*AOS) SCALED AT PI/8.
                CS              BIT1
                TCF             POSALPH         +2
POSALPH         TS              ITEMP2                  # STORE  -ABS(.4*AOS) SCALED AT PI/8.
                CA              BIT1
 +2             INDEX           QRNDXER                 # SGN(AOS) INTO NEGU
                TS              NEGUQ                   # STORE SGN(APLHA) AS NEGU

                CA              NZACCDOT
                EXTEND
                MP              BIT12                   # 2*ACCDOT, SCALED AT PI/8.
                AD              ITEMP2                  # -ABS(ALPHA) + 2*ACCDOT, AT PI/8.
                EXTEND
                BZMF            NOTALLOW                # IS DRIVE TIME MORE THAN TWO SECONDS?
                CS              ITEMP2                  # NO.  COMPUTE DRIVE TIME.
                EXTEND                                  # ABS(ALPHA) AT PI/8.
                MP              OCT00240                # DECIMAL 10/1024
                EXTEND                                  # QUOTIENT IS DRIVE TIME AT WAITLIST.
                DV              NZACCDOT                # ABS(ALPHA)/ACCDOT AT 2(14)/100

## Page 1468
                EXTEND
                BZF             TGOFFNOW                # DRIVE TIME MUST BE GREATER THAN ZERO.

                TCF             DRIVEON

TGOFFNOW        CAF             ZERO                    # TURN OFF GIMBAL NOW.
                INDEX           QRNDXER
                TS              NEGUQ

                TCF             DONEYET

NOTALLOW        CAF             OCT31
                INDEX           QRNDXER
                TS              QGIMTIMR
                CAF             ZERO                    # DRIVE TIME IS MORE THAN 2 SECONDS, SO
                TS              ALLOWGTS                # DO NOT PERMIT FURTHER GTS ATTITUDE-RATE
                                                        # CONTROL UNTIL AOSTASK APPROVES.
                TCF             DONEYET                 # NO WAITLIST CALL IS MADE.

DRIVEON         INDEX           QRNDXER
                TS              QGIMTIMR                # CHOOSE Q OR R AXIS.

DONEYET         CCS             QRNDXER
                TCF             TIMQGMBL

                DXCH            RUPTREG3                # PROTECT IBNKCALL ERASABLES.  ACDT+C12
                DXCH            ITEMP2                  # LEAVES ITEMPS2,3 ALONE.

                TC              IBNKCALL                # TURN OF CHANNEL BITS, SET Q(R)ACCDOTS.
                CADR            ACDT+C12

                DXCH            ITEMP2                  # RESTORE ERASABLES FOR IBNKCALL.
                DXCH            RUPTREG3

                TC              RUPTREG2                # RETURN TO CALLER.

OCT00240        OCTAL           00240                   # DECIMAL 10/1024

## Page 1469
# THE FOLLOWING SECTION IS A CONTINUATION OF THE TRIM GIMBAL CONTROL FROM THE LAST GTS ENTRY. THE QUANTITY NEGUSUM
# IS COMPUTED FOR EACH AXIS (Q,R), .707*DEL*FUNCTION(3/2) + K2THETA = NEGUSUM.  NEW DRIVES ARE ENTERED TO CH 12.

# THE SUBROUTINE GTSQRT ACCEPTS A DOUBLE PRECISION VALUE IN FUNCTION, FUNCTION +1 AND RETURNS A SINGLE-PRECISION
# SQUARE ROOT OF THE FOURTEEN MOST SIGNIFICANT BITS OF THE ARGUMENT.  ALSO, THE CELL SHFTFLAG CONTAINS A BINARY
# EXPONENT S, SUCH THAT THE SQUARE ROOT (RETURNED IN THE A REGISTER) MUST BE SHIFTED RIGHT (MULTIPLIED BY 2 TO THE
# POWER (-S)) IN ORDER TO BE THE TRUE SQUARE ROOT OF THE FOURTEEN MOST SIGNIFICANT BITS OF FUNCTION, FUNCTION +1.
# SQUARE ROOT ERROR IS NOT MORE THAN 2 IN THE 14TH SIGNIFICANT BIT.  CELLS CLOBBERED ARE A,L,SHFTFLAG,ININDEX,
# HALFARG,SCRATCH,SR,FUNCTION, FUNCTION +1.  GTSQRT IS CALLED BY TC GTSQRT AND RETURNS VIA TC Q OR TC FUNCTION +1.
# ZERO OR NEGATIVE ARGUMENTS YIELD ZERO FOR SQUARE ROOTS.

GTSQRT          CCS             FUNCTION
                TCF             GOODARG                 # FUNCTION IS POSITIVE.  TAKE SQUARE ROOT.
                TCF             +2                      # HIGH ORDER WORD IS ZERO.  TRY THE LOWER.
                TCF             ZEROOT                  # NEGATIVE.  USE ZERO FOR 1/2 POWER.

                CA              FUNCTION        +1
                EXTEND
                BZMF            ZEROOT

                TCF             ZEROHIGH                # PROCEED.
ZEROOT          CA              ZERO
                TS              SHFTFLAG
                TC              Q

ZEROHIGH        XCH             FUNCTION                # 14 MOST SIGNIFICANT BITS ARE IN THE
                XCH             FUNCTION        +1      # LOWER WORD.  EXCHANGE THEM.
                CA              SEVEN
                TCF             GOODARG         +1

GOODARG         CA              ZERO
                TS              SHFTFLAG
                CA              TWELVE                  # INITIALIZE THE SCALING LOOP.
                TS              ININDEX
                TCF             SCALLOOP

SCALSTRT        CA              FUNCTION
                TCF             SCALDONE

MULBUSH         CA              NEG2                    # IF ARG IS NOT LESS THAN 1/4, INDEX IS
                ADS             ININDEX                 # ZERO, INDICATING NO SHIFT NEEDED.
                EXTEND                                  # BRANCH IF ARG IS NOT LESS THAN 1/4.
                BZMF            SCALSTRT                # OTHERWISE COMPARE ARG WITH A REFERENCE
                                                        # WHICH IS 4 TIMES LARGER THAN THE LAST.
SCALLOOP        CS              FUNCTION
                INDEX           ININDEX
                AD              BIT15                   # REFERENCE MAGNITUDE LESS OR EQUAL TO 1/4
                EXTEND
                BZMF            MULBUSH                 # IF ARG IS NOT LESS THAN REFERENCE, GO
                                                        # AROUND THE MULBERRY BUSH ONCE MORE.

## Page 1470
                INDEX           ININDEX
                CA              BIT15                   # THIS IS THE SCALE MAGNITUDE
                XCH             HALFARG                 # 2**(-ININDEX) IS THE SHIFT DIVISOR.
                EXTEND                                  # RESCALE ARGUMENT.
                DCA             FUNCTION
                EXTEND
                DV              HALFARG
                                                        # ININDEX AND SHFTFLAG PRESERVE INFO FOR

                                                        # RESCALING AFTER ROOT PROCESS.
SCALDONE        EXTEND
                QXCH            FUNCTION        +1      # SAVE Q FOR RETURN
                EXTEND
                MP              BIT14
                TS              HALFARG
                MASK            BIT13
                CCS             A
                CA              OCT11276
                AD              ROOTHALF                # INITIAL GUESS IS ROOT 1/2 OR POSMAX

                TC              ROOTCYCL
                TC              ROOTCYCL
                TC              ROOTCYCL

                TC              FUNCTION        +1

# ****************************************************************************************************************


RSTOFGTS        TC              GTSQRT
PRODUCT         XCH             K2CNTRAL
                EXTEND
                MP              K2CNTRAL
                DXCH            K2CNTRAL
                EXTEND                                  #             THE PRODUCT OF
                MP              L                       #  1/2                   2       1/2
                ADS             K2CNTRAL        +1      # K   *(DEL*OMEGA + ALPHA /(2*K))
                TS              L                       #                 AND
                TCF             +2                      #                        2
                ADS             K2CNTRAL                #  DEL*(DEL*OMEGA + ALPHA /(2*K)) NOW IN
                                                        # K2CNTRAL

DOSHIFT         CA              ININDEX
                EXTEND                                  # MULTIPLY IN THE FACTOR 2(-S), RETURNED
                MP              BIT14                   # BY THE GTSQRT SUBROUTINE
                ADS             SHFTFLAG
                EXTEND
                BZF             ADDITIN
                INDEX           SHFTFLAG
                CA              BIT15
## Page 1471
                XCH             K2CNTRAL
                EXTEND
                MP              K2CNTRAL
                DAS             K2THETA
                XCH             K2CNTRAL
                EXTEND
                MP              K2CNTRAL        +1
                ADS             K2THETA         +1
                TS              L
                TCF             +2
                ADS             K2THETA

                TCF             NEGUSUM

ADDITIN         EXTEND
                DCA             K2CNTRAL
                DAS             K2THETA                 # NOW ADD IN THE K2THETA TERM.
NEGUSUM         CCS             K2THETA                 # TEST SIGN OF HIGH ORDER PART.
                TCF             NEGDRIVE
                TCF             +2
                TCF             POSDRIVE

                CCS             K2THETA         +1      # SIGN TEST FOR LOW ORDER PART.
NEGDRIVE        CA              BIT1
                TCF             +2                      # STOP GIMBAL DRIVE FOR A ZERO NEGUSUM.
POSDRIVE        CS              BIT1
                TS              L                       # SAVE FOR DRIVE REVERSAL TEST.
                INDEX           QRCNTR
                XCH             NEGUQ

                EXTEND
                MP              L                       # MULTIPLY OLD NEGU AND NEW NEGU.
                CCS             L
                TCF             LOUPE                   # NON-ZERO GIMBAL DRIVE BEING CONTINUED.

                TCF             ZEROLOUP                # NO REVERSAL PROBLEM HERE.

                TCF             REVERSAL                # NON-ZERO GIMBAL DRIVE BEING REVERSED.
                TCF             ZEROLOUP                # NO REVERSAL PROBLEM HERE.

REVERSAL        INDEX           QRCNTR                  # A ZERO-DRIVE PAUSE IS NEEDED HERE.  ZERO
                TS              QACCDOT                 # IS IN A REGISTER FROM CCS ON (-1).
                INDEX           QRCNTR
                CS              GMBLBITA
                EXTEND
                WAND            CHAN12

ZEROLOUP        CS              RCSFLAGS                # SET UP REQUEST FOR ACDT+C12 CALL.
                MASK            CALLGMBL
                ADS             RCSFLAGS

## Page 1472
LOUPE           CCS             QRCNTR                  # HAVE BOTH AXES BEEN PROCESSED?
                TCF             GOQTRIMG                # NO.  DO Q AXIS NEXT.

                CA              SAVESR                  # RESTORE THE SR
                TS              SR

GOCLOSE         EXTEND                                  # TERMINATE THE JASK.
                DCA             CLOSEADR
                DTCB

                EBANK=          AOSQ
CLOSEADR        2CADR           CLOSEOUT                # TERMINATE THE JASK.

TWELVE          EQUALS          OCT14
ROOTHALF        OCTAL           26501                   # SQUARE ROOT OF 1/2
GMBLBITA        OCTAL           01400                   # INDEXED WRT GMBLBITB   DO NOT MOVE******
OCT11276        OCTAL           11276                   # POSMAX - ROOTHALF
GMBLBITB        OCTAL           06000                   # INDEXED WRT GMBLBITA   DO NOT MOVE******

# SUBROUTINE ROOTCYCL:  BY CRAIG WORK,3 APRIL 68
# ROOTCYCL IS A SUBROUTINE WHICH EXECUTES ONE NEWTON SQUARE ROOT ALGORITHM ITERATION.  THE INITIAL GUESS AT THE
# SQUARE ROOT IS PRESUMED TO BE IN THE A REGISTER AND ONE-HALF THE SQUARE IS TAKEN FROM HALFARG.  THE NEW APPROXI-
# MATION TO THE SQUARE ROOT IS RETURNED IN THE A REGISTER.  DEBRIS:   A,L,SR,SCRATCH.  ROOTCYCL IS CALLED FROM
# LOCATION (LOC) BY A TC ROOTCYCL, AND RETURNS (TC Q) TO LOC +1.

# WARNING:  IF THE INITIAL GUESS IS NOT GREATER THAN THE SQUARE, DIVIDE OR ADD OVERFLOW IS A REAL POSSIBILITY.

ROOTCYCL        TS              SCRATCH                 # STORE X
                TS              SR                      # X/2 NOW IN SR
                CA              HALFARG                 # ARG/2 IN THE A REG
                ZL                                      # PREPARE FOR DIVISION
                EXTEND
                DV              SCRATCH                 # (ARG/X)/2
                AD              SR                      # (X + ARG/X)/2 IN THE A REG
                TC              Q
