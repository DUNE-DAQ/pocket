#%%
import uuid
import psycopg2
from psycopg2.extensions import TRANSACTION_STATUS_INERROR
import time
import os
from os import walk
import os.path

knownDataSources = {}
knownDataIds = {}

#%%
def setDabaseConnection(host, dbname, user, password, port):
    try:
        global dbConnectionInsert
        dbConnectionInsert = psycopg2.connect(
        host=host,
        dbname=dbname,
        user=user,
        password=password,
        port=port)
        global cursorInsert
        cursorInsert = dbConnectionInsert.cursor()

        global dbConnectionSelect
        dbConnectionSelect = psycopg2.connect(
        host=host,
        dbname=dbname,
        user=user,
        password=password,
        port=port)
        global cursorSelect
        cursorSelect = dbConnectionSelect.cursor()


    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

#%%
def databaseInsert(postgres_insert_query, record_to_insert):
    try:
        cursorInsert.execute(postgres_insert_query, record_to_insert)

        dbConnectionInsert.commit()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        


#%%
def databaseQuerry(querry):
    try:

        querry = querry.replace("\\", "")

        cursorSelect.execute(querry)

        querryResult = cursorSelect.fetchall()
    
        return querryResult
        
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        

#%%
def addDataFile(path, storagePlace, dataId, run, subRun, event):
    try:
            postgres_insert_query = "INSERT INTO public.\"DataPaths\"(\"Id\", \"DataId\", \"WriteTime\", \"Path\", \"Storage\", \"Run\", \"SubRun\", \"EventNumber\") VALUES (%s,%s,%s,%s,%s,%s,%s,%s)" 
            
            dt = time.time()
            recordId = str(uuid.uuid4())
            record_to_insert = (recordId,dataId,(dt,), path, storagePlace, run, subRun, event)
            insertResults = databaseInsert(postgres_insert_query, record_to_insert)

    except Exception as err:
        print(err)
        pass


    return recordId

#%%
#if Data or source doesn't exist yet, in file or DB creates it
def NewData(host, data, dataSource, defaultRetention):
    #print("dataSource " + dataSource)
    global knownDataSources
    global knownDataIds

    try:

        if not os.path.exists(host + "/" + dataSource):
            os.makedirs(host + "/" + dataSource)
        if not os.path.exists(host + "/" + dataSource + "/" + data):
            os.makedirs(host + "/" + dataSource + "/" + data)

        #Add dictionnary to avoid querryign too often database
        if dataSource not in knownDataSources.keys() or data not in knownDataIds.keys():
            sourceIds = databaseQuerry("SELECT \"Id\" From \"DataSources\" WHERE \"Source\" LIKE '"+dataSource+"'")
            if sourceIds == []:
                postgres_insert_query = "INSERT INTO public.\"DataSources\"(\"Id\", \"Source\") VALUES (%s,%s)" 
                recordId = str(uuid.uuid4())
                record_to_insert = (recordId,dataSource)
                insertResults = databaseInsert(postgres_insert_query, record_to_insert)
                sourceIds = databaseQuerry("SELECT \"Id\" From \"DataSources\" WHERE \"Source\" LIKE '"+dataSource+"'")
                print("New source added")
            knownDataSources[dataSource] = sourceIds[0][0]


            dataIds = databaseQuerry("SELECT \"Id\" From \"Data\" WHERE \"Name\" LIKE '"+data+"' AND \"DataSourceId\" = '"+sourceIds[0][0]+"'")
            if dataIds == []:
                postgres_insert_query = "INSERT INTO public.\"Data\"(\"Id\", \"DataSourceId\", \"RententionTime\", \"Name\") VALUES (%s,%s,%s,%s)" 
                recordId = str(uuid.uuid4())
                record_to_insert = (recordId,sourceIds[0][0],defaultRetention, data)
                insertResults = databaseInsert(postgres_insert_query, record_to_insert)
                dataIds = databaseQuerry("SELECT \"Id\" From \"Data\" WHERE \"Name\" LIKE '"+data+"' AND \"DataSourceId\" = '"+sourceIds[0][0]+"'")
                print("New data added")
            knownDataIds[data] = dataIds[0][0]
            return dataIds[0][0]

        else:
            return knownDataIds[data]


    except Exception as err:
            print(err)
            pass
# %%
