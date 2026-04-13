* TESTDATA.PRG
* Test data utility — sets up scenarios that require past rental dates.
* NOT part of the application. Development and testing use only.
*
* Usage from DOSBox:
*   CD to project root (D:)
*   CLIPPER TOOLS\TESTDATA /N /W
*   RTLINK FI TOOLS\TESTDATA LIB CLIPPER
*   TOOLS\TESTDATA
*
* Scenarios loaded:
*   TC-041: Movie 2 rented to Customer 1, RENTED_ON = today - 5 days
*           (RENTAL_DAYS=3, so 2 days overdue)
*   TC-042: Movie 3 rented to Customer 1, RENTED_ON = today - 3 days
*           (exactly on due date, assuming RENTAL_DAYS=3)
*
* Preconditions: MOVIES.DBF must have movies with ID 2 and 3.
*                CUSTOMERS.DBF must have customer with ID 1.
*                Movies 2 and 3 must currently be available (RENTED_TO = 0).

PROCEDURE MAIN

   LOCAL lOk

   ? "VIDEOCLUB Test Data Utility"
   ? "============================"
   ?

   * Open files
   IF .NOT. FILE("DATA\MOVIES.DBF")
      ? "[ERROR] DATA\MOVIES.DBF not found. Aborting."
      RETURN
   ENDIF

   USE DATA\MOVIES INDEX DATA\MOVIES ALIAS MOV
   IF NETERR()
      ? "[ERROR] Could not open MOVIES.DBF. Aborting."
      RETURN
   ENDIF

   * --- TC-041: Movie 2, 5 days ago, 2 days overdue ---
   ?
   ? "Setting TC-041: Movie 2 rented 5 days ago..."

   SEEK 2
   IF FOUND()
      IF MOV->RENTED_TO = 0
         REPLACE MOV->RENTED_TO WITH 1, ;
                 MOV->RENTED_ON WITH DATE() - 5
         ? "  Movie 2: RENTED_TO=1, RENTED_ON=" + DTOC(DATE() - 5) + " [OK]"
      ELSE
         ? "  Movie 2 is already rented. Skipping."
      ENDIF
   ELSE
      ? "  Movie 2 not found. Create it first via the application."
   ENDIF

   * --- TC-042: Movie 3, exactly RENTAL_DAYS ago (due today) ---
   ?
   ? "Setting TC-042: Movie 3 rented 3 days ago (due today)..."

   SEEK 3
   IF FOUND()
      IF MOV->RENTED_TO = 0
         REPLACE MOV->RENTED_TO WITH 1, ;
                 MOV->RENTED_ON WITH DATE() - 3
         ? "  Movie 3: RENTED_TO=1, RENTED_ON=" + DTOC(DATE() - 3) + " [OK]"
      ELSE
         ? "  Movie 3 is already rented. Skipping."
      ENDIF
   ELSE
      ? "  Movie 3 not found. Create it first via the application."
   ENDIF

   CLOSE DATABASES

   ?
   ? "Done. Run VIDEOCLUB and execute TC-041 / TC-042."
   ?

RETURN
