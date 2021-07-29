import json
import sys
import urllib.parse
import boto3
import logging

# set up logging
logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.INFO)

logger.info('Loading function')

s3 = boto3.client('s3')

def is_anagram(word_1:str, word_2:str) -> bool:
    if (type(word_1) != str) or (type(word_2) != str):
        logger.error("Input must be string")
        return "could not check"
    try:
        word_1 = word_1.lower()
        word_2 = word_2.lower()
    except Exception as e:
        logger.error(f"Error happened: {e}")
        sys.exit()
    
    anagram_test = sorted(word_1) == sorted(word_2)
    
    return anagram_test


def handler(event, context):
    #logger.info("Received event: " + json.dumps(event, indent=2))

    # parse bucket and file (key) names
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    # only process the file anagrams.csv
    if key == "anagrams.csv":
        try:
            response = s3.get_object(Bucket=bucket, Key=key)
            rows    = response['Body'].read().decode('utf-8').split('\n')

            #iterate through each word pair and append the result of the anagram check
            for row in rows[1:]:
                row = row.split(',')
                # only check anagrams if the row dimension is correct (i.e. 2 words)
                if len(row) == 3:
                    row.append(is_anagram(row[1],row[2]))
                logger.info('anagram test: ' + str(row))
            logger.info("logger info: Anagram check complete")
            return {
            "message" : "Anagram check complete"
        }
        except Exception as e:
            logger.error(e)
    else:
        return {
            "message" : "The file added to S3 is not anagrams.csv. Goodbye",
            "bucket"  : bucket,
            "key"     : key
        }
              