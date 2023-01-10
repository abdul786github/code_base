/* Managing user routes
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Module creation and routes implementation
 */

import { Router, Request, Response, NextFunction } from "express";
import { validationResult, query, matchedData } from "express-validator";
import { errorConst } from "../common/errorConstant";
import { HttpStatus } from "../common/httpStatus";
import { UserService } from "../service/user.service";
import { AuthCheckTokenAdmin } from "../middleware/auth.middleware";

const router: Router = Router();
const userService = new UserService();

router.get(
  "/validate",
  AuthCheckTokenAdmin,
  [
    query(
      [
        "name",
        "pob",
        "nationality",
        "passport_no",
        "address",
        "national_identification_no",
        "drivers_license_no",
        "dob",
        "gender",
        "email",
        "aadhar_no",
        "pan_no",
      ],
      errorConst.errorInvalidInput
    ).optional(),
  ],
  async (req: Request, res: Response, next: NextFunction) => {
    const matchedParams = matchedData(req, {
      onlyValidData: true,
      includeOptionals: true,
      locations: ["query"],
    });

    req.query = matchedParams;
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res
        .status(HttpStatus.STATUS_BAD_REQUEST)
        .send({ error: errors.array()[0]?.msg });
    } else {
      userService.validateUser(req, res);
    }
  }
);

export default router;
