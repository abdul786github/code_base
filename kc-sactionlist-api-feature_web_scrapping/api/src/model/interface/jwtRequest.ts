/* Interface to handle http requests
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Module creation
 */

import { Request } from "express";

declare global {
  namespace Express {
    interface Request {
      payload: {
        userId: string;
        username: string;
        exp: number;
        iat: number;
      };
    }
  }
}

export interface JwtRequest extends Request {
  payload: {
    userId: string;
    username: string;
    exp: number;
    iat: number;
  };
}
