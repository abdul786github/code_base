/* Managing authorization routes
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Module creation
 * 2      14/11/2022    Vishnu Viswambharan      Routes implementation
 */

import { Router, Request, Response } from "express";
import { validationResult, body } from "express-validator";
import { AuthorizationService } from "../service/authorization.service";
import { errorConst } from "../common/errorConstant";
import { HttpStatus } from "../common/httpStatus";

const authRouter: Router = Router();
const authorization = new AuthorizationService();

authRouter.post(
  "/login",
  [body(["username", "password"], errorConst.errorInvalidInput).notEmpty()],
  async (req: Request, res: Response) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res
        .status(HttpStatus.STATUS_BAD_REQUEST)
        .send({ error: errors.array()[0]?.msg });
    } else {
      authorization.userLogin(req, res);
    }
  }
);

export default authRouter;
