# Anagram validator

This service checks whether a given pair of strings are anagrams.

The validator runs on AWS Lambda and is triggered any time a new file named `anagrams.csv` is uploaded (created or updated) to an S3 bucket named `sandbox-anagram-fd-testing`.



The `anagrams.csv` file should have three columns in the following format (make sure the header is included):

|      | word_1 | word_2 |
| ---- | ------ | ------ |
| 0    | acer   | acre   |

Once the csv file is uploaded to S3, the lambda function is invoked and it retrieves the file contents.

Row by row, it checks whether the words on the second and third columns are strings, and if so, it checks if they are anagrams.

The result (true/false) is appended to the word pair and the list of `[index, word_1, word_2, is_anagram]` is logged in CloudWatch.

### Example output:

`[0, 'acre', 'acer', True]`



You can then filter the log output to find the anagrams in the csv file.



## Setup

This service was tested on macOS 11.2 using Terraform 1.0.3. and Python 3.7.3 and AWS CLI 2.0.56

### Requirements:

-  Terraform 1.0.3
-  AWS CLI 2.0

## Steps

1.  install Terraform
2.  install AWS CLI and make sure the IAM user or role can create and manage lambda functions, S3 buckets and CloudWatch logs
3.  Navigate to the project folder (where this readme file is located)
4.  Zip the lambda.py function. In your terminal: `zip lambda.zip lambda.py`
5.  Initialize Terraform: `terraform init`
6.  Deploy the changes described in `main.tf`  :`terraform apply`
7.  Follow the steps in the Jupyter notebook to generate a `anagrams.csv` file
8.  Once the services are deployed, upload the `anagrams.csv` file to the S3 bucket `sandbox-anagram-fd-testing`
9.  Go to the lambda function `aandrei_anagram_validator` and check its most recent logs, where the results should appear (see Example output above)