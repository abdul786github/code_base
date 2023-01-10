/* Middleware to handle errors
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Vishnu Viswambharan
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Vishnu Viswambharan        Module creation method to handle errors
 */

import { Request, Response } from "express";
import HttpException from "../helpers/httpExceptions.helper";

/**
 * @function - errorHandler
 * @description - Middleware to handle response errors
 * @param error - Error object
 * @param request - Request object
 * @param response - Response object
 * @returns - Returns error responsed with valid status code and message
 */
export const errorHandler = (
  error: HttpException,
  request: Request,
  response: Response
) => {
  const status = error.statusCode || 500;

  response
    .status(status)
    .send({ ResponseMessage: error.statusMessage, IsError: true });
};
