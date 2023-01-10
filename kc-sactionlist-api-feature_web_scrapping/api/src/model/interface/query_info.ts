/* Interface to handle user validation requests
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Module creation
 */

export interface ValidateUserQueryInfo {
  name?: string | null;
  pob?: string | null;
  nationality?: string | null;
  passport_no?: string | null;
  address?: string | null;
  drivers_license_no?: string | null;
  dob?: string | null;
  gender?: string | null;
  email?: string | null;
  national_identification_no?: string | null;
  aadhar_no?: string | null;
  pan_no?: string | null;
}
