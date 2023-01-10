# US DATA FETCHING AND FORMATTING

import requests
from bs4 import BeautifulSoup
import datetime
import json
from utils import split_values_and_generate_list,dob_format_converter_us,json_converter,us_gender,us_single_aka_fetcher
import pandas as pd


def start_us_web_scraping(uk_url):
    """ Function to scrape sanction list from uk html page

    Args:
        uk_url: URL of the UK page

    Returns: returns web scraped raw data from uk website

    """
    r = requests.get(uk_url)

    soup = BeautifulSoup(r.content, 'html5lib')

    body = soup.find('body')
    body_text = body.string
    data_list = body_text.split('\n\n')
    return data_list


def format_us_data(us_scrape_data):
    """ Function to format US scrape data

    Args:
        us_scrape_data: Uk scrape data

    Returns: returns formatted list of UK data

    """
    sanction_data_list = []
    for scrape_data in us_scrape_data:
        sanction_data_dict = {}
        if '(individual)' in scrape_data:
            address_list = []
            data_details_list = scrape_data.split(';')
            name, address, alias_name = __format_name(data_details_list[0])
            name = name.replace(' ', '')
            alias_names_list, dob_list, pob_list, national_id_list, email_address_list, passport_list, nationality_list\
                , identification_no_list, national_id_no_list, drivers_license_list = ([] for i in range(10))
            gender = ''
            if alias_name: #1ST AKA IN DATA
                alias_names_list.append(alias_name.replace(" ","").replace(",","").replace(")",""))   

            if address:
                address_list.append(address)
                
            for data_details in data_details_list[1:]:
                data_details = data_details.replace('\n', ' ')
                data_details = str(data_details.split('(individual)')[0])
                if 'a.k.a.' in data_details: #LAST AKA IN DATA
                    if '),' in data_details:
                        address_details = data_details.split('),')
                        address_list.append(address_details[1].strip())
                        alias_names_string = address_details[0].strip()
                        alias_names_string = alias_names_string.replace('a.k.a.', '')
                                         
                        alias_names_string = alias_names_string.replace('"', '')
                        alias_names_string = alias_names_string.replace(" ","") #
                        alias_names_string = alias_names_string.replace(')', '') #
                        alias_names_list.append(alias_names_string.replace(",",""))
                    else: #2ND AKA IN DATA
                        data_details = data_details.split('a.k.a.')[1].strip()
                        data_details = data_details.replace('"', '')
                        data_details = data_details.replace(" ","")                        
                        data_details = data_details.replace(')', '')#
                        alias_names_list.append(data_details.replace(",",""))
                elif 'DOB' in data_details:
                    data_details = data_details.split('DOB')[1].strip()
                    dob_list.append(data_details)
                elif 'POB' in data_details:
                    data_details = data_details.split('POB')[1].strip()
                    data_details_pob = split_values_and_generate_list([data_details])                           
                elif 'nationality' in data_details:
                    data_details = data_details.split('nationality')[1].strip()
                    nationality_list.append(data_details)
                elif 'National ID No.' in data_details:
                    data_details = data_details.split('National ID No.')[1].strip()
                    national_id_list.append(data_details)
                elif 'Identification Number' in data_details:
                    data_details = data_details.split('Identification Number')[1].strip()
                    identification_no_list.append(data_details)
                elif 'Passport' in data_details:
                    data_details = data_details.split('Passport')[1].strip()
                    passport_list.append(data_details)
                elif "Driver's License No." in data_details:
                    data_details = data_details.split("Driver's License No.")[1].strip()
                    drivers_license_list.append(data_details)
                elif 'Email Address' in data_details:
                    data_details = data_details.split('Email Address')[1].strip()
                    email_address_list.append(data_details)
                elif 'Gender' in data_details:
                    data_details = data_details.split('Gender')[1].strip()
                    gender = data_details
                   
            sanction_data_dict['name'] = name.strip("'").replace(",","")
            sanction_data_dict['dob'] = json_converter(dob_format_converter_us(__format_date(dob_list)))
            sanction_data_dict['pob'] =  data_details_pob 
            sanction_data_dict['address'] = split_values_and_generate_list(address_list)
            sanction_data_dict['alias_name_good_quality'] = json_converter(alias_names_list)
            sanction_data_dict['passport_no'] = json_converter(passport_list)
            sanction_data_dict['nationality'] = json_converter(nationality_list)
            if identification_no_list:
                nationality = ''
                if nationality_list:
                    nationality = nationality_list[0]
                sanction_data_dict['identification_no'] = __format_identification_number(identification_no_list,
                                                                                         nationality)
            sanction_data_dict['national_identification_no'] = json_converter(national_id_list)
            sanction_data_dict['drivers_license_no'] = json_converter(drivers_license_list)
            sanction_data_dict['email_address'] = json_converter(email_address_list)
            sanction_data_dict['gender'] = us_gender(gender.strip())
            sanction_data_dict['data_source'] = 'US'
            sanction_data_list.append(sanction_data_dict)
    return sanction_data_list


def __format_name(name_string):
    """ FUnction to format name string

    Args:
        name_string: The whole name string which include name, alias name and address

    Returns: returns name, alias name and address

    """
    address = ''
    alias_names_string = ''
    if '(a.k.a.' in name_string:
        name_details_list = name_string.split('(a.k.a.')
        name = name_details_list[0]
        alias_names_string = name_details_list[1]
    else:
        name_details_list = name_string.split(',')
        name = ' '.join(name_details_list[:2])
        address = ','.join(name_details_list[2:])
        
    return name, address, alias_names_string


def __format_identification_number(identification_no_list, nationality):
    """ Function to convert Identification number to JSON format

    Args:
        identification_no_list: List of identification numbers
        nationality: Nationality of the identified person

    Returns: returns list of identification numbers in a JSON format

    """
    identification_no_dict = {}
    for identification_no in identification_no_list:
        id_details_list = identification_no.split('(')
        if len(id_details_list) > 1:
            country_string = id_details_list[1].split(')')[0].replace(' ', '').lower()
            id_no = id_details_list[0].strip().replace(' ', '').lower()
            if country_string in identification_no_dict:
                identification_no_dict[country_string].append(id_no)
            else:
                identification_no_dict[country_string] = [id_no]
        elif nationality:
            id_no = id_details_list[0].strip().replace(' ', '').lower()
            nationality = nationality.replace(' ', '').lower()
            if nationality in identification_no_dict:
                identification_no_dict[nationality].append(id_no)
            else:
                identification_no_dict[nationality] = [id_no]
        else:
            id_no = id_details_list[0].strip().replace(' ', '').lower()
            if "null" in identification_no_dict:
                identification_no_dict["null"].append(id_no)
            else:
                identification_no_dict["null"] = [id_no]
    identification_no_dict = json.dumps(identification_no_dict)
    return identification_no_dict


def __format_date(date_list):
    """Function to format date string

    Args:
        date_list: List of dates

    Returns: returns formatted date string as a list

    """
    final_date_list = []
    months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10,
              'Nov': 11, 'Dec': 12}
    try:
        final_date_list = []
        for date in date_list:
            if "to" in date:
                val=date.split(" ")
                if len(val[0]) ==4:
                    start= int(val[0])
                    end=int(val[2])
                    count=0
                    while start <= end:
                        count=start
                        final_date_list.append(str(count))
                        start+=1
                  
                else:
                    splitted=date.replace(" ",'').split("to")
                    lst=[]
                    for i in range(len(splitted)):
                        dd=splitted[i][:2]
                        mm=months[splitted[i][2:5]]
                        yy=splitted[i][5:]
                        convert=str(dd)+"-"+str(mm)+"-"+str(yy)
                        lst.append(convert)
                    
                    start = datetime.datetime.strptime(lst[0], "%d-%m-%Y")
                    end = datetime.datetime.strptime(lst[1], "%d-%m-%Y")
                    date_generated = pd.date_range(start, end,periods=None, freq=None, tz=None, normalize=False, name=None)
                    date_final=date_generated.strftime("%Y-%m-%d")
                    for dates in date_final:
                        final_date_list.append(dates)
                    
            else:
                dd_mm_yy_list = date.split(' ')
                if len(dd_mm_yy_list) > 2:
                    mm = dd_mm_yy_list[1].strip()
                    dd = dd_mm_yy_list[0].strip()
                    yy = dd_mm_yy_list[2].strip()
                    month = months[mm]
                    date = datetime.datetime(int(yy), int(month), int(dd), 0, 0)
                    date_string = date.strftime('%Y-%m-%d')
                    final_date_list.append(date_string)
                else:
                    final_date_list.append(dd_mm_yy_list[0].strip())
        
    except Exception as e:
        pass
    return final_date_list
