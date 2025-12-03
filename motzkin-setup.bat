@echo off
setlocal

rem =====================================
rem Motzkin PostgreSQL Database Utility
rem =====================================
echo ==========================================
echo      Motzkin Database Utility
echo ==========================================
echo.

rem --- בקשת סיסמה מהמשתמש ---
set /p PGPASSWORD=Enter PostgreSQL password: 

rem --- הגדרת מסלול psql מלא ---
set PSQL="C:\Program Files\PostgreSQL\17\bin\psql.exe"

rem --- הגדרות בסיס ---
set DB_NAME=motzklist
set DB_USER=postgres
set DB_HOST=127.0.0.1
set SQL_FILE=init.sql

echo.
echo Choose an option:
echo 1. Create database
echo 2. Create tables
echo 3. Drop tables
echo 4. Drop database
echo 5. All (create DB if not exists + create tables)
set /p OPTION=Enter your choice [1-5]:

echo.

if "%OPTION%"=="1" goto CREATE_DB
if "%OPTION%"=="2" goto CREATE_TABLES
if "%OPTION%"=="3" goto DROP_TABLES
if "%OPTION%"=="4" goto DROP_DB
if "%OPTION%"=="5" goto ALL

echo Invalid option!
goto END

rem ---------------------------
:CREATE_DB
echo Creating database "%DB_NAME%" (ignoring errors if exists)...
%PSQL% -U %DB_USER% -h %DB_HOST% -c "CREATE DATABASE %DB_NAME%;" 2>NUL
goto END

:CREATE_TABLES
echo Creating tables from "%SQL_FILE%"...
%PSQL% -U %DB_USER% -h %DB_HOST% -d %DB_NAME% -f %SQL_FILE%
goto END

:DROP_TABLES
echo Dropping all tables in "%DB_NAME%"...
rem --- מחיקת כל טבלאות קיימות
%PSQL% -U %DB_USER% -h %DB_HOST% -d %DB_NAME% -c "DO $$ DECLARE r RECORD; BEGIN FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname='public') LOOP EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE'; END LOOP; END $$;"
goto END

:DROP_DB
echo Dropping database "%DB_NAME%"...
%PSQL% -U %DB_USER% -h %DB_HOST% -c "DROP DATABASE IF EXISTS %DB_NAME%;"
goto END

:ALL
echo Creating database "%DB_NAME%" if it does not exist...
%PSQL% -U %DB_USER% -h %DB_HOST% -c "CREATE DATABASE %DB_NAME%;" 2>NUL

echo Creating tables from "%SQL_FILE%"...
%PSQL% -U %DB_USER% -h %DB_HOST% -d %DB_NAME% -f %SQL_FILE%
goto END

:END
echo.
echo Done!
pause
endlocal
