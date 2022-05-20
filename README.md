# Time and Tide: iCal API for UK Tide Times
iCal files for UK high tides.

![Seascape](docs/banner.png)


![license](https://img.shields.io/github/license/martinpauleve/time-and-tide) ![activity](https://img.shields.io/github/last-commit/MartinPaulEve/time-and-tide)

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white) ![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white) ![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black) ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

This AWS Lambda function produces an iCal calendar for the next seven days of high tides at the location specified in the location querystring.

For example, you can see it in action/use it at [https://tides.eve.gd/ical?location=Broadstairs](https://tides.eve.gd/ical?location=Broadstairs).

In its technical capacity, this project demonstrates how to wire a Python Lambda function to a subdomain with SSL/HTTPS on AWS. 

## Features
* iCal files for high tides at all UK locations. Valid locations at [tide times](https://www.tidetimes.org.uk/broadstairs-tide-times-20220519).
* Synchronizes the next seven days.
* Compatible with Google Calendar and other iCal-based systems.

## Tech Features
* Python lambda function.
* Scraping approach to data collection.
* Caching (while function is warm).
* AWS Application Gateway.
* Custom domain.
* SSL support.
* MIME type/content type passthrough.

## Running it Yourself

If you want to run it yourself on AWS, first, obviously, configure your AWS account and setup your credentials so that terraform can connect. Then add a terraform.tfvars file with details of the hosted domain and SSL certificate to use:

    ssl_certificate_arn = "arn:aws:acm:us-east-1:747101050174:certificate/0816d2e4-1c07-44e0-99e0-55763e24615e"
    hosted_zone_id      = "Z04028672340GRJRXW460"
    hosted_zone_arn     = "arn:aws:route53:::hostedzone/Z04028672340GRJRXW460"
    domain_name         = "tides.eve.gd"

Then run:

    cd tides
    ./build.sh
    cd ..
    terraform init
    terraform plan
    terraform apply


# Credits
* [terraform-api-gateway](https://github.com/clouddrove/terraform-aws-api-gateway) by CloudDrove. Here forked to fix a VPC endpoints issue. 
* [Git](https://git-scm.com/) from Linus Torvalds _et al_.
* [.gitignore](https://github.com/github/gitignore) from Github.
* [Terraform](https://www.terraform.io/) by Hashicorp.

&copy; Martin Paul Eve 2022