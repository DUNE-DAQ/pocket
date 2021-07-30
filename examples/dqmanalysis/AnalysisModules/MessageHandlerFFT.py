#%%
#internal modules
from kafka import consumer
from psycopg2.extensions import TRANSACTION_STATUS_INERROR
import KafkaService
import DbStatements

#external modules
import os
import os.path
from kafka import KafkaConsumer
import bson
import numpy
import time
import json
conf = json.load(open('configuration.json',))
host = conf["FileStorage"]

extensionName = ""
defaultRetention = 10

consumer = KafkaConsumer(conf["Kafka"]["Channels"]["HandlerInputs"],
                         bootstrap_servers=conf["Kafka"]["Servers"],
                         client_id=conf["Kafka"]["ClientId"])

DbStatements.setDabaseConnection(conf["Database"]["Server"],conf["Database"]["Name"], conf["Database"]["UserName"], conf["Database"]["Password"], conf["Database"]["Port"])   

#%%

def dataBSONWritting(dataSource, data, filename, extension, datas, defaultRetention, host):    

    dataId = DbStatements.NewData(host, data, dataSource, defaultRetention)


    dataList = datas

    labelList = []

    labelsX = ""

    dictionary = {"LabelXs" : labelsX, "Labels" : labelList, "Datas" : dataList}

    bsonFile = bson.BSON.encode(dictionary)

    with open(host + "/" + dataSource + "/" + data + "/" + filename + extension,"wb") as f:
        f.write(bsonFile)

    return dataId

#%%
fullData = []

def dataProcessing(dictionary):
    
    global fullData

    datas = bson.BSON.decode(dictionary)

    for data in datas['Datas']:
        fullData.append(data)
        #print(len(data))
    
    while(len(fullData) > 800):
            fullData.pop(0)

    return numpy.transpose(fullData)

#%%
def consumerInitlizer():
    recordCount = 0
    topic = conf["Kafka"]["Channels"]["PlatformInputs"]
    ####ANALYSIS SPECIFIC####
    dataSourceName = "dqmTestProcessUnit2"
    dataName = "FFT1"
    #########################

    ### TEMPORARY
    iterator = 0
    ###

    for msg in consumer:
        try:   
            ### TEMPORARY
            timeStamp = str(time.time())
            ###
            #Readout from message
            originalDataId, originalRecordId, dataPath, encoding, originalDataName, run, subRun, event, timeStamp = KafkaService.MessageInputProcessing(msg)

            if  "fourier10s" in originalDataName:
                
                with open(dataPath,"rb") as f:
                    data = dataProcessing(f.read()).tolist()            
                
                ### TEMPORARY
                if iterator > 2:
                    iterator = 0
                dataName = "FFT" + str(iterator)
                iterator = iterator +1
                ###

                #Writes the data to EOS
                dataId = dataBSONWritting(dataSourceName, dataName, timeStamp, extensionName, data, defaultRetention, host)
                KafkaService.DataOutput(topic, dataSourceName, dataName, dataId, host, recordCount, timeStamp, extensionName, run, subRun, event)


        except Exception as err:
            print(err)
            pass

#consumerInitlizer()
#%%
