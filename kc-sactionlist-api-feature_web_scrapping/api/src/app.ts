/* Managing Node.js Server and Swagger documents
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Module creation
 * 2      14/11/2022    Mujeeburrahman KM        Swagger docs implemetation
 */

import dotEnv from "dotenv";
import swaggerUi from "swagger-ui-express";
import ApiRouter from "./init/routerManager";
import createConnection from "./database/connection";
import express, { Application, NextFunction, Request, Response } from "express";
import cookieParser from "cookie-parser";

const swaggerDocument = require("./swagger.json");

dotEnv.config();
class Server {
  app: Application;
  dbConnection: any; // eslint-disable-line
  constructor() {
    this.app = express();
    this.app.use(express.json());
    this.app.use(cookieParser());

    createConnection()
      .then((res: any) => {
        this.dbConnection = res;
      })
      .catch((error) => {
        console.log("connection error:", error); // eslint-disable-line no-console
      });

    this.app.use("/api", ApiRouter);

    this.app.get(
      "/",
      (
        req: Request, //eslint-disable-line
        res: Response
      ) => {
        res.status(200).json("KC Station List API");
      }
    );

    this.app.use(
      "/api-docs",
      function (
        req: any, // eslint-disable-line
        res: Response, //eslint-disable-line
        next: NextFunction
      ) {
        swaggerDocument.host = `${process.env.API_DOC_HOST}:${process.env.API_DOC_PORT}`;
        req.swaggerDoc = swaggerDocument;
        next();
      },
      swaggerUi.serve,
      swaggerUi.setup(swaggerDocument)
    );
  }

  async getApp() {
    if (!this.dbConnection) {
      this.dbConnection = await createConnection();
    }
    return this.app;
  }

  public start() {
    const PORT: number | string = process.env.PORT || 5000;
    this.app.listen(
      PORT,
      () => console.log(`Server is listening on port ${PORT}!`) // eslint-disable-line
    );
  }
}

export default new Server();
