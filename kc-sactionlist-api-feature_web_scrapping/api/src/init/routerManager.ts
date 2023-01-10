/* Managing endpoints
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Module creation adding base routes
 */

import express from "express";
import UserRouter from "../router/user.router";
import AuthRouter from "../router/authorization.router";

const RouterManager = express.Router();

RouterManager.use("/auth", AuthRouter);
RouterManager.use("/user", UserRouter);

export default RouterManager;
