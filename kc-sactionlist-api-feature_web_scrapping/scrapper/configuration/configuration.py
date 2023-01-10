""" ACCESSSING CONFIGURATION YAML FILE
* Developed By : Travancore Analytics (2022)
* Author: SIBIN PAUL 
* Created on:26/10/2022
* Project: Kinara Capital
* Revision History:
* SNo.   | Date        | Author                   | Task                              | Comments |
* 1      26/10/2022     SIBIN PAUL                     ACCESSSING CONFIGURATION FILE """
import yaml
import pkg_resources


def get_configurations():
    with open(pkg_resources.resource_filename('configuration', 'configuration.yaml'), 'r') as file:
        configurations = yaml.safe_load(file)
    return configurations
