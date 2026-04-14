**
** VIDEOCLUB.PRG
** Scaled Video Club — Stage 1: Clipper 5.2
** Rental Management System
**
** Compile:  clipper VIDEOCLUB /N /W
** Link:     blinker FILE VIDEOCLUB LIB clipper
**           (or: rtlink FILE VIDEOCLUB LIB clipper)
**
** File scope: Flow 0 — MAIN, logo, menu loop.
** All rental flows are stubs pending next sessions.
**

* ═══════════════════════════════════════════════════════════════════════
* Preprocessor constants
* ═══════════════════════════════════════════════════════════════════════

* Double-line box string for @ r1,c1,r2,c2 BOX command
* Order: UL, TOP, UR, RIGHT, LR, BOTTOM, LL, LEFT
#define DBLBOX  CHR(201)+CHR(205)+CHR(187)+CHR(186)+CHR(188)+CHR(205)+CHR(200)+CHR(186)

* Single horizontal rule character for internal separators
#define HRULE   CHR(196)

#define APP_TITLE  " SCALED VIDEO CLUB  //  Rental Management System "
#define DATA_PATH  "DATA\"
#define CFG_FILE   "VIDEOCLUB.CFG"

* ═══════════════════════════════════════════════════════════════════════
* Global configuration variables
* PUBLIC — visible to every procedure without parameter passing.
* Initialized to hardcoded defaults here; LoadConfig() may override them.
* ═══════════════════════════════════════════════════════════════════════

* moved to Procedure InitGlobals sue to error  
*       Error C2006 Statement not allowed outside procedure...

* ═══════════════════════════════════════════════════════════════════════
* MAIN
* Entry point. Initializes environment, opens files, shows logo,
* enters menu loop. On exit, closes all files and quits.
* ═══════════════════════════════════════════════════════════════════════

PROCEDURE MAIN

   ? "PUNTO 1"

   SET TALK       OFF
   SET SCOREBOARD OFF
   SET BELL       OFF
   SET DELETED    ON
   SET DATE       BRITISH
   SET CENTURY    OFF
   SET CONFIRM    OFF
   SET WRAP       OFF

   PUBLIC nRentalDays, nDailyRate, nLateFeeDaily, nMaxRentals

   CLEARSCREEN()

   InitGlobals()
   LoadConfig()
   OpenFiles()
   ShowLogo()
   MenuLoop()

   CLOSE ALL
   CLEARSCREEN()
   @ 12, 35 SAY "Goodbye."
   @ 14,  0 SAY ""

   QUIT

RETURN


* ───────────────────────────────────────────────────────────────────────
* LoadConfig
*
* Reads VIDEOCLUB.CFG into global variables.
* Format: one KEY=VALUE per line. Lines starting with * are comments.
* Unknown keys are silently ignored.
* Missing file: globals keep their defaults; warning shown on row 22.
* ───────────────────────────────────────────────────────────────────────

PROCEDURE LoadConfig()

   LOCAL cContent
   LOCAL cLine
   LOCAL cKey
   LOCAL cVal
   LOCAL nPos
   LOCAL nLines
   LOCAL i

   IF FILE(CFG_FILE)
      cContent := MEMOREAD(CFG_FILE)
      nLines   := MLCOUNT(cContent, 254)

      FOR i := 1 TO nLines
         cLine := ALLTRIM(MEMOLINE(cContent, 254, i))

         * Skip blank lines and comment lines (lines starting with *)
         IF LEN(cLine) > 0 .AND. LEFT(cLine, 1) <> "*"
            nPos := AT("=", cLine)
            IF nPos > 0
               cKey := ALLTRIM(UPPER(LEFT(cLine, nPos - 1)))
               cVal := ALLTRIM(SUBSTR(cLine, nPos + 1))

               DO CASE
               CASE cKey == "RENTAL_DAYS"
                  nRentalDays   := VAL(cVal)
               CASE cKey == "DAILY_RATE"
                  nDailyRate    := VAL(cVal)
               CASE cKey == "LATE_FEE_DAILY"
                  nLateFeeDaily := VAL(cVal)
               CASE cKey == "MAX_RENTALS"
                  nMaxRentals   := VAL(cVal)
               ENDCASE
            ENDIF
         ENDIF
      NEXT
   ELSE
      @ 22, 1 SAY "Config file not found. Using defaults."
      INKEY(2)
   ENDIF

RETURN

* ───────────────────────────────────────────────────────────────────────
* InitGlobals
*
* Initialize global PUBLIC variables
* ───────────────────────────────────────────────────────────────────────

PROCEDURE InitGlobals
   nRentalDays   = 3
   nDailyRate    = 2.00
   nLateFeeDaily = 1.00
   nMaxRentals   = 3
RETURN


* ───────────────────────────────────────────────────────────────────────
* OpenFiles
*
* Opens MOVIES.DBF (work area 1) and CUSTOMERS.DBF (work area 2)
* with their NTX indexes.
* Fatal error and immediate exit if any required file is missing.
* ───────────────────────────────────────────────────────────────────────

PROCEDURE OpenFiles()

   * ── Work area 1: MOVIES ─────────────────────────────────────────────

   SELECT 1

   IF .NOT. FILE(DATA_PATH + "MOVIES.DBF")
      @ 22, 1 SAY "[FATAL] Data file not found: MOVIES.DBF. Exiting."
      INKEY(0)
      QUIT
   ENDIF

   IF .NOT. FILE(DATA_PATH + "MOVIES.NTX")
      @ 22, 1 SAY "[FATAL] Index not found: MOVIES.NTX. Exiting."
      INKEY(0)
      QUIT
   ENDIF

   USE (DATA_PATH + "MOVIES") INDEX (DATA_PATH + "MOVIES") ALIAS MOVIES

   * ── Work area 2: CUSTOMERS ──────────────────────────────────────────

   SELECT 2

   IF .NOT. FILE(DATA_PATH + "CUSTOMERS.DBF")
      @ 22, 1 SAY "[FATAL] Data file not found: CUSTOMERS.DBF. Exiting."
      INKEY(0)
      QUIT
   ENDIF

   IF .NOT. FILE(DATA_PATH + "CUSTOMERS.NTX")
      @ 22, 1 SAY "[FATAL] Index not found: CUSTOMERS.NTX. Exiting."
      INKEY(0)
      QUIT
   ENDIF

   USE (DATA_PATH + "CUSTOMERS") INDEX (DATA_PATH + "CUSTOMERS") ALIAS CUSTOMERS

RETURN


* ───────────────────────────────────────────────────────────────────────
* ShowLogo
*
* Draws the startup screen with ASCII logo and active config summary.
* Waits for a keypress, then hands off to MenuLoop.
* ───────────────────────────────────────────────────────────────────────

PROCEDURE ShowLogo()

   CLEARSCREEN()

   * Row 0: application title bar (full width)
   @ 0, 0 SAY PADC(APP_TITLE, 80)

   * Rows 2-10: ASCII logo
   @ 2, 14 SAY " ____   ___    __   __     ____   ____  "
   @ 3, 14 SAY "(  __) / __)  / _\ (  )   (  __) (    \"
   @ 4, 14 SAY " \ \  ( (__  /    \ )( _   ) _)   ) D  ) "
   @ 5, 14 SAY "(____) \___) \_/\_/(____) (____) (____/ "
   @ 6, 14 SAY ""
   @ 7, 14 SAY " _  _  __  ____  ____  __      ___   _     _   _   ___  "
   @ 8, 14 SAY "( \/ )(  )(    \(  __)/  \    / __) ( )   ( ) ( ) (  _)"
   @ 9, 14 SAY " \  /  )(  ) D ( ) _)(  O )  ( (__ )( )_  ( )_( ) (  _\'"
   @10, 14 SAY "  \/  (__)(____/(____) \__/   \___) (___) (____)  (____)"

   * Separator
   @ 12, 2 SAY REPLICATE(HRULE, 76)

   * Config summary — operator can confirm loaded settings at a glance
   @ 13, 4 SAY "Date: " + DTOC(DATE())
   @ 14, 4 SAY "Rental period: " + LTRIM(STR(nRentalDays)) + " days"
   @ 15, 4 SAY "Rate: $" + LTRIM(STR(nDailyRate, 6, 2)) + "/day"
   @ 16, 4 SAY "Late: $" + LTRIM(STR(nLateFeeDaily, 6, 2)) + "/day"
   @ 17, 4 SAY "Max rentals per customer: " + LTRIM(STR(nMaxRentals))

   @ 22, 25 SAY "Press any key to continue..."

   INKEY(0)

RETURN


* ───────────────────────────────────────────────────────────────────────
* DrawMenu
*
* Renders the main menu screen. Called at the start of each
* MenuLoop iteration so the screen is always clean on return.
* ───────────────────────────────────────────────────────────────────────

PROCEDURE DrawMenu()

   CLEARSCREEN()

   * Title bar
   @ 0, 0 SAY PADC(APP_TITLE, 80)

   * Menu box
   @ 3, 2, 18, 34 BOX DBLBOX

   @  4,  4 SAY "  R.  Rent a movie"
   @  5,  4 SAY "  D.  Return a movie"
   @  6,  3 SAY REPLICATE(HRULE, 30)
   @  7,  4 SAY "  C.  New customer"
   @  8,  4 SAY "  L.  Customer list"
   @  9,  3 SAY REPLICATE(HRULE, 30)
   @ 10,  4 SAY "  M.  Available movies"
   @ 11,  4 SAY "  N.  New movie"
   @ 12,  3 SAY REPLICATE(HRULE, 30)
   @ 14,  4 SAY "  X.  Exit"

   @ 24,  1 SAY "[Key] Select option"

RETURN


* ───────────────────────────────────────────────────────────────────────
* MenuLoop
*
* Main dispatch loop. Draws the menu, reads a single keypress,
* calls the matching procedure. Exits only on X.
* ───────────────────────────────────────────────────────────────────────

PROCEDURE MenuLoop()

   LOCAL cKey
   LOCAL lExit

   lExit := .F.

   DO WHILE .NOT. lExit

      DrawMenu()
      cKey := UPPER(CHR(INKEY(0)))

      DO CASE
      CASE cKey == "R"
         RentMovie()
      CASE cKey == "D"
         ReturnMovie()
      CASE cKey == "C"
         NewCustomer()
      CASE cKey == "L"
         CustomerList()
      CASE cKey == "M"
         AvailableMovies()
      CASE cKey == "N"
         NewMovie()
      CASE cKey == "X"
         lExit := .T.
      ENDCASE

   ENDDO

RETURN


* ═══════════════════════════════════════════════════════════════════════
* FLOW STUBS
* Placeholder procedures for flows not yet implemented.
* Each displays a [STUB] notice and waits for a keypress.
* Replace body-by-body in subsequent sessions.
* ═══════════════════════════════════════════════════════════════════════

PROCEDURE RentMovie()
   @ 22, 1 SAY "[STUB] RentMovie - not yet implemented. Press any key."
   INKEY(0)
RETURN

PROCEDURE ReturnMovie()
   @ 22, 1 SAY "[STUB] ReturnMovie - not yet implemented. Press any key."
   INKEY(0)
RETURN

PROCEDURE NewCustomer()
   @ 22, 1 SAY "[STUB] NewCustomer - not yet implemented. Press any key."
   INKEY(0)
RETURN

PROCEDURE CustomerList()
   @ 22, 1 SAY "[STUB] CustomerList - not yet implemented. Press any key."
   INKEY(0)
RETURN

PROCEDURE AvailableMovies()
   @ 22, 1 SAY "[STUB] AvailableMovies - not yet implemented. Press any key."
   INKEY(0)
RETURN

PROCEDURE NewMovie()
   @ 22, 1 SAY "[STUB] NewMovie - not yet implemented. Press any key."
   INKEY(0)
RETURN

PROCEDURE CLEARSCREEN()
   LOCAL i 
   FOR i := 0 TO 24
      @ i,0 SAY SPACE(80)
   NEXT

   SETPOS(0,0)
RETURN 