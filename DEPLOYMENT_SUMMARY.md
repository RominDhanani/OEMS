# OEMS Production Setup & Fixes Summary

## Project Links
- **Vercel Frontend**: https://oems-frontend.vercel.app
- **Vercel Backend**: https://oems-backend.vercel.app
- **Aiven Database Host**: mysql-36cdc1f2-manav-188a.i.aivencloud.com

## Fixes Implemented
1.  **Expense Creation**: Fixed 500 error by changing default status from `CREATED` to `PENDING_APPROVAL` in `backend/routes/expenses.js`.
2.  **Socket Timeouts**: Prevented frontend from attempting WebSocket connections on Vercel by adding environment detection in `SocketContext.jsx`.
3.  **Image/PDF Viewing**: Corrected path normalization in both Flutter and React to support Cloudinary absolute URLs.
4.  **Backend Stability**: Stubbed `Socket.io` on the backend to prevent crashes when the socket is uninitialized in serverless environments.

## CRITICAL: Required Manual Step
To enable **Expansion Requests** and fully sync the database with the code, you **MUST** run the migration locally:
1.  Open terminal in `backend` folder.
2.  Run: `node scripts/migrate_enums.js`

This step is necessary because the production database currently rejects external connections from my automated environment.
