/* Managing authorization services
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Module creation and authentication services implementation
 */

import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import { HttpStatus } from "../common/httpStatus";
import { responseMessage } from "../common/responseMessage";
import server from "../app";
import { errorHandler } from "../middleware/errorHandler.middleware";
import HttpException from "../helpers/httpExceptions.helper";
import { errorConst } from "../common/errorConstant";
import { cipherDecryption } from "..//helpers/authorization.helper";

export class AuthorizationService {
  /**
   * @function - userLogin
   * @description - Method to handle user login
   * @param req - Request object
   * @param res - Response object
   * @returns - Returns validate user with JWT token
   */
  public userLogin = async (req: Request, res: Response) => {
    try {
      const bodyData = req.body;
      await server.dbConnection.query(
        {
          sql: `
          SELECT * FROM user WHERE LOWER(TRIM(username)) = LOWER(TRIM('${bodyData.username}'));
        `,
          timeout: process.env.DB_TIMEOUT,
        },
        async (err: any, row: any) => {
          if (err) {
            return errorHandler(err, req, res);
          } else {
            if (!row[0]) {
              return errorHandler(
                new HttpException(
                  HttpStatus.STATUS_NOT_FOUND,
                  errorConst.userNotFound
                ),
                req,
                res
              );
            } else {
              const decryptedPassword = await cipherDecryption(
                row[0]?.password
              );
              if (String(bodyData?.password) !== String(decryptedPassword)) {
                return errorHandler(
                  new HttpException(
                    HttpStatus.STATUS_BAD_REQUEST,
                    errorConst.passwordInvalid
                  ),
                  req,
                  res
                );
              }

              const tokenData = {
                userId: row[0].id,
                username: row[0].username,
              };

              const token = this.createToken(tokenData);

              return res.status(HttpStatus.STATUS_OK).send({
                message: responseMessage?.USERLOGGEDINSUCCESS,
                accessToken: token,
              });
            }
          }
        }
      );
    } catch (error: any) {
      return errorHandler(error, req, res);
    }
  };

  /**
   * @function - createToken
   * @description - Method to create JWT token from given data
   * @param tokenData -Data for creating token
   * @returns - Returns JWT token
   */
  createToken = (tokenData: any) => {
    const token = jwt.sign(tokenData, process.env.SECRET_KEY as string, {
      expiresIn: process.env.TOKEN_EXPIRY,
    });
    return token;
  };
}
