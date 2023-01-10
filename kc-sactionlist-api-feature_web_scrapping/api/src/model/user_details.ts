/* Interface to handle user details
 *
 * Developed By : Travancore Analytics (2022)
 * Author: Mujeeburrahman KM
 * Created on: 09/11/2022
 * Project: Kinara Capital Sanctions List
 * Revision History:
 * SNo.   | Date        | Author                   | Task                       | Comments |
 * 1      09/11/2022    Mujeeburrahman KM        Module creation
 */

export interface UserDetails {
  id: number;
  name: string;
  originalScript?: string[];
  title?: string[];
  designation?: string[];
  dob?: string[];
  pob?: string[];
  goodQuality?: string[];
  lowQuality?: string[];
  nationality?: string[];
  passportNo?: string[];
  nationalIdentificationNo?: string[];
  address?: string[];
  listedOn?: string[];
  otherInformation?: string[];
  dataSource?: string[];
  createdOn?: string[];
}
