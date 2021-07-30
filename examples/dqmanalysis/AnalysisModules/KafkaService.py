#%%
from kafka import KafkaProducer
import json
import DbStatements
conf = json.load(open('configuration.json',))
host = conf["FileStorage"]


#%%
producer = KafkaProducer(bootstrap_servers=conf["Kafka"]["Servers"])


#%%
def sendData(topic, content):
    future = producer.send(topic, content)
    try:
        record_metadata = future.get(timeout=10)
    except Exception as err:
        print(err)
        pass

def MessageInputProcessing(msg):

    #processes the kafka message from the DQM module simulator
    message = str(msg.value).split(',')
    message[0] = message[0].replace("b", "")
    message[0] = message[0].replace("'", "")
    message[0] = message[0].replace('"', "")

    originalDataId = message[0]
    originalRecordId = message[1]
    dataPath = message[2]
    encoding = message[3]
    originalDataName = message[4]
    run = message[5]
    subRun = message[6]
    event = message[7]
    timeStamp = message[8]

    return originalDataId, originalRecordId, dataPath, encoding, originalDataName, run, subRun, event, timeStamp

#%%
def DataOutput(topic, dataSourceName, dataName, dataId, host, recordCount, timeStamp, extensionName, run, subRun, event):
    storageType = "BSON" 
    
    #Data path summary
    dataPath = host + "/" + dataSourceName + "/" + dataName + "/" + timeStamp + extensionName
    #Add the path to the database
    recordId = DbStatements.addDataFile(dataPath, storageType, dataId, run, subRun, event)
    #announces via kafka the new entry
    sendData(topic, bytes(dataId + "," + recordId + "," + dataPath + "," + storageType + "," + dataName  + "," + run + "," + subRun + "," + event + "," + timeStamp, 'utf-8'))
    recordCount = recordCount + 1
    print("Sent record : " + dataName)