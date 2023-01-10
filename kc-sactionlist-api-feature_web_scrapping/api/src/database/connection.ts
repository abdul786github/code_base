/* Managing MYSQL DB connection
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Creating file and method to handle DB connections
 */

import mysql from "mysql";
import * as dotenv from "dotenv";

dotenv.config();

/**
 * @function - createConnection
 * @description - Function to setup DB connection
 * @returns - Gets the DB connection object
 */
const createConnection = () => {
  return new Promise((resolve, reject) => {
    try {
      const pool = mysql.createPool({
        user: process.env.DB_USERNAME,
        host: process.env.DB_HOST,
        database: process.env.DB_NAME,
        password: process.env.DB_PASSWORD,
        port: Number(process.env.DB_PORT),
      });
      resolve(pool);
    } catch (error) {
      reject(error);
    }
  });
};

export default createConnection;
