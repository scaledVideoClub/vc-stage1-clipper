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
#define CFG_FILE   "VCLUB.CFG"

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

   SET TALK       OFF
   SET SCOREBOARD OFF
   SET BELL       OFF
   SET DELETED    ON
   SET DATE       BRITISH
   SET CENTURY    OFF
   SET CONFIRM    OFF
   SET WRAP       OFF

   PUBLIC nRentalDaysDays, nDailyRate, nLateFeeDaily,nMaxRentals

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
                  M->nRentalDays   := VAL(cVal)
               CASE cKey == "DAILY_RATE"
                  M->nDailyRate    := VAL(cVal)
               CASE cKey == "LATE_FEE_DAILY"
                  M->nLateFeeDaily := VAL(cVal)
               CASE cKey == "MAX_RENTALS"
                  M->nMaxRentals   := VAL(cVal)
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
   M->nRentalDays   = 3
   M->nDailyRate    = 2.00
   M->nLateFeeDaily = 1.00
   M->nMaxRentals   = 3
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
   @ 14, 4 SAY "Rental period: " + LTRIM(STR(M->nRentalDays)) + " days"
   @ 15, 4 SAY "Rate: $" + LTRIM(STR(M->nDailyRate, 6, 2)) + "/day"
   @ 16, 4 SAY "Late: $" + LTRIM(STR(M->nLateFeeDaily, 6, 2)) + "/day"
   @ 17, 4 SAY "Max rentals per customer: " + LTRIM(STR(M->nMaxRentals))

   @ 22, 25 SAY "Press any key to continue..."

   INKEY(0)

RETURN


* ───────────────────────────────────────────────────────────────────────
* Flow 0 : DrawMenu
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
         CLOSE ALL
         lExit := .T.
      ENDCASE

   ENDDO

RETURN




* ───────────────────────────────────────────────────────────────────────
* ### Flow 2 — Rent a movie
*   The operator:
*   1. Enters the catalog ID of the movie (read from the physical cassette's label)
*  2. Enters the customer ID
*  3. The system verifies the movie is available (stock = 1 unit, currently in)
*  4. The system records the rental: movie, customer, start date, due date
*  5. The movie is marked as rented (unavailable)
* ───────────────────────────────────────────────────────────────────────

PROCEDURE RentMovie()

    LOCAL nMovieID
    LOCAL nClientID
    LOCAL GETLIST
    LOCAL cMovieName
    LOCAL cClientName
    LOCAL nArea 
    
    GETLIST := {}
    nArea := SELECT()

   CLEARSCREEN()
   @ 0, 0 SAY PADC(APP_TITLE, 80)
   @ 3, 2, 10, 60 BOX DBLBOX
   @ 4, 4 SAY "RENT A MOVIE"
   @ 5, 3 SAY REPLICATE(HRULE, 57)
   @ 7, 4 SAY "Client ID: "
   @ 24, 1 SAY "[Enter] Confirm   [Esc] Cancel"

   M->nCLientID := SPACE(3)
   @ 7, 11 GET M->nCLientID PICT "@999"
   READ

   * LASTKEY() == 27 user pressed Esc while GET
   IF LASTKEY() == 27
      SELECT (nArea)
      RETURN
   ENDIF

   IF LEN(M->nCLientID) = 0
      @ 22, 1 SAY "This field cannot be empty. Press any key."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   M->nCLientID  = VAL(M->nCLientID)
   SELECT CUSTOMERS
   SEEK M->nCLientID

   IF !FOUND()
      @ 22, 1 SAY "Customer doesn't exists. Press any key."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   M->cClientName := CUSTOMERS->Name 
   
   * validate max rentals
   IF SeekRentalsFrom(M->nCLientID) >= M->nMaxRentals
      @ 22, 1 SAY "Customer already has " + LTRIM(STR(M->nMaxRentals)) + " rentals. Cannot rent more."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF   

   * find movie
   CLEARSCREEN()
   GETLIST := {}

   @ 0, 0 SAY PADC(APP_TITLE, 80)
   @ 3, 2, 10, 60 BOX DBLBOX
   @ 4, 4 SAY "RENT A MOVIE"
   @ 5, 3 SAY REPLICATE(HRULE, 57)
   @ 7, 4 SAY "Movie ID: "
   @ 24, 1 SAY "[Enter] Confirm   [Esc] Cancel"

   @ 22, 1 SAY "Renting to customer: " + STR(M->nCLientID) + ": " + M->cClientName +"."

   M->nMovieID := SPACE(3)
   @ 7, 14 GET M->nMovieID PICT "@999"
   READ

   * LASTKEY() == 27 user pressed Esc while GET
   IF LASTKEY() == 27
      SELECT (nArea)
      RETURN
   ENDIF

   IF LEN(M->nMovieID) = 0
      @ 22, 1 SAY "This field cannot be empty. Press any key."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   @ 23, 1 SAY "Movie ID entered: " + M->nMovieID + " - Press any key to continue..."
   INKEY(0)

   M->nMovieID  = VAL(M->nMovieID)

   SELECT MOVIES
   GO TOP
   SEEK M->nMovieID

   IF !FOUND()
      @ 22, 1 SAY "Movie doesn't exists. Press any key."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   M->nRentedTo = MOVIES->RENTED_TO
   
   IF M->nRentedTo != 0
      @ 22, 1 SAY "Movie is already rented. Press any key."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   REPLACE MOVIES->RENTED_TO WITH M->nCLientID, ;
           MOVIES->RENTED_ON WITH DATE() 

   M->cMovieName := MOVIES->TITLE 
   * @ 22, 1 SAY M->cMovieName + " has been rented'. Press any key."
   INKEY(0)



RETURN


* ───────────────────────────────────────────────────────────────────────
* ### Flow 3 — Return a movie
*
* The operator:
* 1. Enters the catalog ID of the movie being returned
* 2. The system finds the active rental for that movie
* ...
* ───────────────────────────────────────────────────────────────────────
PROCEDURE ReturnMovie()
    LOCAL nMovieID
    LOCAL GETLIST
    LOCAL cMovieName
    LOCAL nArea 
    LOCAL nDaysRented
    
    GETLIST := {}
    nArea := SELECT()

   CLEARSCREEN()

   * 1. Enters the catalog ID of the movie being returned

   @ 0, 0 SAY PADC(APP_TITLE, 80)
   @ 3, 2, 10, 60 BOX DBLBOX
   @ 4, 4 SAY "RETURN A MOVIE"
   @ 5, 3 SAY REPLICATE(HRULE, 57)
   @ 7, 4 SAY "Movie ID: "
   @ 24, 1 SAY "[Enter] Confirm   [Esc] Cancel"

   M->nMovieID := SPACE(4)
   @ 7, 14 GET M->nMovieID PICT "@999"
   READ

   * LASTKEY() == 27 significa que el usuario presionó Esc durante el GET
   IF LASTKEY() == 27
      SELECT (nArea)
      RETURN
   ENDIF

   IF LEN(M->nMovieID) = 0
      @ 22, 1 SAY "This field cannot be empty. Press any key."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   * 2. The system finds the active rental for that movie

   M->nMovieID  := VAL(M->nMovieID)

   SELECT MOVIES
   SEEK M->nMovieID
   IF !FOUND()
      @ 22, 1 SAY "Movie doesn't exists. Press any key."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   M->nRentedTo = MOVIES->RENTED_TO
   
   IF M->nRentedTo = 0
      @ 22, 1 SAY "Movie is not rented. Press any key."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   * 3. The system calculates whether the return is late
   *   DAYS = DATE() - MOVIES->RENTED_ON
   *   DAYS vs M->nMaxRentals

   M->nDaysRented := Date() - MOVIES->RENTED_ON
   M->cMovieName := MOVIES->TITLE 
   
   IF M->nDaysRented > M->nRentalDays
      @ 22, 1 SAY M->cMovieName + " is late by " + LTRIM(STR((M->nDaysRented - M->nRentalDays))) + " days. Press any key."
      INKEY(0)
   ENDIF 


   * 4. If late: displays the fee owed (`days_overdue × daily_late_fee`). 
   *  Decide not to implenet the fees calculation.  Already proved what wanted to try. 
   
   * 5. The movie is marked as available again. The rental is marked as closed.   
   REPLACE MOVIES->RENTED_TO WITH 0, ;
           MOVIES->RENTED_ON WITH CTOD("  /  /  ")

 
   @ 22, 1 SAY M->cMovieName + " has been returned. Press any key."
   INKEY(0)

RETURN


* ───────────────────────────────────────────────────────────────────────
*  ### Flow 1 — Register a customer
* ───────────────────────────────────────────────────────────────────────
PROCEDURE NewCustomer()

   LOCAL nNewId
   LOCAL nArea
   LOCAL GETLIST
   LOCAL cName 
   
   GETLIST := {}
   nArea := SELECT()

   CLEARSCREEN()
   @ 0, 0 SAY PADC(APP_TITLE, 80)
   @ 3, 2, 10, 60 BOX DBLBOX
   @ 4, 4 SAY "NEW CUSTOMER"
   @ 5, 3 SAY REPLICATE(HRULE, 57)
   @ 7, 4 SAY "Name: "
   @ 24, 1 SAY "[Enter] Confirm   [Esc] Cancel"

   M->cName := SPACE(60)
   @ 7, 11 GET M->cName PICT "@S48"
   READ

   * LASTKEY() == 27 user pressed Esc on  GET
   IF LASTKEY() == 27
      SELECT (nArea)
      RETURN
   ENDIF

   M->cName := ALLTRIM(M->cName)
   
   IF LEN(M->cName) == 0
      @ 22, 1 SAY "This field cannot be empty. Press any key."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   * Auto-increment: MAX + 1, con fallback a 1 si la tabla está vacía
   SELECT CUSTOMERS
   GO BOTTOM
   IF EOF() .OR. BOF()
      nNewId := 1
   ELSE
      nNewId := CUSTOMERS->ID + 1
   ENDIF

   APPEND BLANK
   REPLACE CUSTOMERS->ID   WITH nNewId, ;
           CUSTOMERS->NAME WITH M->cName ;

   REINDEX

   @ 22, 1 SAY "Customer "+ ALLTRIM(M->cName) + " added. Member ID: " + LTRIM(STR(nNewId)) + "   "
   INKEY(0)

   SELECT (nArea)
RETURN

* ───────────────────────────────────────────────────────────────────────
*  ### Seek and return the quantity of movies rented by a client 
* ───────────────────────────────────────────────────────────────────────
FUNCTION SeekRentalsFrom
  PARAMETERS nCustID
  
  LOCAL nArea, nRentals 

  nArea := SELECT()
  nRentals := 0 
  SELECT MOVIES
  GO TOP
  DO WHILE .NOT. EOF()
     IF (MOVIES->RENTED_TO == nCustID)
        nRentals := nRentals + 1
     ENDIF 
     SKIP 
  ENDDO

  SELECT (nArea) 

RETURN nRentals


* ───────────────────────────────────────────────────────────────────────
*  ### Flow 5 — Customer list
*  The operator views a paginated list of all customers with their 
*  current number of active rentals.
* ───────────────────────────────────────────────────────────────────────
PROCEDURE CustomerList()
   LOCAL aList
   LOCAL nTotal, nPage, nPages, nFrom, nTo, nRow, nActiveRentals
   LOCAL i, cKey, nArea
   LOCAL PAGE_SIZE
   PAGE_SIZE := 15

   nArea := SELECT()
   
   aList := {}
 
   SELECT CUSTOMERS
   GO TOP
   DO WHILE .NOT. EOF()
      nActiveRentals := SeekRentalsFrom(CUSTOMERS->ID)
      AADD(aList, {CUSTOMERS->ID, ALLTRIM(CUSTOMERS->NAME), nActiveRentals})
      SKIP
   ENDDO

   IF LEN(aList) = 0
      @ 22, 1 SAY "No customers available.                "
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   nTotal := LEN(aList)
   nPages := INT((nTotal - 1) / PAGE_SIZE) + 1
   nPage  := 1
   
   DO WHILE .T.
      CLEARSCREEN()
      @ 0, 0 SAY PADC(APP_TITLE, 80)
      @ 1, 2 SAY "CUSTOMERS     "
      @ 2, 2 SAY REPLICATE(HRULE, 76)
      @ 3, 4 SAY "  ID    Name                           Active Rentals "
      @ 4, 2 SAY REPLICATE(HRULE, 76)

      nFrom := (nPage - 1) * PAGE_SIZE + 1
      nTo   := MIN(nPage * PAGE_SIZE, nTotal)

      FOR i := nFrom TO nTo
         nRow := 4 + (i - nFrom + 1)
         @ nRow, 4 SAY STR(aList[i][1], 5) + "   " + LEFT(aList[i][2]+SPACE(30), 30) + " " + STR(aList[i][3], 5)
      NEXT

      @ 20, 2 SAY REPLICATE(HRULE, 76)
      @ 21, 4 SAY "Page " + LTRIM(STR(nPage)) + " of " + LTRIM(STR(nPages)) + ;
                  "   (" + LTRIM(STR(nTotal)) + " available)"
      @ 24, 1 SAY "[N] Next   [P] Prev   [Esc] Back to menu"

      cKey := UPPER(CHR(INKEY(0)))
      DO CASE
      CASE cKey == "N"
         IF nPage < nPages
            nPage := nPage + 1
         ENDIF
      CASE cKey == "P"
         IF nPage > 1
            nPage := nPage - 1
         ENDIF
      CASE ASC(cKey) == 27
         EXIT
      ENDCASE
   ENDDO

   SELECT (nArea)
RETURN

* ───────────────────────────────────────────────────────────────────────
* Available movies
*  Present a listing of movies available to rent.
* ───────────────────────────────────────────────────────────────────────

PROCEDURE AvailableMovies()
   LOCAL aList
   LOCAL nTotal, nPage, nPages, nFrom, nTo, nRow
   LOCAL i, cKey, nArea
   LOCAL PAGE_SIZE
   PAGE_SIZE := 15

   nArea := SELECT()

   aList := {}
   SELECT MOVIES
   GO TOP
   DO WHILE .NOT. EOF()
      IF MOVIES->RENTED_TO == 0
         AADD(aList, {MOVIES->ID, ALLTRIM(MOVIES->TITLE)})
      ENDIF
      SKIP
   ENDDO

   IF LEN(aList) = 0
      @ 22, 1 SAY "No movies available.                    "
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   nTotal := LEN(aList)
   nPages := INT((nTotal - 1) / PAGE_SIZE) + 1
   nPage  := 1

   DO WHILE .T.
      CLEARSCREEN()
      @ 0, 0 SAY PADC(APP_TITLE, 80)
      @ 1, 2 SAY "AVAILABLE MOVIES"
      @ 2, 2 SAY REPLICATE(HRULE, 76)
      @ 3, 4 SAY "  ID    Title"
      @ 4, 2 SAY REPLICATE(HRULE, 76)

      nFrom := (nPage - 1) * PAGE_SIZE + 1
      nTo   := MIN(nPage * PAGE_SIZE, nTotal)

      FOR i := nFrom TO nTo
         nRow := 4 + (i - nFrom + 1)
         @ nRow, 4 SAY STR(aList[i][1], 5) + "   " + aList[i][2]
      NEXT

      @ 20, 2 SAY REPLICATE(HRULE, 76)
      @ 21, 4 SAY "Page " + LTRIM(STR(nPage)) + " of " + LTRIM(STR(nPages)) + ;
                  "   (" + LTRIM(STR(nTotal)) + " available)"
      @ 24, 1 SAY "[N] Next   [P] Prev   [Esc] Back to menu"

      cKey := UPPER(CHR(INKEY(0)))
      DO CASE
      CASE cKey == "N"
         IF nPage < nPages
            nPage := nPage + 1
         ENDIF
      CASE cKey == "P"
         IF nPage > 1
            nPage := nPage - 1
         ENDIF
      CASE ASC(cKey) == 27
         EXIT
      ENDCASE
   ENDDO

   SELECT (nArea)

RETURN

* ───────────────────────────────────────────────────────────────────────
* ### Flow 6 — Add a movie to the catalog
* The operator adds a new movie to the system
* ───────────────────────────────────────────────────────────────────────
PROCEDURE NewMovie()

   LOCAL cTitle
   LOCAL nNewId
   LOCAL nArea
   LOCAL GETLIST

   GETLIST := {}
   nArea := SELECT()

   CLEARSCREEN()
   @ 0, 0 SAY PADC(APP_TITLE, 80)
   @ 3, 2, 10, 60 BOX DBLBOX
   @ 4, 4 SAY "NEW MOVIE"
   @ 5, 3 SAY REPLICATE(HRULE, 57)
   @ 7, 4 SAY "Title: "
   @ 24, 1 SAY "[Enter] Confirm   [Esc] Cancel"

   cTitle := SPACE(60)
   @ 7, 11 GET cTitle PICT "@S48"
   READ

   * LASTKEY() == 27 usr pressed ESC
   IF LASTKEY() == 27
      SELECT (nArea)
      RETURN
   ENDIF

   cTitle := ALLTRIM(cTitle)

   IF LEN(cTitle) = 0
      @ 22, 1 SAY "This field cannot be empty. Press any key."
      INKEY(0)
      SELECT (nArea)
      RETURN
   ENDIF

   * Auto-increment: MAX + 1, con fallback a 1 si la tabla está vacía
   SELECT MOVIES
   GO BOTTOM
   IF EOF() .OR. BOF()
      nNewId := 1
   ELSE
      nNewId := MOVIES->ID + 1
   ENDIF

   APPEND BLANK
   REPLACE MOVIES->ID  WITH nNewId, ;
           MOVIES->TITLE     WITH cTitle, ;
           MOVIES->RENTED_TO WITH 0, ;
           MOVIES->RENTED_ON WITH CTOD("  /  /  ")

   REINDEX

   @ 22, 1 SAY "Movie added. Catalog ID: " + LTRIM(STR(nNewId)) + "   "
   INKEY(0)

   SELECT (nArea)

RETURN

* ───────────────────────────────────────────────────────────────────────
* Clean screen by writing empty lines
* ───────────────────────────────────────────────────────────────────────
PROCEDURE CLEARSCREEN()
   LOCAL i 
   FOR i := 0 TO 24
      @ i,0 SAY SPACE(80)
   NEXT

   SETPOS(0,0)
RETURN 