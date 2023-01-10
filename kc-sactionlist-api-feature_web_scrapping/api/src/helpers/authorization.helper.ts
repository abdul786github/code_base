/* String hashing helper methods
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Creating methods to handle string encryption and decryption
 */

import * as bcrypt from "bcryptjs";
const CryptoJS = require("crypto-js");

/**
 * @function - checkUnencryptedValue
 * @description - Function to validate given string with its own hash value
 * @param unencryptedValue  String to compare
 * @param encryptedValue  Hashed string to compare
 * @returns - Gets the validation result as boolean
 */
export const checkUnencryptedValue = (
  unencryptedValue: string,
  encryptedValue: string
) => {
  return bcrypt.compareSync(unencryptedValue, encryptedValue);
};

/**
 * @function - cipherEncryption
 * @description - Function to create hash value based on given secret key
 * @param value  String to be hashed
 * @returns - Gets the hashed value
 */
export const cipherEncryption = (value: string) => {
  return CryptoJS.AES.encrypt(value, process.env.SECRET_KEY).toString();
};

/**
 * @function - cipherDecryption
 * @description - Function to decrypt given hashed string
 * @param value  String to be decrypted
 * @returns - Gets the decrypted value
 */
export const cipherDecryption = (cipherEncryptedValue: string) => {
  try {
    const bytes = CryptoJS.AES.decrypt(
      cipherEncryptedValue,
      process.env.SECRET_KEY
    );
    return bytes.toString(CryptoJS.enc.Utf8);
  } catch (error: any) {
    console.log(error, "inside cipeher decryption");
    throw error;
  }
};
