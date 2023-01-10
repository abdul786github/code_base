/* Managing user services
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Module creation and user services implementation
 * 2      14/11/2022    Mujeeburrahman KM        Adding new params - Aadhar and PAN number
 * 3      21/11/2022    Mujeeburrahman KM        Adding formatter
 * 4      05/12/2022    Mujeeburrahman KM        Separate AML check and fuzzy logic implementation
 */

import { Request, Response } from "express";
import { HttpStatus } from "../common/httpStatus";
import { responseMessage } from "../common/responseMessage";
import server from "../app";
import { errorHandler } from "../middleware/errorHandler.middleware";
import { ValidateUserQueryInfo } from "../model/interface/query_info";

export class UserService {
  /**
   * @function - validateUser
   * @description - Method to validate user with given data
   * @param req - Request object
   * @param res - Response object
   * @returns - Validated result
   */
  public validateUser = async (req: Request, res: Response) => {
    try {
      const queryData: ValidateUserQueryInfo = req.query;
      let genderData = queryData?.gender;

      if (queryData?.gender?.toLowerCase() === "m") {
        genderData = "male";
      } else if (queryData?.gender?.toLowerCase() === "f") {
        genderData = "female";
      } else {
        genderData = queryData?.gender;
      }

      await server.dbConnection.query(
        {
          sql: `CALL validate_user(
          ${queryData?.email ? '"' + String(queryData?.email) + '"' : null},
          ${
            queryData?.nationality
              ? '"' + String(queryData?.nationality) + '"'
              : null
          },
          ${
            queryData?.passport_no
              ? '"' + String(queryData?.passport_no) + '"'
              : null
          },
          ${
            queryData?.national_identification_no
              ? '"' + String(queryData?.national_identification_no) + '"'
              : null
          },
          ${
            queryData?.drivers_license_no
              ? '"' + String(queryData?.drivers_license_no) + '"'
              : null
          },
          ${queryData?.name ? '"' + String(queryData?.name) + '"' : null},
          ${queryData?.dob ? '"' + String(queryData?.dob) + '"' : null},
          ${queryData?.pob ? '"' + String(queryData?.pob) + '"' : null},
          ${queryData?.address ? '"' + String(queryData?.address) + '"' : null},
          ${genderData ? '"' + String(genderData) + '"' : null},
          ${
            queryData?.aadhar_no
              ? '"' + String(queryData.aadhar_no) + '"'
              : null
          },
          ${queryData?.pan_no ? '"' + String(queryData?.pan_no) + '"' : null}
          )`,
          timeout: process.env.DB_TIMEOUT,
        },
        (err: any, row: any) => {
          if (err) {
            return errorHandler(err, req, res);
          } else {
            const formattedData = this.formateMatchedParams(
              queryData,
              row[0][0]
            );
            return res.status(HttpStatus.STATUS_OK).send({
              message: responseMessage?.VALIDATIONDATAFETCHSUCCESS,
              amlMatchScore: formattedData.amlScore,
              matchedParams: formattedData.statisfiedParams,
            });
          }
        }
      );
    } catch (error: any) {
      return errorHandler(error, req, res);
    }
  };

  /**
   * @function - formateMatchedParams
   * @description - Method to formate response from SQL query
   * @param requestData - ser request object
   * @param responseData - MYSQL query response object
   * @returns - Query response formatted data
   */
  formateMatchedParams = (requestData: any, responseData: any) => {
    let statisfiedParams: any = {};
    let totalScore = 0;
    let paramsCount = 0;
    const entries = Object.entries(responseData);

    entries.map(([key, val]: any) => {
      if (
        Object.prototype.hasOwnProperty.call(requestData, key) &&
        requestData[key]
      ) {
        let formattedKey = "";

        if (
          (responseData.secondary_count > 0 && key === "name") ||
          key === "dob" ||
          key === "pob" ||
          key === "address" ||
          key === "gender"
        ) {
          paramsCount = paramsCount + 1;
          if (key === "name") {
            formattedKey = "Name";
            totalScore = totalScore + val;
          } else if (key === "dob") {
            formattedKey = "DOB";
            totalScore = totalScore + val;
          } else if (key === "pob") {
            formattedKey = "POB";
            totalScore = totalScore + val;
          } else if (key === "address") {
            formattedKey = "Address";
            totalScore = totalScore + val;
          } else if (key === "gender") {
            formattedKey = "Gender";
            totalScore = totalScore + val;
          }

          statisfiedParams = {
            ...statisfiedParams,
            [formattedKey]: `${requestData[key]} (${
              val > 0 ? "Match found" : "No match found"
            } - ${val})`,
          };
        } else if (responseData.primary_count > 0) {
          if (key === "email") {
            formattedKey = "Email";
          } else if (key === "nationality") {
            formattedKey = "Nationality";
          } else if (key === "drivers_license_no") {
            formattedKey = "Drivers License No";
          } else if (key === "passport_no") {
            formattedKey = "Passport No";
          } else if (key === "national_identification_no") {
            formattedKey = "National Identification No";
          } else if (key === "aadhar_no") {
            formattedKey = "Aadhar No";
          } else if (key === "pan_no") {
            formattedKey = "Pan No";
          }

          statisfiedParams = {
            ...statisfiedParams,
            [formattedKey]: `${requestData[key]} (${
              val > 0 ? "Match found" : "No match found"
            } - ${val})`,
          };
        }
      }
    });

    let amlScore = 0;
    if (responseData.primary_count === 1) {
      amlScore = 1;
    } else if (responseData.secondary_count > 0) {
      amlScore = totalScore / paramsCount;
    }

    return { statisfiedParams, amlScore };
  };
}
