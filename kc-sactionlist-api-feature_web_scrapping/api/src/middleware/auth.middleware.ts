/* Middleware to handle authorization
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Module creation method to handle authorization
 */

import { HttpStatus } from "../common/httpStatus";
import { Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { errorConst } from "../common/errorConstant";
import { JwtRequest } from "../model/interface/jwtRequest";

/**
 * @function - AuthCheckTokenAdmin
 * @description - Function to check user authenticity
 * @param req - Request object
 * @param res - Response object
 * @param next - Next function object
 */
export const AuthCheckTokenAdmin = (
  req: JwtRequest,
  res: Response,
  next: NextFunction
) => {
  const token = req.header("authorization");

  if (!token)
    return res
      .status(HttpStatus.STATUS_UNAUTHORIZED)
      .json(errorConst.accessDenied);

  let jwtPayload;

  try {
    jwtPayload = <any>jwt.verify(token, process.env.SECRET_KEY as string);
    req.payload = jwtPayload;
    next();
    return;
  } catch (error) {
    return res
      .status(HttpStatus.STATUS_UNAUTHORIZED)
      .send(errorConst.unauthorized);
  }
};
