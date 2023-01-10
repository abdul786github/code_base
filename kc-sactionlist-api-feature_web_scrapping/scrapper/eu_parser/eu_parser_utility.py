"""" FETCHING EU DATA AND SAVING IT AS  PDF.
* Developed By : Travancore Analytics (2022)
* Author: SIBIN PAUL , ABDUL MANAF M
* Created on:21/10/2022
* Project: Kinara Capital
* Revision History:
* SNo.   | Date        | Author                   | Task                              | Comments |
* 1      21/10/2022     SIBIN PAUL ,ABDUL MANAF               FETCHING EU DATA AND SAVING IT AS  PDF                """
import re
import os
import json
import requests

from PyPDF2 import PdfReader
from utils import dob_format_converter_eu,json_converter


def download_eu_sanction_list_pdf(eu_url, destination_folder):
    """ Function to download sanction list pdf from EU url

    Args:
        eu_url: EU sanction list pdf url
        destination_folder: Folder in which pdf file should be downloaded

    Returns: returns the filepath where pdf is downloaded

    """
    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)  # create folder if it does not exist

    filename = "eu_sanction_list"  # be careful with file names
    file_path = os.path.join(destination_folder, filename)

    r = requests.get(eu_url, stream=True)
    if r.ok:
        print("saving to", os.path.abspath(file_path))
        with open(file_path, 'wb') as f:
            for chunk in r.iter_content(chunk_size=1024 * 8):
                if chunk:
                    f.write(chunk)
                    f.flush()
                    os.fsync(f.fileno())
    else:  # HTTP status code 4XX/5XX
        print("Download failed: status code {}\n{}".format(r.status_code, r.text))

    return file_path


def extract_eu_data_from_pdf(file_path):
    """ Function to extract EU sanction data from pdf

    Args:
        file_path: Absolute path to the pdf file

    Returns: returns the EU sanctions data as a list

    """
    reader = PdfReader(file_path)
    full_list = []
    text = ""
    for page in reader.pages:
        text += page.extract_text()

    text_list = text.split('EU reference number:')
    sanction_data_list = []
    for text_data in text_list:
        name = ''
        email_list=[]
        alias_names = []
        dob = []
        pob = []
        nationality = []
        address = []
        passport_no = []
        identification_no = []
        full_list.append(text_list)
        text_data = text_data.split('\n')
        sanction_data_dict = {}
        if 'Identity information:' or 'Contact information:' in text_data: 
            for text in text_data:
                sanction_data_dict = {}
                if 'Name/Alias:' in text:
                    name_str, title, designation = __split_name_text(text)
                    if name == '':
                        name = name_str
                    else:
                        alias_names.append(name_str.replace(" ",""))
                if 'Birth date:' in text:
                    birth_date, birth_place = __split_birth_details_text(text)
                    dob.append(birth_date)
                    pob.append(birth_place)
                if 'Citizenship:' in text:
                    citizenship = __split_details_and_remove_remarks(text, 'Citizenship:')
                    nationality.append(citizenship)
                if 'Address:' in text:
                    address_string = __split_details_and_remove_remarks(text, 'Address:')
                    address.append(address_string)
                if 'Source:' in text:
                    passport_number, identification_number, source = __fetch_document_details(text)
                    if passport_number:
                        passport_no.append(passport_number)
                    if identification_number:
                        identification_no.append([source, identification_number])
                if 'Email:' in text:
                    email_string =  __fetch_document_details_email(text)
                    email_list.extend(email_string)

            sanction_data_dict['name'] = name.replace(" ","")
            sanction_data_dict['passport_no'] = json_converter(passport_no )#
            sanction_data_dict['email_address'] = json_converter(eu_filter_email(email_list))#
            sanction_data_dict['alias_name_good_quality'] = json_converter(alias_names)
            sanction_data_dict['dob'] =json_converter(dob_format_converter_eu(dob))
            sanction_data_dict['pob'] = json_converter(pob)
            sanction_data_dict['nationality'] = json_converter(nationality)
            sanction_data_dict['address'] = json_converter(address)
            sanction_data_dict['identification_no'] = __set_identification_number(identification_no)
            sanction_data_dict['data_source'] = 'EU'
            sanction_data_list.append(sanction_data_dict)

    return sanction_data_list


def __split_name_text(name_text):
    """ Function to split name text

    Args:
        name_text: Text contain name details

    Returns: returns the name, title and designation

    """
    designation = None
    title = None
    if 'Function:' in name_text:
        string_list = name_text.split('Function:')
        designation = string_list[-1].strip()
        if 'Title:' in name_text:
            string_list = string_list[0].split('Title:')
            title = string_list[1].strip()
        name = string_list[0].split('Name/Alias:')[1].strip()
    elif 'Title:' in name_text:
        string_list = name_text.split('Title:')
        title = string_list[-1].strip()
        name = string_list[0].split('Name/Alias:')[1].strip()
    else:
        name = name_text.split('Name/Alias:')[1].strip()

    return name, title, designation


def __split_birth_details_text(birth_details_text):
    """ Function to split birth details text

    Args:
        birth_details_text: Text contain birth details

    Returns: returns birthdate and birthplace

    """
    pob = None
    if 'Birth place:' in birth_details_text:
        string_list = birth_details_text.split('Birth place:')
        if 'Remark:' in string_list:
            pob_remark_list = string_list[1].split('Remark:')
            pob = pob_remark_list[0].strip()
        else:
            pob = string_list[1].strip()
        dob = string_list[0].split('Birth date:')[1].strip()
    else:
        dob = birth_details_text.split('Birth date:')[1].strip()

    return dob, pob


def __split_details_and_remove_remarks(text_string, data_key):
    """ Function to remove remarks text and fetch details

    Args:
        text_string: string text contains details

    Returns: returns the details

    """
    if 'Remark:' in text_string:
        string_list = text_string.split('Remark:')
        details_string = string_list[0].split(data_key)
        if len(details_string) > 1:
            exact_string = details_string[1].strip()
        else:
            exact_string = details_string[0].strip()
    else:
        string_list = text_string.split(data_key)
        if len(string_list) > 1:
            exact_string = string_list[1].strip()
        else:
            exact_string = string_list[0].strip()
    return exact_string


def __fetch_document_details(text_string):
    """ Function to fetch document details from the text

    Args:
        text_string: String contains document details

    Returns: returns document details

    """
    passport_no = None
    identification_no = None
    source = None
    vals = [x.strip() for x in re.split(r"\w+:", text_string)[1:]]
    keys = re.findall(r"[\w/]+:", text_string)
    document_details = dict(zip(keys, vals))
    if 'Document:' in document_details:
        document_string = document_details['Document:']
        source = document_details['Source:'].strip()
        if 'National passport' in document_string:
            passport_no = document_string.split('National passport')[0].strip()
        elif 'National identification card' in document_string:
            identification_no = document_string.split('National identification card')[1].strip()
    return passport_no, identification_no, source


def __set_identification_number(identification_no_list):
    """ Function to convert Identification number to JSON format

    Args:
        identification_no_list: List of identification numbers

    Returns: returns list of identification numbers in a JSON format

    """
    identification_no_dict = {}
    for identification_no in identification_no_list:
        country_string = identification_no[0]
        identification_number = identification_no[1]
        if country_string != 'Unknown country':
            if country_string in identification_no_dict:
                identification_no_dict[country_string].append(identification_number)
            else:
                identification_no_dict[country_string] = [identification_number]
        else:
            if "unknown" in identification_no_dict:
                identification_no_dict["unknown"].append(identification_number)
            else:
                identification_no_dict["unknown"] = [identification_number]
    identification_no_dict = json.dumps(identification_no_dict)
    return identification_no_dict


def  __fetch_document_details_email(text_string):
    """ Function to fetch emails from data

    Args:
        string of data
    Returns: Returns emails fetched from data

    """
    emails=[]
    vals = [x.strip() for x in re.split(r"\w+:", text_string)[1:]]
    keys = re.findall(r"[\w/]+:", text_string)
    document_details = dict(zip(keys, vals))
    if "Email:" in document_details:
        email_string = document_details["Email:"]
        emails.append(email_string)
    return emails


def eu_filter_email(email_list):
    """FUNCTION TO FORMAT FETCHED EMAIL
    Args:
        string of data
    Returns: Returns emails fetched from data in required format

    """
    email_list_final=[]
    for raw_email in email_list:
        emails = re.findall(r"[A-Za-z0-9\.?\-?+_]+@[A-Za-z0-9\.\-+_]+\.?[A-Za-z]+",raw_email)
        email_list_final.extend(emails)
    return email_list_final