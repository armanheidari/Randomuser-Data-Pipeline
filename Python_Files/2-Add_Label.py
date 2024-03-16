#!/usr/bin/python3
import json
from kafka import KafkaConsumer
from kafka import KafkaProducer
from dotenv import load_dotenv
from pathlib import Path
import os
import sys
from faker import Faker


dir_path = Path(__file__).parent.parent
sys.path.append(str(dir_path / 'Python_Files'))
from Logger import Log


load_dotenv(dotenv_path=str(dir_path / '.env'))

logger = Log()
fake = Faker()

KAFKA_HOST_PORT = os.getenv('KAFKA_HOST_PORT', 9092)

logger.info(
    f"Topic 2-Add_Label - Consumer Connection... - Port: {KAFKA_HOST_PORT}")

consumer = KafkaConsumer(
    'Add_Label',
    bootstrap_servers=[f'localhost:{KAFKA_HOST_PORT}'],
    enable_auto_commit=True,
    group_id='project_group',
    value_deserializer=lambda x: json.loads(x.decode('utf-8'))
)

logger.info('Topic 2-Add_Label - Connection Successful')

producer = KafkaProducer(
    bootstrap_servers=[f'localhost:{KAFKA_HOST_PORT}'],
    value_serializer=lambda x: json.dumps(x).encode('utf-8')
)

def add_info(data: dict):
    data['company'] = fake.company()
    return data

for message in consumer:
    logger.info(
        f"Key:{message.key}\tValue:{message.value}")

    data = add_info(message.value)
    
    producer.send('Add_Database', value=data)
    producer.flush()

    logger.info(
        f'Topic 2-Add_Label: username= {data["username"]} - Sent to 3)Add_Database')
