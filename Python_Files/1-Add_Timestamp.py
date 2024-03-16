import json
from kafka import KafkaConsumer
from kafka import KafkaProducer
import time
from dotenv import load_dotenv
from pathlib import Path
import os
import sys

dir_path = Path(__file__).parent.parent
sys.path.append(str(dir_path / 'Python_Files'))
from Logger import Log


load_dotenv(dotenv_path=str(dir_path / '.env'))

logger = Log()

KAFKA_HOST_PORT = os.getenv('KAFKA_HOST_PORT', 9092)

logger.info(
    f"Topic 1-Add_Timestamp - Consumer Connection... - Port: {KAFKA_HOST_PORT}")

consumer = KafkaConsumer(
    'Add_Timestamp',
    bootstrap_servers=[f'localhost:{KAFKA_HOST_PORT}'],
    enable_auto_commit=True,
    group_id='project_group',
    value_deserializer=lambda x: json.loads(x.decode('utf-8'))
)

logger.info('Topic 1-Add_Timestamp - Connection Successful')

producer = KafkaProducer(
    bootstrap_servers=[f'localhost:{KAFKA_HOST_PORT}'],
    value_serializer=lambda x: json.dumps(x).encode('utf-8')
)

for message in consumer:
    logger.info(
        f"Key:{message.key}\tValue:{message.value}")

    data = message.value
    data['ts'] = time.strftime('%Y-%m-%d %H:%M:%S')
    producer.send('Add_Label', value=data)
    producer.flush()

    logger.info(
        f'Topic 1-Add_Timestamp: username= {data["username"]} - Sent to 2)Add_Label')
