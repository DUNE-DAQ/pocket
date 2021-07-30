#%%
from os import walk
import KafkaService
import DbStatements
import time
from glob import glob
from kafka import KafkaConsumer
import bson
import json
conf = json.load(open('configuration.json',))
host = conf["FileStorage"]

consumer = KafkaConsumer(conf["Kafka"]["Channels"]["DQMInputs"],
                         bootstrap_servers=conf["Kafka"]["Servers"],
                         client_id=conf["Kafka"]["ClientId"])

DbStatements.setDabaseConnection(conf["Database"]["Server"],conf["Database"]["Name"], conf["Database"]["UserName"], conf["Database"]["Password"], conf["Database"]["Port"])     

#%% 
def dataWritting(dataSource, data, filename, extension, content, defaultRetention):    
    
    dataId = DbStatements.NewData(host, data, dataSource, defaultRetention)

    with open(host + "/" + dataSource + "/" + data + "/" + filename + extension,"a+") as f:
        f.write(content)

    return dataId


def dataBSONWritting(dataSource, data, filename, extension, datas, defaultRetention):    

    dataId = DbStatements.NewData(host, data, dataSource, defaultRetention)

    datas = datas.split("\\n")



    dataList = []
    for i in range(2, len(datas),2) :
        datas[i] = datas[i].split(" ")
        datas[i] = [value for value in datas[i] if value.replace(".","",1).isdigit()]
        dataList.append(list(map(float, datas[i])))

    labelList = []
    for i in range(1, len(datas),2) :
        labelList.append(datas[i])

    labelList.pop(len(labelList)-1)

    labelsX = datas[0].split(" ")


    dictionary = {"LabelXs" : labelsX, "Labels" : labelList, "Datas" : dataList}

    bsonFile = bson.BSON.encode(dictionary)
    bsonDecoded = bson.BSON(bsonFile).decode()

    with open(host + "/" + dataSource + "/" + data + "/" + filename + extension,"wb") as f:
        f.write(bsonFile)

    return dataId



#%%
def consumerInitlizer():
    recordCount = 0
    topic = conf["Kafka"]["Channels"]["HandlerInputs"]
    for msg in consumer:
        try:   
            #processes the kafka message from the DQM module simulator
            message = str(msg.value).split(';')
            message[0] = message[0].replace("b", "")
            message[0] = message[0].replace("'", "")
            message[0] = message[0].replace('"', "")

            dataSourceName = message[0]
            dataName = message[1]
            run = message[2]
            subRun = message[3]
            event = message[4]
            timeStamp = message[5]
            metadata = message[6]
            data = message[7]

            ####TEMPORARY####
            timeStamp = str(time.time())
            extensionName = ""
            storageType = "BSON"
            defaultRetention = 10
            #################

            #Writes the data to EOS
            #dataWritting(dataSource, data, filename, extension, content)
            dataId = dataBSONWritting(dataSourceName, dataName, timeStamp, extensionName, data, defaultRetention)
            #Data path summary
            KafkaService.DataOutput(topic, dataSourceName, dataName, dataId, host, recordCount, timeStamp, extensionName, run, subRun, event)

        except Exception as err:
                print(err)
                pass

#consumerInitlizer()
#%%


# %%

# %%
