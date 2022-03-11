from pymongo import MongoClient
from pprint import pprint

client = MongoClient("127.0.0.1:27018")
db=client.admin
# Issue the serverStatus command and print the results
serverStatusResult=db.command("serverStatus")
# pprint(serverStatusResult)

# for db in client.list_databases():
#     print(db)
    
#     for collection in client[db['name']].list_collection_names():
#         print(f"  {collection}")

db = client.test
# db.test.insert_many([{"x": 1, "tags": ["dog", "cat"]},
#                      {"x": 2, "tags": ["cat"]},
#                      {"x": 2, "tags": ["mouse", "cat", "dog"]},
#                      {"x": 3, "tags": []}])

# for content in 
# print(client.local.collection.find_one())
# db = client.test

 
for stuff in db.test.find({}):
    pprint(stuff)
