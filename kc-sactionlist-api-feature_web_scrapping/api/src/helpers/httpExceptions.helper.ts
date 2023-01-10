/* Managing HTTP request response exceptions
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Vishnu Viswambharan
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Vishnu Viswambharan        Creating class to handle http exceptions
 */

export default class HttpException extends Error {
  statusCode: number;
  statusMessage: string;
  error: string | null;

  constructor(statusCode: number, statusMessage: string, error?: string) {
    super(statusMessage);
    this.statusCode = statusCode;
    this.statusMessage = statusMessage;
    this.error = error || null;
  }
}
